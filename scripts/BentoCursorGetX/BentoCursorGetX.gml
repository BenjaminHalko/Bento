// Feather disable all

/// Returns the x-coordinate of the cursor's position.
/// 
/// @param [layerOrName=current]
/// @param [playerIndex=0]

function BentoCursorGetX(_layerOrName = undefined, _playerIndex = 0)
{
    with(__BentoLayerSeek(_layerOrName))
    {
        with(__playerArray[_playerIndex])
        {
            if (__inputMode == BENTO_MODE_MOUSE)
            {
                return __pointerX;
            }
            else if (__inputModeNavigation)
            {
                return 0.5*(__cursorLastL + __cursorLastR);
            }
            else if (__inputMode == BENTO_MODE_TOUCH)
            {
                return (__pointerPrimaryState & __BENTO_STATE_START)? __pointerX : __pointerPrevX;
            }
        }
    }
    
    return 0;
}