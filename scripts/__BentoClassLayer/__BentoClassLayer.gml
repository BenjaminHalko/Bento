// Feather disable all

/// @param environment
/// @param name

function __BentoClassLayer(_environment, _name) constructor
{
    static _system = __BentoSystem();
    
    __environment = _environment;
    __name        = _name;
    
    if (BENTO_DEBUG_LEVEL >= 1)
    {
        __BentoTrace($"Creating layer {__BentoGetStructPointer(self)} called \"{__name}\" in environment {__BentoGetStructPointer(__environment)}");
    }
    
    ////////
    // Gemeral state
    ////////
    
    __rootElement = BENTO_NO_ELEMENT;
    
    __isTopLayer = true;
    __drawWhenBackgrounded = true;
    __runStep = true;
    
    __animPlayingArray      = [];
    __animPlayingMap        = ds_map_create();
    __animBlockingMap       = ds_map_create();
    __animAnyBlocking       = false;
    __animUnblockedCallback = undefined;
    __animUnblockedMetadata = undefined;
    __animUnblockedPersist  = false;
    
    ////////
    // Input state
    ////////
    
    __playerArray = array_create_ext(BENTO_MAX_PLAYERS, function(_playerIndex)
    {
        return new __BentoClassPlayer(self, _playerIndex);
    });
    
    __pointerScrolled = false;
    __pointerScrollingElement = BENTO_NO_ELEMENT;
    __pointerScrollPlayerIndex = undefined;
    
    ////////
    // Update tracking
    ////////
    
    __layoutOrder    = [];
    __stepOrder      = [];
    __hoverableOrderPointer    = [];
    __hoverableOrderNavigation = [];
    __drawOrder      = [];
    
    __dirtyFlags = __BENTO_DIRTY_ALL;
    __hoverableRegenCount = 0;
    
    __dirtyChildOrderArray   = [];
    __dirtyScrollLimitsArray = [];
    __dirtyOffsetArray       = [];
    __dirtyTransformsArray   = [];
    __scrollAnimatingArray   = [];
    
    __carryNextItemElement = BENTO_NO_ELEMENT;
    __carryNextPlayerIndex = undefined;
    __carryItemElement     = BENTO_NO_ELEMENT;
    __carryPlayerIndex     = undefined;
    
    __updateElementArray = [];
    
    __focusStack = [];
    __focusTop   = undefined;
    
    
    
    
    
    static __Destroy = function()
    {
        if (BENTO_DEBUG_LEVEL >= 1)
        {
            __BentoTrace($"Destroying layer {__BentoGetStructPointer(self)} called \"{__name}\" in environment {__BentoGetStructPointer(__environment)}");
        }
        
        BentoDestroy(__rootElement);
        __environment.__RemoveLayer(self);
    }
    
    static __SetBackgroundedState = function()
    {
        __isTopLayer = false;
        
        __ClearScrollingElement();
        
        //If this layer has the current text handler then abort its use
        if ((__environment.__textElement != undefined) && (__environment.__textElement.BENTO_VARS.__layer == self))
        {
            __environment.__textHandler.__Terminate(BENTO_TEXT_ABORT);
        }
        
        var _i = 0;
        repeat(BENTO_MAX_PLAYERS)
        {
            if (__playerArray[_i].__active)
            {
                __playerArray[_i].__SetBackgroundedState();
                __playerArray[_i].__active = false;
            }
            ++_i;
        }
        __dirtyFlags |= __BENTO_DIRTY_STEP | __BENTO_DIRTY_HOVERABLE;
        
        __ClearDraggedItem();
    }
    
    static __SetForegroundedState = function()
    {
        __isTopLayer = true;
        __UpdateInputMode();
        
    }
    
    static __ClearDraggedItem = function()
    {
        if (__carryItemElement != BENTO_NO_ELEMENT)
        {
            __carryItemElement = BENTO_NO_ELEMENT;
            __carryPlayerIndex = undefined;
            
            if (BentoExists(__carryItemElement))
            {
                __carryItemElement.BENTO_VARS.__carryTargetElement = BENTO_NO_ELEMENT;
            }
            
            __dirtyFlags |= __BENTO_DIRTY_HOVERABLE;
        }
    }
    
    static __ClearScrollingElement = function()
    {
        __pointerScrolled = false;
        __pointerScrollingElement = BENTO_NO_ELEMENT;
        __pointerScrollPlayerIndex = undefined;
    }
    
    static __UpdateInputMode = function()
    {
        var _i = 0;
        repeat(BENTO_MAX_PLAYERS)
        {
            __playerArray[_i].__UpdateInputMode(__environment.__envInputMode[_i]);
            ++_i;
        }
        
        //Focus, carry and scrolling are shared and follow the input mode of the player that started them
        
        //Find any focused element that needs to be closed if we've swapped to a pointer mode
        var _focusStack = __focusStack;
        var _i = 0;
        repeat(array_length(_focusStack))
        {
            var _element = _focusStack[_i].__focusElement;
            var _player = __playerArray[_focusStack[_i].__playerIndex];
            if (_player.__changedMode && _player.__inputModePointer && (_element.BENTO_VARS.__focusType == BENTO_FOCUS_POINTER_CANCEL_ALWAYS))
            {
                BentoFocusClose(_element);
                break;
            }
            
            ++_i;
        }
        
        if ((__carryNextPlayerIndex != undefined) && __playerArray[__carryNextPlayerIndex].__changedMode)
        {
            __carryNextItemElement = BENTO_NO_ELEMENT;
        }
        
        if ((__carryPlayerIndex != undefined) && __playerArray[__carryPlayerIndex].__changedMode)
        {
            if (BentoExists(__carryItemElement))
            {
                __carryItemElement.BENTO_VARS.__carryItemContinuous = true;
            }
        }
        
        if ((__pointerScrollPlayerIndex != undefined) && __playerArray[__pointerScrollPlayerIndex].__changedMode)
        {
            __ClearScrollingElement();
        }
    }
    
    static __Ensure = function(_rootX, _rootY, _rootWidth, _rootHeight)
    {
        //Ensure our root element is the same size as the overall Bento space
        BentoSetOffset(_rootX, _rootY, __rootElement);
        BentoLayoutSetSize(_rootWidth, _rootHeight, __rootElement);
        
        //Keep our layout and step order updated as necessary. Updating the layer and step order here
        //catches any weird stuff the dev might've done between calls to `BentoSystemStep()`
        __BentoEnsureLayout();
        __BentoEnsureStepOrder();
        __BentoEnsureScrollLimits();
        __BentoEnsureOffset();
        __BentoEnsureHoverableOrder();
    }
    
    static __Update = function(_rootX, _rootY, _rootWidth, _rootHeight, _timeStep)
    {
        var _isTopLayer = __isTopLayer;
        
        //This is the main update function for a layer. It handles hovering elements, holding elements,
        //scrolling containers, disabling focus etc.
        
        __BentoLayerTargetPush(self);
        
        ///////
        // Animations
        ///////
        
        var _animPlayingArray = __animPlayingArray;
        var _i = array_length(_animPlayingArray)-1;
        repeat(array_length(_animPlayingArray))
        {
            with(_animPlayingArray[_i])
            {
                __animElapsed += _timeStep;
                
                var _t = clamp((__animElapsed - __animDelay) / __animDuration, 0, 1);
                if (_t >= 1)
                {
                    BentoAnimStop(true, __attachedElement);
                }
                else
                {
                    __animMethod(__attachedElement, _t, __animMetadata);
                }
            }
            
            --_i;
        }
        
        if (not ds_map_empty(__animBlockingMap))
        {
            //If anything has a blocking animating, consume all input
            if (_isTopLayer)
            {
                BentoInputConsume(self);
            }
        }
        else
        {
            //Otherwise check if we need to execute the unblocked callback
            __CheckUnblocked();
        }
        
        if (_isTopLayer)
        {
            __UpdateInputMode();
        }
        
        ///////
        // Drag & drop
        ///////
        
        if (BentoExists(__carryNextItemElement))
        {
            //Incoming new item element
            
            if ((__carryNextItemElement != __carryItemElement) || (__carryNextPlayerIndex != __carryPlayerIndex))
            {
                //The item element has changed
                
                if (BentoExists(__carryItemElement))
                {
                    //To avoid bugs, reset the target for the existing item element
                    __carryItemElement.BENTO_VARS.__carryTargetElement = BENTO_NO_ELEMENT;
                }
                
                __carryItemElement = __carryNextItemElement;
                __carryPlayerIndex = __carryNextPlayerIndex;
                
                //We're going to scroll using edge detection so we don't need to actively track grabbing a scrollable element
                __ClearScrollingElement();
                
                var _player = __playerArray[__carryPlayerIndex];
                with(__carryItemElement.BENTO_VARS)
                {
                    __carryPointerDX = _player.__pointerPressX - __attachedElement.bentoX;
                    __carryPointerDY = _player.__pointerPressY - __attachedElement.bentoY;
                    
                    __carryTargetElement = BENTO_NO_ELEMENT;
                    __BentoSetAsUpdating();
                }
                
                __dirtyFlags |= __BENTO_DIRTY_HOVERABLE;
            }
            
            __carryNextItemElement = BENTO_NO_ELEMENT;
        }
        else if (__carryItemElement != BENTO_NO_ELEMENT)
        {
            //No new item element
            
            if ((not BentoExists(__carryItemElement)) || __carryItemElement.BENTO_VARS.__carryItemContinuous)
            {
                //If we have no new drag & drop item element and the current item is continuous then we've lost the item
                __carryItemElement = BENTO_NO_ELEMENT;
                __carryPlayerIndex = undefined;
                __dirtyFlags |= __BENTO_DIRTY_HOVERABLE;
            }
        }
        
        ///////
        // Ensure various orders
        ///////
        
        var _i = 0;
        repeat(BENTO_MAX_PLAYERS)
        {
            var _player = __playerArray[_i];
            var _active = _isTopLayer && __environment.__envPlayerActive[_i];
            if (_active != _player.__active)
            {
                if (_active)
                {
                    _player.__SetForegroundedState();
                }
                else
                {
                    _player.__SetBackgroundedState();
                    //Inactive players must disappear even when background hover is maintained.
                    _player.__ClearHoverElement();
                    if (_i == __pointerScrollPlayerIndex) __ClearScrollingElement();
                    if (_i == __carryPlayerIndex) __ClearDraggedItem();
                }
                _player.__active = _active;
                __dirtyFlags |= __BENTO_DIRTY_STEP | __BENTO_DIRTY_HOVERABLE;
            }
            ++_i;
        }
        
        __Ensure(_rootX, _rootY, _rootWidth, _rootHeight);
        
        ///////
        // Input
        ///////
        
        var _playerArray = __playerArray;
        
        var _i = 0;
        repeat(BENTO_MAX_PLAYERS)
        {
            if (_playerArray[_i].__active)
            {
                _playerArray[_i].__UpdateInputStateAsTopLevel();
            }
            else
            {
                _playerArray[_i].__UpdateInputStateAsBackgrounded();
            }
            ++_i;
        }
        
        if (_isTopLayer)
        {
            //Reset the drag & drop element if it has been destroyed for some reason or its channel has
            //been set to `undefined`
            if ((__carryItemElement != BENTO_NO_ELEMENT)
            &&  ((not __BentoGetHoverableInternal(__carryItemElement, false)) || (__carryItemElement.BENTO_VARS.__carryItemChannel == undefined)))
            {
                __ClearDraggedItem();
            }
        }
        
        var _i = 0;
        repeat(BENTO_MAX_PLAYERS)
        {
            _playerArray[_i].__UpdatePrimaryState();
            ++_i;
        }
        
        if (_isTopLayer)
        {
            ///////
            // Pointer and Navigation
            ///////
            
            __BentoScissorReset();
            
            var _i = 0;
            repeat(BENTO_MAX_PLAYERS)
            {
                if (_playerArray[_i].__active) _playerArray[_i].__UpdateHover();
                ++_i;
            }
        }
        
        //Always run Step events if we're the top layer
        __runStep = _isTopLayer;
        
        //Update elements of interest. `__runStep` is also set to `true` in here too depending on what
        //state elements are in
        array_resize(__updateElementArray, array_filter_ext(__updateElementArray, function(_elementVars)
        {
            return __BentoUpdateActiveElement(_elementVars);
        }));
        
        //Reset this mouse state after we update element state. This ensures we set the correct
        //state when releasing after dragging a scrollable container
        if ((__pointerScrollPlayerIndex != undefined) && (_playerArray[__pointerScrollPlayerIndex].__primaryState == __BENTO_STATE_END))
        {
            __ClearScrollingElement();
        }
        
        if (__runStep)
        {
            ///////
            // Step user event execution
            ///////
            
            var _stepOrder = __stepOrder;
            var _i = 0;
            repeat(array_length(_stepOrder))
            {
                _stepOrder[_i]();
                ++_i;
            }
        }
        
        ///////
        // Position updates
        ///////
        
        //Check to see if we need to update the layout and step order again
        __BentoEnsureLayout();
        __BentoEnsureStepOrder();
        __BentoEnsureScrollLimits();
        __BentoAnimateScroll(_timeStep);
        __BentoEnsureOffset();
        
        //And we're done
        __BentoLayerTargetPop();
    }
    
    static __UpdatePartialOnCreate = function(_rootX, _rootY, _rootWidth, _rootHeight)
    {
        __BentoLayerTargetPush(self);
        
        //Initialize all the animations
        var _animPlayingArray = __animPlayingArray;
        var _i = array_length(_animPlayingArray)-1;
        repeat(array_length(_animPlayingArray))
        {
            with(_animPlayingArray[_i])
            {
                __animMethod(__attachedElement, 0, __animMetadata);
            }
            
            --_i;
        }
        
        __Ensure(_rootX, _rootY, _rootWidth, _rootHeight);
        
        __BentoLayerTargetPop();
    }
    
    static __Draw = function()
    {
        __BentoLayerTargetPush(self);
        
        __BentoEnsureLayout();
        __BentoEnsureScrollLimits();
        __BentoEnsureOffset();
        __BentoEnsureTransforms();
        __BentoEnsureDrawOrder();
        
        if (__isTopLayer || __drawWhenBackgrounded)
        {
            var _drawOrder = __drawOrder;
            var _i = 0;
            repeat(array_length(_drawOrder))
            {
                _drawOrder[_i]();
                ++_i;
            }
        }
        
        //Draw the hovered element if it's not inside a scissor. If the hovered element is inside
        //a scissor then it'll be drawn by `__BentoScissorPop()`
        var _playerArray = self.__playerArray;
        var _i = 0;
        repeat(BENTO_MAX_PLAYERS)
        {
            var _hoverElement = _playerArray[_i].__hoverElement;
            if (BentoExists(_hoverElement))
            {
                var _hoverElementVars = _hoverElement.BENTO_VARS;
                if (_hoverElementVars.__scissorParent == __rootElement.BENTO_VARS)
                {
                    var _j = 0;
                    repeat(_i)
                    {
                        if (_playerArray[_j].__hoverElement == _hoverElement) break;
                        ++_j;
                    }
                    
                    if (_j == _i)
                    {
                        _hoverElementVars.__eventDrawHover();
                    }
                }
            }
            
            ++_i;
        }
        
        if (__isTopLayer)
        {
            //Draw the dragged item element, if we have one
            var _player = (__carryPlayerIndex != undefined)? __playerArray[__carryPlayerIndex] : undefined;
            with(__carryItemElement)
            {
                //Store the current exposed position variables
                var _oldBentoLeft   = bentoLeft;
                var _oldBentoTop    = bentoTop;
                var _oldBentoRight  = bentoRight;
                var _oldBentoBottom = bentoBottom;
                var _oldBentoX      = bentoX;
                var _oldBentoY      = bentoY;
                
                //Calculate the vector from the old cursor position to the new cursor position
                if (_player.__inputModePointer)
                {
                    var _dX = _player.__pointerX - bentoX - BENTO_VARS.__carryPointerDX;
                    var _dY = _player.__pointerY - bentoY - BENTO_VARS.__carryPointerDY;
                }
                else if (_player.__inputModeNavigation)
                {
                    var _dX = _player.__navigationLastX - 0.5*(_oldBentoLeft + _oldBentoRight);
                    var _dY = _player.__navigationLastY - 0.5*(_oldBentoTop + _oldBentoBottom);
                }
                else
                {
                    var _dX = 0;
                    var _dY = 0;
                }
                
                //Move the exposed position to the wherever the cursor is
                bentoLeft   += _dX;
                bentoTop    += _dY;
                bentoRight  += _dX;
                bentoBottom += _dY;
                bentoX      += _dX;
                bentoY      += _dY;
                //Allow downstream code to set whatever variables it needs
                BENTO_VARS.__eventReposition();
                
                //Do the actual draw
                BENTO_VARS.__eventDrawDragged();
                
                //Restore the old position
                bentoLeft   = _oldBentoLeft;
                bentoTop    = _oldBentoTop;
                bentoRight  = _oldBentoRight;
                bentoBottom = _oldBentoBottom;
                bentoX      = _oldBentoX;
                bentoY      = _oldBentoY;
                BENTO_VARS.__eventReposition();
            }
        }
        
        __BentoLayerTargetPop();
    }
    
    static __DrawWireframe = function()
    {
        __BentoEnsureTransforms();
        
        var _func = function(_func, _elementVars, _baseAlpha)
        {
            //N.B. - This should match `__BentoEnsureDrawOrderInner()`
            
            with(_elementVars)
            {
                if (__disable) return;
                
                if (__transformMatrix != undefined)
                {
                    matrix_stack_push(__transformMatrix);
                    matrix_set(matrix_world, matrix_stack_top());
                }
                
                if (__visible)
                {
                    with(__attachedElement)
                    {
                        draw_set_alpha(_baseAlpha * ((BentoGetClickable() && BentoCursorGetHover())? 0.2 : 0.1));
                        draw_rectangle(bentoLeft, bentoTop, bentoRight, bentoBottom, false);
                        draw_set_alpha(_baseAlpha);
                        
                        draw_rectangle(bentoLeft, bentoTop, bentoRight, bentoBottom, true);
                        BentoDrawCross(bentoX, bentoY);
                    }
                }
                
                if (__scissorEnabled)
                {
                    __BentoDrawScissorPushFromVars();
                }
                
                //Add children created inside the parent to the Draw order
                var _array = __childDrawArray;
                var _i = 0;
                repeat(array_length(_array))
                {
                    _func(_func, _array[_i], _baseAlpha);
                    ++_i;
                }
                
                if (__scissorEnabled)
                {
                    __BentoDrawScissorPop();
                }
                
                BentoScrollbarDrawPlaceholder(BentoScrollbarGetHoriData(__attachedElement), __attachedElement);
                BentoScrollbarDrawPlaceholder(BentoScrollbarGetVertData(__attachedElement), __attachedElement);
                
                if (__transformMatrix != undefined)
                {
                    matrix_stack_pop();
                    matrix_set(matrix_world, matrix_stack_top());
                }
            }
        }
        
        var _oldAlpha = draw_get_alpha();
        _func(_func, __rootElement.BENTO_VARS, _oldAlpha);
        draw_set_alpha(_oldAlpha);
    }
    
    static __GetFocusRoot = function(_navigation)
    {
        //If we're inputting text then we have to focus on that element
        if (BentoExists(__environment.__textElement))
        {
            return __environment.__textElement;
        }
        
        //Determine where to start the Step order processing
        //FIXME - Walk up focus stack to find a pointer constrain element rather than only looking at the top one
        var _focusTop = __focusTop;
        if (BentoExists(_focusTop))
        {
            if (_navigation) return _focusTop;
            
            var _focusType = _focusTop.BENTO_VARS.__focusType;
            
            if ((_focusType == BENTO_FOCUS_POINTER_CONSTRAIN)
            ||  (_focusType == BENTO_FOCUS_POINTER_CANCEL_ON_CLICK)
            ||  (_focusType == BENTO_FOCUS_POINTER_DESTROY_ON_CLICK))
            {
                return _focusTop;
            }
        }
        
        return __rootElement;
    }
    
    static __CheckUnblocked = function()
    {
        if (__animAnyBlocking)
        {
            __animAnyBlocking = false;
            
            if (is_callable(__animUnblockedCallback))
            {
                __animUnblockedCallback(__name, __animUnblockedMetadata);
                
                //Reset values, including the metadata in case that should be GC'd
                if (not __animUnblockedPersist)
                {
                    __animUnblockedCallback = undefined;
                    __animUnblockedMetadata = undefined;
                    __animUnblockedPersist  = false;
                }
            }
        }
    }
}