// Feather disable all

/// if (BentoUsingNavigation() && BentoHotkeyGetPress("pick up"))
/// {
///     if (BentoCarryIsItem())
///     {
///         BentoCarryItemPick();
///     }
///     else
///     {
///         BentoCarryItemDrop();
///     }
/// }
/// 
/// N.B. To avoid problems with order of execution, the drag & drop system is updated at the start
///      of an update loop. That means the effects of this function will not be applied until the
///      Step after this function is called.
/// 
/// @param [element=self]
/// @param [playerIndex=0]

function BentoCarryItemPick(_element = self, _playerIndex = 0)
{
    with(__BentoGetVars(_element))
    {
        if (__carryItemChannel != undefined)
        {
            __layer.__carryNextItemElement = _element;
            __layer.__carryNextPlayerIndex = _playerIndex;
            __carryItemContinuous = false;
        }
        else
        {
            if (BENTO_SAFE && BENTO_RUNNING_FROM_IDE)
            {
                __BentoError("Cannot pick drag & drop item, its channel is `undefined`\nPlease call `BentoCarrySetItemChannel()`");
            }
        }
    }
}