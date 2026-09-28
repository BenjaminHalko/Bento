// Feather disable all

function ExamplePlayersSharedScroller()
{
    with(oMain)
    {
        playerCount = 2;
        BentoSetMode(BENTO_MODE_MOUSE,    undefined, 0);
        BentoSetMode(BENTO_MODE_KEYBOARD, undefined, 1);
        
        BentoLayerClear("example layer");
        with(BentoCreateBlank(BentoGetRoot()))
        {
            BentoLayoutSetPadding(40);
            BentoLayoutSetGutter(35, 35);
            BentoLayoutSetResize(BENTO_RESIZE_INFLATE, BENTO_RESIZE_INFLATE);
            BentoLayoutList(BENTO_AXIS_Y, 0.5, 0);
            
            with(BentoCreateBlank())
            {
                BentoLayoutSetGutter(35, 35);
                BentoLayoutSetResize(BENTO_RESIZE_INFLATE, BENTO_RESIZE_DEFLATE);
                BentoLayoutList(BENTO_AXIS_X, 0.5, 0);
                
                BentoCreate(oBentoExText, { font: fntBentoExCandyBeansBig, text: "Two Players, Shared Scroller" });
                BentoCreate(oBentoExBackButton, { func: ExampleHomePage });
            }
            
            BentoCreate(oBentoExText, {
                text: "Both players share one scrolling grid. Player 1 drag-scrolls it with the mouse and player 2 scrolls it by navigating with the keyboard, so the two can fight over the scroll position.",
                font: fntBentoExCandyBeans,
            });
            
            with(BentoCreate(oBentoExScrollingList))
            {
                BentoLayoutGrid(4, 4);
                BentoLayoutSetPadding(10);
                BentoLayoutSetGutter(10, 10);
                BentoLayoutSetMaxSize(400, 295);
                BentoLayoutSetResize(BENTO_RESIZE_DEFLATE, BENTO_RESIZE_DEFLATE);
                
                var _index = 0;
                repeat(32)
                {
                    with(BentoCreate(oBentoExButton, {
                        text: string(_index),
                        func: function(_playerIndex)
                        {
                            text = $"P{_playerIndex + 1}";
                        },
                    }))
                    {
                        if (_index == 0) BentoHover(self, false, 1);
                        BentoLayoutSetResize(BENTO_RESIZE_INFLATE, undefined);
                    }
                    
                    ++_index;
                }
            }
        }
    }
}