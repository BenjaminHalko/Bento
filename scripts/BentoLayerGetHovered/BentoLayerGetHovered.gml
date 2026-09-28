// Feather disable all

/// @param [layerOrName]
/// @param [environmentOrName]
/// @param [playerIndex=0]

function BentoLayerGetHovered(_layerName = undefined, _environmentName = undefined, _playerIndex = 0)
{
    with(__BentoLayerSeek(_layerName, _environmentName))
    {
        return __playerArray[_playerIndex].__hoverElement;
    }
    
    return BENTO_NO_ELEMENT;
}