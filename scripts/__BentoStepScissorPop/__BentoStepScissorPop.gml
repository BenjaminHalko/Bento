// Feather disable all

/// Pops an entry off of the draw event scissor stack. This will set GPU state.

function __BentoStepScissorPop()
{
    static _scissorStack = __BentoSystem().__scissorStack;
    
    var _playerArray = __layer.__playerArray;
    var _i = 0;
    repeat(BENTO_MAX_PLAYERS)
    {
        var _hoverElement = _playerArray[_i].__hoverElement;
        if (BentoExists(_hoverElement))
        {
            var _hoverElementVars = _hoverElement.BENTO_VARS;
            if (_hoverElementVars.__scissorParent == self)
            {
                var _j = 0;
                repeat(_i)
                {
                    if (_playerArray[_j].__hoverElement == _hoverElement) break;
                    ++_j;
                }
                
                if (_j == _i)
                {
                    _hoverElementVars.__eventDrawHover();
                }
            }
        }
        
        ++_i;
    }
    
    array_pop(_scissorStack);
}