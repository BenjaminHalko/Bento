/// @desc Draw Hover

var _playerIndex = 0;
repeat(BENTO_MAX_PLAYERS)
{
    if (BentoCursorGetHover(self, _playerIndex) && BentoGetClickable(self, _playerIndex))
    {
        BentoDrawSpriteAround(10, sBentoExHighlight, undefined, c_black, BENTO_EXAMPLE_HIGHLIGHT_SHADOW_ALPHA, undefined, BENTO_EXAMPLE_HIGHLIGHT_SHADOW_OFFSET, BENTO_EXAMPLE_HIGHLIGHT_SHADOW_OFFSET);
        BentoDrawSpriteAround(10, sBentoExHighlight, undefined, [BENTO_EXAMPLE_RED, BENTO_EXAMPLE_GREEN, BENTO_EXAMPLE_CYAN, BENTO_EXAMPLE_PINK][_playerIndex]);
    }
    
    ++_playerIndex;
}