// Feather disable all

/// "Consumes" all user input, either for one player or for every player on the layer.
/// 
/// @param [layerOrName=current]
/// @param [playerIndex=all]

function BentoInputConsume(_layerOrName = undefined, _playerIndex = undefined)
{
    static _hotkeyArray = [];
    
    with(__BentoLayerSeek(_layerOrName))
    {
        var _map = __environment.__envHotkeySeenMap;
        
        var _i = _playerIndex ?? 0;
        repeat((_playerIndex == undefined)? BENTO_MAX_PLAYERS : 1)
        {
            with(__playerArray[_i])
            {
                __primaryConsumed = true;
                
                var _key = ds_map_find_first(_map);
                repeat(ds_map_size(_map))
                {
                    __hotkeyConsumedMap[? _key] = true;
                    _key = ds_map_find_next(_map, _key);
                }
            }
            
            ++_i;
        }
    }
}