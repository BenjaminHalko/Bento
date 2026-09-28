// Feather disable all

/// N.B. To avoid problems with order of execution, the drag & drop system is updated at the start
///      of an update loop. That means the effects of this function will not be applied until the
///      Step after this function is called.
/// 
/// @param [element=self]

function BentoCarryItemBehavior(_element = self)
{
    var _layer = BentoGetLayer(_element);
    
    var _playerIndex = 0;
    repeat(BENTO_MAX_PLAYERS)
    {
        if (BentoUsingPointer(undefined, _playerIndex))
        {
            if (BentoPrimaryGetHold(_element, _playerIndex) && BentoPrimaryGetDragged(_layer, _playerIndex))
            {
                BentoCarryItemPickContinuous(_element, _playerIndex);
            }
        }
        else if (BentoUsingNavigation(undefined, _playerIndex))
        {
            if (not BentoCarryIsItem(_element))
            {
                if (BentoPrimaryGetClick(_element, _playerIndex))
                {
                    BentoCarryItemPick(_element, _playerIndex);
                }
            }
            else if (_playerIndex == _layer.__carryPlayerIndex)
            {
                if (BentoPrimaryGetPress(_element, _playerIndex) || BentoHotkeyGetPress(BENTO_HOTKEY_CANCEL, false, _layer, _playerIndex))
                {
                    BentoCarryItemDrop(_element);
                }
            }
        }
        
        ++_playerIndex;
    }
    
    return BentoCarryGetItemDropped()? BentoCarryGetTarget(_element) : BENTO_NO_ELEMENT;
}