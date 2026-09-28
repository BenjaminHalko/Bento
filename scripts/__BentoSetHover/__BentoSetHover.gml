// Feather disable all

/// Starts the hover state for an element. This must be called in the scope of a player struct
/// (see `__BentoClassPlayer()`).
/// 
/// @param element
/// @param byPlayer

function __BentoSetHover(_element, _byPlayer)
{
    if (BentoExists(_element))
    {
        __cursorLastL = _element.bentoLeft;
        __cursorLastT = _element.bentoTop;
        __cursorLastR = _element.bentoRight;
        __cursorLastB = _element.bentoBottom;
        
        if (__inputModeNavigation)
        {
            __navigationLastX = 0.5*(__cursorLastL + __cursorLastR);
            __navigationLastY = 0.5*(__cursorLastT + __cursorLastB);
            
            BentoScrollTo(BentoScrollGetSpeed(_element), _element);
        }
        
        __hoverElement = _element;
        
        //So long as we have a drag & drop element, set its target
        var _carryItemElement = __layer.__carryItemElement;
        if ((__playerIndex == __layer.__carryPlayerIndex) && BentoExists(_carryItemElement))
        {
            _carryItemElement.BENTO_VARS.__carryTargetElement = _element;
        }
        
        var _playerIndex = __playerIndex;
        with(_element.BENTO_VARS)
        {
            __BentoSetAsUpdating();
            
            if (_byPlayer)
            {
                __byPlayer[_playerIndex] = true;
            }
        }
    }
    else
    {
        __ClearHoverElement();
    }
    
    __hoverElementSoft = BENTO_NO_ELEMENT;
}