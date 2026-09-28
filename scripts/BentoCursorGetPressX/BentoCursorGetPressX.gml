// Feather disable all

/// Returns the x-coordinate of where the cursor was when the primary input was last pressed. This
/// function will work in all input modes but, for example, in the mouse input mode this function
/// would return where the cursor was when the mouse was last clicked.
/// 
/// @param [layerOrName=current]
/// @param [playerIndex=0]

function BentoCursorGetPressX(_layerOrName = undefined, _playerIndex = 0)
{
    with(__BentoLayerSeek(_layerOrName))
    {
        with(__playerArray[_playerIndex])
        {
            return __inputModePointer? __pointerPressX : __navigationLastX;
        }
    }
    
    return 0;
}