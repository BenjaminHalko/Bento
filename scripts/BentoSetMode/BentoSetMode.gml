// Feather disable all

/// Sets one player's input mode for an environment. This should be one of the following constants:
/// 
/// - `BENTO_MODE_UNKNOWN`
/// - `BENTO_MODE_MOUSE`
/// - `BENTO_MODE_KEYBOARD`
/// - `BENTO_MODE_GAMEPAD`
/// - `BENTO_MODE_TOUCH`
/// 
/// The mouse and touch input modes are considered "pointer" input modes. The keyboard and gamepad
/// input modes are considered "navigation" input modes.
/// 
/// @param mode
/// @param [environmentName=current]
/// @param [playerIndex=0]

function BentoSetMode(_newMode, _environmentOrName = undefined, _playerIndex = 0)
{
    var _environment = __BentoEnvironmentSeek(_environmentOrName);
    if (_environment == undefined)
    {
        if (is_struct(_environmentOrName))
        {
            __BentoError("Could not find environment (datatype=struct)");
        }
        else if (is_array(_environmentOrName))
        {
            __BentoError("Could not find environment (datatype=array)");
        }
        else
        {
            __BentoError($"Could not find environment \"{_environmentOrName}\"");
        }
    }
    
    with(_environment)
    {
        if (_newMode == __envInputMode[_playerIndex]) return;
        
        __envInputMode[_playerIndex] = _newMode;
        
        if (BENTO_DEBUG_LEVEL >= 1)
        {
            __BentoTrace($"Input mode for player {_playerIndex} in environment {__BentoGetStructPointer(self)} set to {__BentoGetInputModeName(_newMode)}");
        }
        
        with(array_last(__layerArray))
        {
            __UpdateInputMode();
        }
    }
}