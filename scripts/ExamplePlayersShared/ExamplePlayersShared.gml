// Feather disable all

function ExamplePlayersShared()
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
                
                BentoCreate(oBentoExText, { font: fntBentoExCandyBeansBig, text: "Two Players, Shared" });
                BentoCreate(oBentoExBackButton, { func: ExampleHomePage });
            }
            
            BentoCreate(oBentoExText, {
                text: "Player 1 uses the mouse and player 2 uses the keyboard. Both players can use every button and each button shows who clicked it last.",
                font: fntBentoExCandyBeans,
            });
            
            with(BentoCreateBlank())
            {
                BentoLayoutSetGutter(20, 20);
                BentoLayoutSetResize(BENTO_RESIZE_INFLATE, BENTO_RESIZE_DEFLATE);
                BentoLayoutList(BENTO_AXIS_X, 0.5, 0);
                
                var _index = 0;
                repeat(4)
                {
                    with(BentoCreate(oBentoExButton, {
                        text: "Click me",
                        func: function(_playerIndex)
                        {
                            text = $"Player {_playerIndex + 1}";
                        },
                    }))
                    {
                        if (_index == 0) BentoHover(self, false, 1);
                    }
                    
                    ++_index;
                }
            }
        }
    }
}