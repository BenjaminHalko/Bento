// Feather disable all

/// Returns whether the cursor has left (newly un-hovered) the element.
/// 
/// @param [element=self]
/// @param [playerIndex=0]

function BentoCursorGetLeave(_element = self, _playerIndex = 0)
{
    if (not BentoExists(_element)) return false;
    return (_element.BENTO_VARS.__hoverState[_playerIndex] == __BENTO_STATE_END);
}