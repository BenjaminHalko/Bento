// Feather disable all

/// Returns whether the cursor is hovering the given element.
/// 
/// @param [element=self]
/// @param [playerIndex=0]

function BentoCursorGetHover(_element = self, _playerIndex = 0)
{
    if (not BentoExists(_element)) return false;
    return ((_element.BENTO_VARS.__hoverState[_playerIndex] & __BENTO_STATE_START) > 0);
}