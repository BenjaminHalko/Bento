// Feather disable all

/// @param layer
/// @param playerIndex

function __BentoClassPlayer(_layer, _playerIndex) constructor
{
    static _system = __BentoSystem();
    
    __layer = _layer;
    __playerIndex = _playerIndex;
    __active = false;
    
    //Set starting input mode from the environment
    __inputMode = _layer.__environment.__envInputMode[_playerIndex];
    __changedMode = false;
    
    //Explicitly using a mouse or touch input
    __inputModePointer = ((__inputMode == BENTO_MODE_MOUSE) || (__inputMode == BENTO_MODE_TOUCH));
    
    //Explicitly using a keyboard or gamepad
    __inputModeNavigation = ((__inputMode == BENTO_MODE_KEYBOARD) || (__inputMode == BENTO_MODE_GAMEPAD));
    
    ////////
    // Input state
    ////////
    
    __pointerX            = 0;
    __pointerY            = 0;
    __pointerPrimaryState = __BENTO_STATE_OFF;
    __pointerPrevX        = 0;
    __pointerPrevY        = 0;
    __pointerPressX       = 0;
    __pointerPressY       = 0;
    
    __pointerTravelled = false;
    
    __navigationDX           = 0;
    __navigationDY           = 0;
    __navigationPrimaryState = __BENTO_STATE_OFF;
    __navigationLastX        = 0;
    __navigationLastY        = 0;
    
    __cursorLastL = 0;
    __cursorLastT = 0;
    __cursorLastR = 0;
    __cursorLastB = 0;
    
    __turboState = new __BentoClassTurbo();
    
    __hotkeyStateMap    = ds_map_create();
    __hotkeyConsumedMap = ds_map_create();
    
    ////////
    // Hover & hold state
    ////////
    
    __hoverElement       = BENTO_NO_ELEMENT;
    __hoverElementSoft   = BENTO_NO_ELEMENT;
    __hoverElementStored = undefined;
    __primaryState       = __BENTO_STATE_OFF;
    __primaryConsumed    = false;
    __holdElement        = BENTO_NO_ELEMENT;
    
    
    
    
    
    static __ClearHoverElement = function()
    {
        __hoverElement = BENTO_NO_ELEMENT;
        
        //So long as we have a drag & drop element, set its target
        var _carryItemElement = __layer.__carryItemElement;
        if ((__playerIndex == __layer.__carryPlayerIndex) && BentoExists(_carryItemElement))
        {
            _carryItemElement.BENTO_VARS.__carryTargetElement = BENTO_NO_ELEMENT;
        }
    }
    
    static __SetBackgroundedState = function()
    {
        __pointerX = -__BENTO_VERY_LARGE;
        __pointerY = -__BENTO_VERY_LARGE;
        
        __navigationDX = 0;
        __navigationDY = 0;
        
        __pointerTravelled = false;
        
        if (BentoExists(__hoverElement))
        {
            __hoverElementStored = weak_ref_create(__hoverElement);
            
            var _backgroundHover = __hoverElement.BENTO_VARS.__backgroundHover;
            if ((_backgroundHover == BENTO_MAINTAIN_NEVER)
            ||  (_backgroundHover == BENTO_MAINTAIN_POINTER) && (not __inputModePointer)
            ||  (_backgroundHover == BENTO_MAINTAIN_NAVIGATION) && (not __inputModeNavigation)) 
            {
                __ClearHoverElement();
            }
        }
        else
        {
            __hoverElementStored = BENTO_NO_ELEMENT;
        }
        
        __holdElement = BENTO_NO_ELEMENT;
    }
    
    static __SetForegroundedState = function()
    {
        if ((__hoverElementStored != undefined) && weak_ref_alive(__hoverElementStored) && BentoExists(__hoverElementStored.ref))
        {
            __BentoSetHover(__hoverElementStored.ref, false);
        }
        
        __hoverElementStored = undefined;
    }
    
    static __UpdateInputMode = function(_newMode)
    {
        __changedMode = (__inputMode != _newMode);
        if (not __changedMode) return;
        
        //Changing input mode may change whether elements execute their step event and are hoverable
        //when focused
        __layer.__dirtyFlags |= __BENTO_DIRTY_STEP | __BENTO_DIRTY_HOVERABLE;
        
        if ((_newMode == BENTO_MODE_KEYBOARD) || (_newMode == BENTO_MODE_GAMEPAD))
        {
            if (__inputModePointer)
            {
                //Reset mouse variables if we've swapped mouse <-> touch
                __navigationLastX = __pointerX;
                __navigationLastY = __pointerY;
                
                __pointerPrevX = __pointerX;
                __pointerPrevY = __pointerY;
            }
            
            __inputModePointer     = false;
            __inputModeNavigation = true;
        }
        else if ((_newMode == BENTO_MODE_MOUSE) || (_newMode == BENTO_MODE_TOUCH))
        {
            __inputModePointer     = true;
            __inputModeNavigation = false;
            
            __pointerPressX = __pointerX;
            __pointerPressY = __pointerY;
            
            __navigationDX = 0;
            __navigationDY = 0;
            
            __turboState.__Update(0, 0, _system.__frame);
        }
        else
        {
            //Some undefined input mode, perhaps `BENTO_MODE_UNKNOWN`
            __inputModePointer     = false;
            __inputModeNavigation = false;
        }
        
        __pointerTravelled = false;
        
        __primaryConsumed = false;
        __holdElement = BENTO_NO_ELEMENT;
        __primaryState = __BENTO_STATE_OFF;
        __pointerPrimaryState = __BENTO_STATE_OFF;
        __navigationPrimaryState = __BENTO_STATE_OFF;
        __inputMode = _newMode;
    }
    
    static __UpdateInputStateAsTopLevel = function()
    {
        //A full input state update. Player input is collected and passed into layer state
        
        var _layer       = __layer;
        var _environment = _layer.__environment;
        var _playerIndex = __playerIndex;
        
        if (__inputModePointer)
        {
            var _pointerX = _environment.__envMouseX[_playerIndex];
            var _pointerY = _environment.__envMouseY[_playerIndex];
            
            var _prevPrimaryState = __pointerPrimaryState;
            var _envPrimaryState = _environment.__envMouseState[_playerIndex];
            
            if (__primaryConsumed)
            {
                if (_envPrimaryState == __BENTO_STATE_START)
                {
                    __primaryConsumed = false;
                }
                else
                {
                    _envPrimaryState = __BENTO_STATE_OFF;
                }
            }
            
            if ((_prevPrimaryState == __BENTO_STATE_END) && (_envPrimaryState & __BENTO_STATE_START))
            {
                //Catch situations where we think we've released but the environment thinks we're held
                __pointerPrimaryState = __BENTO_STATE_START;
            }
            else if ((_prevPrimaryState == __BENTO_STATE_OFF) && (_envPrimaryState == __BENTO_STATE_START))
            {
                //Only allow us to start pressing when the environment is pressed
                __pointerPrimaryState = __BENTO_STATE_START;
            }
            else if (_prevPrimaryState & __BENTO_STATE_START) && (_envPrimaryState & __BENTO_STATE_START)
            {
                //Sustain primary hold
                __pointerPrimaryState = __BENTO_STATE_ON;
            }
            else
            {
                //Release primary
                __pointerPrimaryState = _prevPrimaryState >> 1;
            }
            
            if (__pointerPrimaryState == __BENTO_STATE_START)
            {
                //Set some variable state if we've clicked the mouse
                __pointerPressX = _pointerX;
                __pointerPressY = _pointerY;
                
                __pointerPrevX = _pointerX;
                __pointerPrevY = _pointerY;
            }
            else
            {
                __pointerPrevX = __pointerX;
                __pointerPrevY = __pointerY;
            }
            
            if ((__inputMode == BENTO_MODE_TOUCH) && (not (__pointerPrimaryState & __BENTO_STATE_START)))
            {
                __pointerX = -__BENTO_VERY_LARGE;
                __pointerY = -__BENTO_VERY_LARGE;
            }
            else
            {
                __pointerX = _pointerX;
                __pointerY = _pointerY;
                
                //Update mouse drag information
                if (__pointerPrimaryState & __BENTO_STATE_START)
                {
                    if (point_distance(__pointerPressX, __pointerPressY, __pointerX, __pointerY) > BENTO_POINTER_DRAG_THRESHOLD)
                    {
                        __pointerTravelled = true;
                    }
                }
            }
        }
        else
        {
            __pointerPrimaryState = __pointerPrimaryState >> 1;
        }
        
        if (__inputModeNavigation)
        {
            var _prevPrimaryState = __navigationPrimaryState;
            var _envPrimaryState = _environment.__envNavigationState[_playerIndex];
            
            if (__primaryConsumed)
            {
                if (_envPrimaryState == __BENTO_STATE_START)
                {
                    __primaryConsumed = false;
                }
                else
                {
                    _envPrimaryState = __BENTO_STATE_OFF;
                }
            }
            
            if ((_prevPrimaryState == __BENTO_STATE_END) && (_envPrimaryState & __BENTO_STATE_START))
            {
                //Catch situations where we think we've released but the environment thinks we've held
                __navigationPrimaryState = __BENTO_STATE_START;
            }
            else if ((_prevPrimaryState == __BENTO_STATE_OFF) && (_envPrimaryState == __BENTO_STATE_START))
            {
                //Only allow us to start pressing when the environment is pressed
                __navigationPrimaryState = __BENTO_STATE_START;
            }
            else if (_prevPrimaryState & __BENTO_STATE_START) && (_envPrimaryState & __BENTO_STATE_START)
            {
                //Sustain primary hold
                __navigationPrimaryState = __BENTO_STATE_ON;
            }
            else
            {
                //Release primary
                __navigationPrimaryState = _prevPrimaryState >> 1;
            }
            
            //Update navigation input
            __navigationDX = _environment.__envNavigationDX[_playerIndex];
            __navigationDY = _environment.__envNavigationDY[_playerIndex];
            
            __turboState.__Update(__navigationDX, __navigationDY, _system.__frame);
        }
        else
        {
            __navigationPrimaryState = __navigationPrimaryState >> 1;
        }
        
        //Update hotkey input
        var _globalHotkeyInputMap = _environment.__envHotkeyInputMap[_playerIndex];
        var _key = ds_map_find_first(_globalHotkeyInputMap);
        repeat(ds_map_size(_globalHotkeyInputMap))
        {
            var _state = (__hotkeyStateMap[? _key] ?? __BENTO_STATE_OFF) >> 1;
            if (_globalHotkeyInputMap[? _key] ?? false) _state |= __BENTO_STATE_START;
            __hotkeyStateMap[? _key] = _state;
            
            if (_state == __BENTO_STATE_START)
            {
                __hotkeyConsumedMap[? _key] = false;
            }
            
            _key = ds_map_find_next(_globalHotkeyInputMap, _key);
        }
    }
    
    static __UpdateInputStateAsBackgrounded = function()
    {
        //A partial update of input state. This artificially forces all player inputs to "off" or "null"
        //in some sense.
        
        var _environment = __layer.__environment;
        
        __pointerPrimaryState = __pointerPrimaryState >> 1;
        __navigationPrimaryState = __navigationPrimaryState >> 1;
        
        __turboState.__Update(0, 0, _system.__frame);
        
        //Update hotkey input
        var _globalHotkeyInputMap = _environment.__envHotkeyInputMap[__playerIndex];
        var _key = ds_map_find_first(_globalHotkeyInputMap);
        repeat(ds_map_size(_globalHotkeyInputMap))
        {
            __hotkeyStateMap[? _key] = (__hotkeyStateMap[? _key] ?? __BENTO_STATE_OFF) >> 1;
            _key = ds_map_find_next(_globalHotkeyInputMap, _key);
        }
    }
    
    static __UpdatePrimaryState = function()
    {
        if (__inputModePointer)
        {
            //Update the primary button state based on mouse input
            __primaryState = __pointerPrimaryState;
        }
        else if (__inputModeNavigation)
        {
            //Update the primary button state based on navigation input
            __primaryState = __navigationPrimaryState;
        }
        else
        {
            __primaryState = __primaryState << 1;
        }
    }
    
    static __UpdateHover = function()
    {
        var _layer       = __layer;
        var _environment = _layer.__environment;
        
        if (__inputModePointer)
        {
            if ((__playerIndex == _layer.__pointerScrollPlayerIndex) && (__pointerPrimaryState & __BENTO_STATE_START) && BentoExists(_layer.__pointerScrollingElement))
            {
                //Handle scrolling as a priority. This will block out hovering new elements
                BentoScrollAddPos(__pointerX - __pointerPrevX, __pointerY - __pointerPrevY, infinity, _layer.__pointerScrollingElement);
            }
            else
            {
                //Verify that the currently held element is still held
                if (not __BentoGetHoverableInternal(__holdElement, false, __playerIndex))
                {
                    if (__holdElement != BENTO_NO_ELEMENT)
                    {
                        __holdElement = BENTO_NO_ELEMENT;
                    }
                }
                
                if ((not (__pointerPrimaryState & __BENTO_STATE_START)) //Hover if the primary isn't held
                ||  ((__playerIndex == _layer.__carryPlayerIndex) && (_layer.__carryItemElement != BENTO_NO_ELEMENT)) //Hover if we have a drag & drop item
                ||  (__inputMode == BENTO_MODE_TOUCH)) //Always hover if we're in touch mode
                {
                    __BentoSetHoverFromPointer(__pointerX, __pointerY);
                }
                
                //Now handle primary press
                if (__pointerPrimaryState == __BENTO_STATE_START)
                {
                    if (_environment.__textHandler != undefined) //Detect clicking off of an input box
                    {
                        if ((_environment.__textElement != __hoverElement)
                        &&  (not BentoIsAncestor(_environment.__textElement, __hoverElement))
                        &&  _environment.__textHandler.__cancelOnClick)
                        {
                            _environment.__textHandler.__Terminate(BENTO_TEXT_ABORT);
                            __ClearHoverElement();
                        }
                    }
                    else if (BentoExists(_layer.__focusTop)) //Detect clicking off of a pop-up
                    {
                        var _focusTop = _layer.__focusTop;
                        if ((_focusTop != __hoverElement) //Don't destroy a pop-up if we're hovering directly over it
                        &&  (not BentoIsAncestor(_focusTop, __hoverElement))) //Also don't destroy if we're hovering over a child of the pop-up
                        {
                            var _focusType = _focusTop.BENTO_VARS.__focusType;
                            if (_focusType == BENTO_FOCUS_POINTER_CANCEL_ON_CLICK)
                            {
                                BentoFocusClose(_focusTop);
                                __ClearHoverElement();
                            }
                            else if (_focusType == BENTO_FOCUS_POINTER_DESTROY_ON_CLICK)
                            {
                                BentoDestroy(_focusTop);
                                __ClearHoverElement();
                            }
                        }
                    }
                }
                
                //Handle scrolling when the pointer is near the edge of a scrolling element
                if ((__playerIndex == _layer.__carryPlayerIndex) && (_layer.__carryItemElement != BENTO_NO_ELEMENT))
                {
                    var _pointerScrollingElement = __BentoFindScrollElement(__hoverElement);
                    if (_pointerScrollingElement != BENTO_NO_ELEMENT)
                    {
                        var _hotspotWidth  = min(60, _pointerScrollingElement.bentoWidth/2); //TODO - Make this a macro
                        var _hotspotHeight = min(60, _pointerScrollingElement.bentoHeight/2);
                        
                        var _dX = 0;
                        
                        if ((__pointerX > _pointerScrollingElement.bentoLeft) && (__pointerX <= _pointerScrollingElement.bentoLeft + _hotspotWidth))
                        {
                            var _dX = 4; //TODO - Make this a macro
                        }
                        else if ((__pointerX >= _pointerScrollingElement.bentoRight - _hotspotWidth) && (__pointerX < _pointerScrollingElement.bentoRight))
                        {
                            var _dX = -4;
                        }
                        else
                        {
                            var _dX = 0;
                        }
                        
                        if ((__pointerY > _pointerScrollingElement.bentoTop) && (__pointerY <= _pointerScrollingElement.bentoTop + _hotspotHeight))
                        {
                            var _dY = 4; //TODO - Make this a macro
                        }
                        else if ((__pointerY >= _pointerScrollingElement.bentoBottom - _hotspotHeight) && (__pointerY < _pointerScrollingElement.bentoBottom))
                        {
                            var _dY = -4;
                        }
                        else
                        {
                            var _dY = 0;
                        }
                        
                        BentoScrollAddPos(_dX, _dY, infinity, _pointerScrollingElement);
                    }
                }
            }
            
            if (__pointerPrimaryState == __BENTO_STATE_END)
            {
                //Reset the travelled state
                __pointerTravelled = false;
            }
        }
        else if (__inputModeNavigation)
        {
            //If the held element cannot be held then proactively reset the state variable
            if (not __BentoGetHoverableInternal(__holdElement, false, __playerIndex)) __holdElement = BENTO_NO_ELEMENT;
            
            //Move the cursor and hover a new element (maybe)
            __BentoSetHoverFromNavigation(__hoverElement, __turboState.__outputX, __turboState.__outputY);
        }
        else //Some other input mode, perhaps `BENTO_MODE_UNKNOWN`
        {
            __holdElement = BENTO_NO_ELEMENT;
            __BentoSetHover(BENTO_NO_ELEMENT, false);
        }
    }
}