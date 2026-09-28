// Feather disable all

/// Must be called in the scope of `__BentoClassLayer`.

function __BentoUpdateActiveElement(_elementVars)
{
    with(_elementVars)
    {
        var _element = __attachedElement;
        if (not BentoExists(_element)) return false;
        
        ///////
        // Drag & drop
        ///////
            
        __carryItemState = __carryItemState >> 1;
            
        var _isLayerItemElement = (other.__carryItemElement != BENTO_NO_ELEMENT) && (other.__carryItemElement.BENTO_VARS == self);
        if (_isLayerItemElement)
        {
            __carryItemState = __carryItemState | __BENTO_STATE_START;
        }
        else if (__carryItemState == __BENTO_STATE_OFF)
        {
            __carryTargetElement = BENTO_NO_ELEMENT;
        }
        
        var _anyPrimary = false;
        var _anyHover   = false;
        
        var _playerArray = other.__playerArray;
        var _c = 0;
        repeat(BENTO_MAX_PLAYERS)
        {
            var _player = _playerArray[_c];
            var _clickable = (_player.__inputModePointer && (__buttonIndexPointer == other.__hoverableRegenCount))
                          || (_player.__inputModeNavigation && (__buttonIndexNavigation == other.__hoverableRegenCount));
            var _isPlayerItemElement = (_c == other.__carryPlayerIndex) && _isLayerItemElement;
            
            if (_player.__inputModeNavigation)
            {
                if (__clickTiming != undefined)
                {
                    var _clickOnPress = (__clickTiming == BENTO_CLICK_ON_PRESS);
                }
                else
                {
                    var _clickOnPress = true;
                }
            }
            else if (BentoExists(__BentoFindScrollElement(_element))
                    || (__carryItemChannel != undefined)
                    || __longPressEnabled)
            {
                var _clickOnPress = false;
            }
            else
            {
                if (__clickTiming != undefined)
                {
                    var _clickOnPress = (__clickTiming == BENTO_CLICK_ON_PRESS);
                }
                else
                {
                    var _clickOnPress = (_player.__inputModePointer && (BENTO_POINTER_CLICK_ON_PRESS || (_player.__inputMode == BENTO_MODE_TOUCH)));
                }
            }
            
            __clickState[_c] = 0b00;
            
            ///////
            // Hover state
            ///////
            
            //Advance our hover state
            var _hoverState = __hoverState[_c] >> 1;
            
            if ((_player.__hoverElement != BENTO_NO_ELEMENT) && (_player.__hoverElement.BENTO_VARS == self))
            {
                _hoverState |= __BENTO_STATE_START;
            }
            
            __hoverState[_c] = _hoverState;
            
            if (_hoverState != __BENTO_STATE_START)
            {
                //Reset the "by player" state
                __byPlayer[_c] = false;
            }
            
            ///////
            // Hold state
            ///////
            
            var _primaryState     = __primaryState[_c];
            var _primaryLongState = __primaryLongState[_c];
            
            if (_player.__primaryState == __BENTO_STATE_START)
            {
                //System says the player has clicked
                
                if (((_hoverState & __BENTO_STATE_START) || _isPlayerItemElement)
                &&  (not (_primaryState & __BENTO_STATE_START)))
                {
                    _primaryState = __BENTO_STATE_START;
                    __pressTime[_c] = current_time;
                    
                    if (not _isPlayerItemElement)
                    {
                        _player.__holdElement = _element; 
                        
                        //Pass through a click signal to the element if we're clicking on press
                        if (_clickOnPress && _clickable) __clickState[_c] = 0b01;
                    }
                }
            }
            else
            {
                //Advance our state
                _primaryState     = _primaryState >> 1;
                _primaryLongState = _primaryLongState >> 1;
                
                //Compare hold element to ourselves using a BENTO_VARS check - this is because GameMaker sometimes
                //gets confused with comparing instance references. It appears that comparisons between `id` and
                //`self` will occasionally return false positives. However, comparing the `BENTO_VARS` structs is
                //stable and returns accurate information.
                var _isLayerHoldElement = (_player.__holdElement != BENTO_NO_ELEMENT) && (_player.__holdElement.BENTO_VARS == self);
                if ((_player.__primaryState == __BENTO_STATE_ON) && (_isLayerHoldElement || _isPlayerItemElement))
                {
                    //Primary button is still down, we're still held
                    _primaryState |= __BENTO_STATE_START;
                    
                    //Trigger a long click
                    if (__longPressEnabled && (current_time - __pressTime[_c] >= BENTO_LONG_CLICK_TIME))
                    {
                        _primaryLongState |= __BENTO_STATE_START;
                    }
                }
                else
                {
                    //Primary button is released or off, or the hold element changed away from us unexpectedly.
                    
                    if (_isLayerHoldElement)
                    {
                        //Unset the system's hold element since that's us
                        _player.__holdElement = BENTO_NO_ELEMENT;
                        
                        //Pass through a click signal to the element if we're clicking on release
                        if ((not _clickOnPress) && _clickable
                        &&  (not _isPlayerItemElement)
                        &&  (_primaryState == __BENTO_STATE_END)
                        &&  (_player.__primaryState == __BENTO_STATE_END)
                        &&  ((_c != other.__pointerScrollPlayerIndex) || (not other.__pointerScrolled)))
                        {
                            if (_player.__inputMode == BENTO_MODE_TOUCH)
                            {
                                //Because we set the mouse x/y position to large negative numbers before running this function, the
                                //hover state for the held element will always be in the leaving (END) state.
                                if (_hoverState == __BENTO_STATE_END)
                                {
                                    __clickState[_c] = (_primaryLongState > 0)? 0b10 : 0b01;
                                }
                            }
                            else
                            {
                                //Only click if we're hovered.
                                if (_hoverState & __BENTO_STATE_START)
                                {
                                    __clickState[_c] = (_primaryLongState > 0)? 0b10 : 0b01;
                                }
                            }
                        }
                    }
                }
            }
            
            __primaryState[_c]     = _primaryState;
            __primaryLongState[_c] = _primaryLongState;
            
            ///////
            // Scrolling
            ///////
            
            //Scrolling when in navigation input mode is handled when an element is hovered
            
            if (_player.__inputModePointer && (_hoverState & __BENTO_STATE_START))
            {
                if (((not other.__pointerScrolled) || (_c == other.__pointerScrollPlayerIndex)) && _player.__pointerTravelled
                &&  ((BENTO_SCROLL_ON_MOUSE_DRAG || (_player.__inputMode == BENTO_MODE_TOUCH)) && (_primaryState == __BENTO_STATE_ON)))
                {
                    //Click & drag
                    
                    var _pressX = _player.__pointerPressX;
                    var _pressY = _player.__pointerPressY;
                    
                    if ((not __holdBlocksDragScroll) && (__carryItemState == __BENTO_STATE_OFF))
                    {
                        var _overScrollbar = false;
                        
                        with(__scrollbarVert)
                        {
                            if (point_in_rectangle(_pressX, _pressY, barLeft, barTop, barRight, barBottom))
                            {
                                _overScrollbar = true;
                            }
                        }
                        
                        with(__scrollbarHori)
                        {
                            if (point_in_rectangle(_pressX, _pressY, barLeft, barTop, barRight, barBottom))
                            {
                                _overScrollbar = true;
                            }
                        }
                        
                        if (not _overScrollbar)
                        {
                            var _parent = __BentoFindScrollElement(_element);
                            if (BentoExists(_parent))
                            {
                                //Start scrolling the parent
                                other.__pointerScrolled = true;
                                other.__pointerScrollingElement = _parent;
                                other.__pointerScrollPlayerIndex = _c;
                                
                                //Unhover and unhold us. This makes it clear that the player is no longer interacting
                                //with us and instead is interacting with the scrolling parent
                                _player.__holdElement = BENTO_NO_ELEMENT;
                                _player.__ClearHoverElement();
                            }
                        }
                    }
                }
                else
                {
                    //Allow the mouse wheel to scroll when hovering over a container or its children
                    
                    var _dX = 0;
                    var _dY = 0;
                    
                    //Mouse wheel input can be pretty noisy so we filter out as much as possible
                    
                    if (BentoHotkeyGetPress(BENTO_HOTKEY_SCROLL_UP, false, other, _c) || BentoHotkeyGetHold(BENTO_HOTKEY_SCROLL_UP, false, other, _c))
                    {
                        _dX -= BENTO_MOUSE_WHEEL_SCROLL_SPEED;
                        _dY += BENTO_MOUSE_WHEEL_SCROLL_SPEED;
                    }
                    
                    if (BentoHotkeyGetPress(BENTO_HOTKEY_SCROLL_DOWN, false, other, _c) || BentoHotkeyGetHold(BENTO_HOTKEY_SCROLL_DOWN, false, other, _c))
                    {
                        _dX += BENTO_MOUSE_WHEEL_SCROLL_SPEED;
                        _dY -= BENTO_MOUSE_WHEEL_SCROLL_SPEED;
                    }
                    
                    if ((_dX != 0) || (_dY != 0))
                    {
                        BentoScrollAddPos(_dX, _dY, BENTO_DEFAULT_SCROLL_SPEED, _element);
                    }
                }
            }
            
            if ((_primaryState != __BENTO_STATE_OFF) || (_primaryLongState != __BENTO_STATE_OFF))
            {
                _anyPrimary = true;
            }
            
            if (_hoverState != __BENTO_STATE_OFF)
            {
                _anyHover = true;
                
                if ((__backgroundHover == BENTO_MAINTAIN_NEVER)
                ||  (__backgroundHover == BENTO_MAINTAIN_POINTER) && (not _player.__inputModePointer)
                ||  (__backgroundHover == BENTO_MAINTAIN_NAVIGATION) && (not _player.__inputModeNavigation)) 
                {
                    //If we're *not* maintaining background hover then elements lose the opportunity
                    //to catch the "hover end" (leave) state unless we run Step events
                    other.__runStep = true;
                }
            }
            
            ++_c;
        }
        
        //Remove this element from the update loop if it's inactive
        if (_anyPrimary
        ||  (__carryItemState != __BENTO_STATE_OFF)
        ||  (__carryTargetElement != BENTO_NO_ELEMENT))
        {
            //We're updating states that are "dangerous" so we must run Step events
            other.__runStep = true;
            
            //Keep us in the array
            return true;
        }
        else if (_anyHover)
        {
            //Keep us in the array
            return true;
        }
        else // if (__hoverState == __BENTO_STATE_OFF)
        {
            //Nothing interesting is happening! Remove us from the array
            __updating = false;
            return false;
        }
    }
    
    return false;
}