// Feather disable all

/// Returns whether the named button is being held based on input via `BentoInputHotkey()`.
/// 
/// @param name
/// @param [ignoreConsume=false]
/// @param [layerOrName=current]
/// @param [playerIndex=0]

function BentoHotkeyGetHold(_name, _ignoreConsume = false, _layerOrName = undefined, _playerIndex = 0)
{
    if (_name == undefined)
    {
        return false;
    }
    
    with(__BentoLayerSeek(_layerOrName))
    {
        with(__playerArray[_playerIndex])
        {
            if ((not _ignoreConsume) && (__hotkeyConsumedMap[? _name] ?? false)) return false;
            return (__hotkeyStateMap[? _name] == __BENTO_STATE_ON);
        }
    }
    
    return false;
}