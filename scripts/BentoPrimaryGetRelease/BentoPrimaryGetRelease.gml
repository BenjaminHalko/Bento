// Feather disable all

/// Returns whether the primary action has released (newly un-held) the element.
/// 
/// N.B. This is NOT the same as clicking an element as an element may be released for many
///      reasons other than user intent. To check whether an element has been clicked, please use
///      `BentoPrimaryGetClick()`.
/// 
/// @param [element]
/// @param [playerIndex=0]

function BentoPrimaryGetRelease(_element = self, _playerIndex = 0)
{
    if (not BentoExists(_element)) return false;
    return (_element.BENTO_VARS.__primaryState[_playerIndex] == __BENTO_STATE_END);
}