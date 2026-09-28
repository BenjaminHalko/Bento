// Feather disable all

/// Returns whether an element is hoverable (i.e. its "hover" state can be set by Bento).
/// 
/// @param [element=self]
/// @param [checkVisible=true]
/// @param [playerIndex=0]

function BentoGetHoverable(_element = self, _checkVisible = true, _playerIndex = 0)
{
    return __BentoGetHoverableInternal(_element, _checkVisible, _playerIndex);
}

function __BentoGetHoverableInternal(_element, _checkVisible, _playerIndex = 0)
{
    with(__BentoGetVars(_element))
    {
        //Can't hover invisible elements
        if (not __visible) return false;
        
        //Can't hover anything if the layer has any blocking animations
        if (not ds_map_empty(__layer.__animBlockingMap)) return false;
        
        //Can't hover elements that aren't in the most recent hoverable order array
        var _player = __layer.__playerArray[_playerIndex];
        if ((not _player.__inputModePointer) && (not _player.__inputModeNavigation)) return false;
        if ((_player.__inputModeNavigation? __hoverableIndexNavigation : __hoverableIndexPointer) != __layer.__hoverableRegenCount) return false;
        
        //Can't hover elements reserved for other players, see `BentoSetPlayers()`
        var _vars = self;
        while (_vars != undefined)
        {
            if ((_vars.__players != undefined) && (array_get_index(_vars.__players, _playerIndex) < 0)) return false;
            _vars = BentoExists(_vars.__parent)? _vars.__parent.BENTO_VARS : undefined;
        }
        
        //Can't hover anything that's outside a clipping region
        return ((not _checkVisible) || (__scissorCoverage > BENTO_MIN_DRAW_COVERAGE));
    }
    
    return false;
}