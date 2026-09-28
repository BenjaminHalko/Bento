// Feather disable all

/// @desc Step

//If Bento thinks this button has been clicked then trigger the callback function
var _playerIndex = 0;
repeat(BENTO_MAX_PLAYERS)
{
    if (BentoPrimaryGetClick(self, _playerIndex) || (BentoGetHoverable(self, true, _playerIndex) && BentoHotkeyGetPress(BENTO_HOTKEY_CANCEL, false, undefined, _playerIndex))) break;
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

if (BentoCursorGetEnterByPlayer() && BentoUsingNavigation())
{
    audio_play_sound(sndBentoExBlip, 0, false);
}