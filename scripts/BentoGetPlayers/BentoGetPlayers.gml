// Feather disable all

/// Returns the players an element is restricted to, as set by `BentoSetPlayers()`. This will be
/// an array of player indices, or `undefined` if every player can use the element. If the element
/// doesn't exist, this function will return `undefined`.
/// 
/// @param [element=self]

function BentoGetPlayers(_element = self)
{
    return BentoExists(_element)? _element.BENTO_VARS.__players : undefined;
}