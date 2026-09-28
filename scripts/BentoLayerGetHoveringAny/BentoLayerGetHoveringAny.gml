// Feather disable all

/// @param [layerOrName]
/// @param [environmentOrName]
/// @param [playerIndex=0]

function BentoLayerGetHoveringAny(_layerName = undefined, _environmentName = undefined, _playerIndex = 0)
{
    return BentoExists(BentoLayerGetHovered(_layerName, _environmentName, _playerIndex));
}