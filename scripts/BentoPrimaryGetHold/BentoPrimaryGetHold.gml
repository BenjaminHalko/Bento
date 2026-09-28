// Feather disable all

/// Returns whether the primary action has been activated and held on the element.
/// 
/// @param [element=self]
/// @param [playerIndex=0]

function BentoPrimaryGetHold(_element = self, _playerIndex = 0)
{
    if (not BentoExists(_element)) return false;
    return ((_element.BENTO_VARS.__primaryState[_playerIndex] & __BENTO_STATE_START) > 0);
}