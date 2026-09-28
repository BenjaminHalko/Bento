// Feather disable all

/// Starts the hold state for an element.
/// 
/// @param element
/// @param [playerIndex=0]

function __BentoStartHold(_element, _playerIndex = 0)
{
    if (BentoExists(_element) && (not BentoPrimaryGetHold(_element, _playerIndex)))
    {
        with(_element.BENTO_VARS)
        {
            __primaryState[_playerIndex] = __BENTO_STATE_START;
            __layer.__playerArray[_playerIndex].__holdElement = _element;
            
            __BentoSetAsUpdating();
        }
    }
}