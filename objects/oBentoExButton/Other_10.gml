// Feather disable all

/// @desc Step

//If Bento thinks this button has been clicked then trigger the callback function
var _playerIndex = 0;
repeat(BENTO_MAX_PLAYERS)
{
    if (BentoPrimaryGetClick(self, _playerIndex)) break;
    ++_playerIndex;
}

if (_playerIndex < BENTO_MAX_PLAYERS)
{
    audio_play_sound(sndBentoExBeep, 0, false);
    
    if (is_callable(func))
    {
        func(_playerIndex);
    }
}
else if (BentoHotkeyGetHold(hotkey))
{
    audio_play_sound(sndBentoExBeep, 0, false);
    
    if (is_callable(func))
    {
        func();
    }
}

if (BentoCursorGetEnterByPlayer() && BentoUsingNavigation())
{
    audio_play_sound(sndBentoExBlip, 0, false);
}