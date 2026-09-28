// Feather disable all

/// Sets input values for pointer input (mouse and/or touch). The `primaryAction` argument should
/// be set to the current held state of the primary "accept" or "confirm" button, conventionally
/// the left mouse button (e.g. `device_mouse_check_button(0, mb_left)`).
/// 
/// @param x
/// @param y
/// @param primaryAction
/// @param [playerIndex=0]

function BentoInputPointer(_x, _y, _primaryAction, _playerIndex = 0)
{
    static _system = __BentoSystem();
    with(_system.__environmentCurrent)
    {
        __envMouseX[_playerIndex]    = _x / _system.__globalScale;
        __envMouseY[_playerIndex]    = _y / _system.__globalScale;
        __envMouseHold[_playerIndex] = _primaryAction;
        __envPlayerActive[_playerIndex] = true;
    }
}