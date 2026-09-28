// Feather disable all

/// Returns whether the primary action has been activated and held on the element.
/// 
/// @param [element=self]
/// @param [playerIndex=0]

function BentoPrimaryGetLongHold(_element = self, _playerIndex = 0)
{
    return BentoExists(_element)? ((_element.BENTO_VARS.__primaryLongState[_playerIndex] & __BENTO_STATE_START) > 0) : false;
}