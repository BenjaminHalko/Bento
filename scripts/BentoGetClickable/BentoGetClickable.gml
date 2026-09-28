// Feather disable all

/// Returns whether an element is clickable (i.e. `BentoPrimaryGetClick()` can return `true`).
/// 
/// @param [element=self]
/// @param [playerIndex=0]

function BentoGetClickable(_element = self, _playerIndex = 0)
{
    with(__BentoGetVars(_element))
    {
        //Can't click invisible elements
        if (not __visible) return false;
        
        //Can't click anything that's outside a clipping region
        if (__scissorCoverage <= BENTO_MIN_DRAW_COVERAGE) return false;
        
        //Can only click it if the button type matches the input mode
        var _player = __layer.__playerArray[_playerIndex];
        return ((_player.__inputModePointer && (__buttonIndexPointer == __layer.__hoverableRegenCount))
             || (_player.__inputModeNavigation && (__buttonIndexNavigation == __layer.__hoverableRegenCount)));
    }
    
    return false;
}