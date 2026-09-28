// Feather disable all

/// Restricts an element, and every element inside it, to the given players. `players` should be
/// an array of player indices, or `undefined` to allow every player (the default). Other players
/// cannot hover the element and their pointers pass through it.
/// 
/// @param players
/// @param [element=self]

function BentoSetPlayers(_players, _element = self)
{
    with(__BentoGetVars(_element))
    {
        __players = _players;
    }
}