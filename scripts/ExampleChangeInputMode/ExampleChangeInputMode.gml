// Feather disable all

function ExampleChangeInputMode()
{
    with(oMain)
    {
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
                
                BentoCreate(oBentoExText, { font: fntBentoExCandyBeansBig, text: "Change Input Mode" });
                BentoCreate(oBentoExBackButton, { func: ExampleHomePage });
            }
            
            BentoCreate(oBentoExTextDynamic, {
                font: fntBentoExCandyBeans,
                text: function()
                {
                    var _text = "";
                    var _playerIndex = 0;
                    repeat(oMain.playerCount)
                    {
                        var _mode = BentoGetMode(undefined, _playerIndex);
                        _text += $"Player {_playerIndex + 1} is using {["unknown", "mouse", "keyboard", "gamepad", "touch"][_mode]} input\n";
                        ++_playerIndex;
                    }
                    
                    return _text;
                },
            });
            
            BentoCreate(oBentoExButton, {
                text: "Mouse",
                inoperative: (not BENTO_ON_DESKTOP),
                func: function(_playerIndex)
                {
                    BentoSetMode(BENTO_MODE_MOUSE, undefined, _playerIndex);
                },
            });
            
            BentoCreate(oBentoExButton, {
                text: "Keyboard",
                inoperative: (not BENTO_ON_DESKTOP),
                func: function(_playerIndex)
                {
                    BentoSetMode(BENTO_MODE_KEYBOARD, undefined, _playerIndex);
                },
            });
            
            BentoCreate(oBentoExButton, {
                text: "Keyboard",
                inoperative: (not BENTO_ON_DESKTOP),
                func: function(_playerIndex)
                {
                    BentoSetMode(BENTO_MODE_KEYBOARD, undefined, _playerIndex);
                },
            });
            
            BentoCreate(oBentoExButton, {
                text: "Gamepad",
                func: function(_playerIndex)
                {
                    BentoSetMode(BENTO_MODE_GAMEPAD, undefined, _playerIndex);
                },
            });
            
            BentoCreate(oBentoExButton, {
                text: "Touch",
                inoperative: not (BENTO_ON_DESKTOP || BENTO_ON_MOBILE),
                func: function(_playerIndex)
                {
                    BentoSetMode(BENTO_MODE_TOUCH, undefined, _playerIndex);
                },
            });
            
            BentoCreate(oBentoExText, {
                text: (not BENTO_ON_DESKTOP)? "" : "You can also use the 1 / 2 / 3 / 4 keys to set input mode.",
                font: fntBentoExCandyBeans,
            });
        }
    }
}

function ExampleChangeInputModeJSON()
{
    with(oMain)
    {
        var _json = {
            object: oBentoExParent,
            layout: {
                padding: 40,
                gutter: 35,
                resize: [BENTO_RESIZE_INFLATE, BENTO_RESIZE_INFLATE],
                list: [BENTO_AXIS_Y, 0.5, 0],
            },
            children: [
                {
                    object: oBentoExParent,
                    layout: {
                        list: [BENTO_AXIS_X, 0.5, 0.5],
                        gutter: 35,
                        resize: [BENTO_RESIZE_INFLATE, BENTO_RESIZE_DEFLATE],
                    },
                    children: [
                        {
                            object: oBentoExText,
                            vars: {
                                text: "Change Input Mode",
                                font: fntBentoExCandyBeansBig,
                            },
                        },
                        {
                            object: oBentoExBackButton,
                            hover: true,
                            vars: {
                                func: ExampleHomePage,
                            },
                        },
                    ],
                },
                {
                    object: oBentoExTextDynamic,
                    vars: {
                        text: function()
                        {
                            var _text = "";
                            var _playerIndex = 0;
                            repeat(oMain.playerCount)
                            {
                                var _mode = BentoGetMode(undefined, _playerIndex);
                                _text += $"Player {_playerIndex + 1} is using {["unknown", "mouse", "keyboard", "gamepad", "touch"][_mode]} input\n";
                                ++_playerIndex;
                            }
                            
                            return _text;
                        },
                        font: fntBentoExCandyBeans,
                    },
                },
                {
                    object: oBentoExButton,
                    vars: {
                        text: "Mouse",
                        inoperative: (not BENTO_ON_DESKTOP),
                        func: function(_playerIndex)
                        {
                            BentoSetMode(BENTO_MODE_MOUSE, undefined, _playerIndex);
                        },
                    },
                },
                {
                    object: oBentoExButton,
                    vars: {
                        text: "Keyboard",
                        inoperative: (not BENTO_ON_DESKTOP),
                        func: function(_playerIndex)
                        {
                            BentoSetMode(BENTO_MODE_KEYBOARD, undefined, _playerIndex);
                        },
                    },
                },
                {
                    object: oBentoExButton,
                    vars: {
                        text: "Gamepad",
                        func: function(_playerIndex)
                        {
                            BentoSetMode(BENTO_MODE_GAMEPAD, undefined, _playerIndex);
                        },
                    },
                },
                {
                    object: oBentoExButton,
                    vars: {
                        text: "Touch",
                        inoperative: not (BENTO_ON_DESKTOP || BENTO_ON_MOBILE),
                        func: function(_playerIndex)
                        {
                            BentoSetMode(BENTO_MODE_TOUCH, undefined, _playerIndex);
                        },
                    },
                },
                {
                    object: oBentoExText,
                    vars: {
                        text: (not BENTO_ON_DESKTOP)? "" : "You can also use the 1 / 2 / 3 / 4 keys to set input mode.",
                        font: fntBentoExCandyBeans,
                    },
                },
            ],
        };
        
        BentoLayerClear("example layer");
        BentoCreateFromJSON(_json, undefined, BentoLayerGetRoot());
    }
}