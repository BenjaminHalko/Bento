// Feather disable all

/// Returns if the pointer has moved far enough whilst being held to be considered a drag. The
/// drag distance threshold is defined by `BENTO_POINTER_DRAG_THRESHOLD`. If the input mode isn't
/// `BENTO_MODE_MOUSE` or `BENTO_MODE_TOUCH` this function always returns `false`.
/// 
/// @param [layerOrName=current]
/// @param [playerIndex=0]

function BentoPrimaryGetDragged(_layerOrName = undefined, _playerIndex = 0)
{
    with(__BentoLayerSeek(_layerOrName))
    {
        return __playerArray[_playerIndex].__pointerTravelled;
    }
    
    return false;
}