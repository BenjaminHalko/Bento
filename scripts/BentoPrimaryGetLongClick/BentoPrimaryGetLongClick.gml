// Feather disable all

/// @param [element=self]
/// @param [playerIndex=0]

function BentoPrimaryGetLongClick(_element = self, _playerIndex = 0)
{
    with(__BentoGetVars(_element))
    {
        return __layer.__playerArray[_playerIndex].__primaryConsumed? false : (__clickState[_playerIndex] == 0b10);
    }
    
    return false;
}