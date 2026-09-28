// Feather disable all

function ExamplePlayersSeparate()
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
                
                BentoCreate(oBentoExText, { font: fntBentoExCandyBeansBig, text: "Two Players, Separate" });
                BentoCreate(oBentoExBackButton, { func: ExampleHomePage });
            }
            
            BentoCreate(oBentoExText, {
                text: "Each list belongs to one player. Player 1 scrolls the left list with the mouse and player 2 scrolls the right list with the keyboard.",
                font: fntBentoExCandyBeans,
            });
            
            with(BentoCreateBlank())
            {
                BentoLayoutSetGutter(60, 60);
                BentoLayoutSetResize(BENTO_RESIZE_INFLATE, BENTO_RESIZE_DEFLATE);
                BentoLayoutList(BENTO_AXIS_X, 0.5, 0);
                
                var _playerIndex = 0;
                repeat(2)
                {
                    with(BentoCreateBlank())
                    {
                        BentoSetPlayers([_playerIndex]);
                        BentoLayoutSetGutter(15, 15);
                        BentoLayoutSetResize(BENTO_RESIZE_DEFLATE, BENTO_RESIZE_DEFLATE);
                        BentoLayoutList(BENTO_AXIS_Y, 0.5, 0);
                        
                        BentoCreate(oBentoExText, { text: (_playerIndex == 0)? "Player 1 (mouse)" : "Player 2 (keyboard)", font: fntBentoExCandyBeans });
                        
                        with(BentoCreate(oBentoExScrollingList))
                        {
                            BentoLayoutSetPadding(10);
                            BentoLayoutSetGutter(10, 10);
                            BentoLayoutSetMaxSize(200, 295);
                            BentoLayoutSetResize(BENTO_RESIZE_DEFLATE, BENTO_RESIZE_DEFLATE);
                            
                            var _index = 0;
                            repeat(15)
                            {
                                with(BentoCreate(oBentoExButton, {
                                    text: string(_index),
                                }))
                                {
                                    if (_index == 0) BentoHover(self, false, _playerIndex);
                                    BentoLayoutSetResize(BENTO_RESIZE_INFLATE, undefined);
                                }
                                
                                ++_index;
                            }
                        }
                    }
                    
                    ++_playerIndex;
                }
            }
        }
    }
}