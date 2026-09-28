// Feather disable all

/// Returns whether the input mode has been set to `BENTO_MODE_TOUCH`.
/// 
/// @param [environmentName=current]
/// @param [playerIndex=0]

function BentoUsingTouch(_environmentOrName = undefined, _playerIndex = 0)
{
    with(__BentoEnvironmentSeek(_environmentOrName))
    {
        return (__envInputMode[_playerIndex] == BENTO_MODE_TOUCH);
    }
}