// Feather disable all

/// Preferentially hovers an element if no other element is currently hovered. A soft hover will
/// only last for a frame and can be overwritten by `BentoHover()`. This function further only
/// works when the input mode is set to `BENTO_MODE_KEYBOARD` or `BENTO_MODE_GAMEPAD`. This
/// function will return `true` if the element was successfully soft-hovered and `false` otherwise.
/// 
/// Hovering an element in this way will not count as entering by navigation. This means that
/// `BentoCursorGetEnterByPlayer()` will return `false`.
/// 
/// @param element
/// @param [playerIndex=0]

function BentoHoverSoft(_element, _playerIndex = 0)
{
    if (not BentoExists(_element)) return false;
    
    with(_element.BENTO_VARS.__layer)
    {
        if (__playerArray[_playerIndex].__inputModeNavigation)
        {
            __playerArray[_playerIndex].__hoverElementSoft = _element;
            return true;
        }
    }
    
    return false;
}