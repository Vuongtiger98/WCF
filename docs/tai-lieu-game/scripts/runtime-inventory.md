# Inventory script runtime

Snapshot đối chiếu trực tiếp `Data/Scripts.rvdata2`. Slot là chỉ số zero-based của mảng Marshal; không phải thứ tự chữ cái của file export.

- Tổng slot: 222 (gồm placeholder và separator).
- Slot có token Ruby thực thi: 182. Đây là kiểm tra cấu trúc, không chứng minh một tính năng đã được gọi trong game.
- Tác giả, công dụng và dependency của các script bổ sung: [catalogue.md](catalogue.md).
- Cột `exact` khớp byte; `line-endings-only` chỉ khác CRLF/LF; `different` cần xem token và nội dung trước khi đồng bộ.

| Slot | Script | Trạng thái mã | Export | SHA-256 runtime (12 ký tự đầu) |
|---:|---|---|---|---|
| 0 | (slot rỗng) | Rỗng/separator | — | `e3b0c44298fc` |
| 1 | ▼ Modules | Rỗng/separator | — | `e3b0c44298fc` |
| 2 | [Vocab](<../../../Scripts/Vocab.rb>) | Có mã | exact | `ab5bc32f7d19` |
| 3 | [Sound](<../../../Scripts/Sound.rb>) | Có mã | exact | `374838d9eba8` |
| 4 | [Cache](<../../../Scripts/Cache.rb>) | Có mã | exact | `67447b957588` |
| 5 | [DataManager](<../../../Scripts/DataManager.rb>) | Có mã | exact | `758f0500d4ed` |
| 6 | [SceneManager](<../../../Scripts/SceneManager.rb>) | Có mã | exact | `e5d5f304134f` |
| 7 | [BattleManager](<../../../Scripts/BattleManager.rb>) | Có mã | exact | `0164f88daa5e` |
| 8 | (slot rỗng) | Rỗng/separator | — | `e3b0c44298fc` |
| 9 | ▼ Game Objects | Rỗng/separator | — | `e3b0c44298fc` |
| 10 | [Game_Temp](<../../../Scripts/Game_Temp.rb>) | Có mã | exact | `606949ee32ce` |
| 11 | [Game_System](<../../../Scripts/Game_System.rb>) | Có mã | exact | `07ce99a2d81a` |
| 12 | [Game_Timer](<../../../Scripts/Game_Timer.rb>) | Có mã | exact | `351f97a2fa49` |
| 13 | [Game_Message](<../../../Scripts/Game_Message.rb>) | Có mã | exact | `3fb76b71d6ad` |
| 14 | [Game_Switches](<../../../Scripts/Game_Switches.rb>) | Có mã | exact | `613f10bedd11` |
| 15 | [Game_Variables](<../../../Scripts/Game_Variables.rb>) | Có mã | exact | `f58bfe8fd6af` |
| 16 | [Game_SelfSwitches](<../../../Scripts/Game_SelfSwitches.rb>) | Có mã | exact | `92493e03caf3` |
| 17 | [Game_Screen](<../../../Scripts/Game_Screen.rb>) | Có mã | exact | `3c38363f8cfa` |
| 18 | [Game_Picture](<../../../Scripts/Game_Picture.rb>) | Có mã | exact | `f67e940a359a` |
| 19 | [Game_Pictures](<../../../Scripts/Game_Pictures.rb>) | Có mã | exact | `c98632b6fb6e` |
| 20 | [Game_BaseItem](<../../../Scripts/Game_BaseItem.rb>) | Có mã | exact | `5e74328d5b82` |
| 21 | [Game_Action](<../../../Scripts/Game_Action.rb>) | Có mã | exact | `f5caf894ffd7` |
| 22 | [Game_ActionResult](<../../../Scripts/Game_ActionResult.rb>) | Có mã | exact | `29a1d25786b2` |
| 23 | [Game_BattlerBase](<../../../Scripts/Game_BattlerBase.rb>) | Có mã | exact | `dd317e6dad6c` |
| 24 | [Game_Battler](<../../../Scripts/Game_Battler.rb>) | Có mã | exact | `5683725c1e0e` |
| 25 | [Game_Actor](<../../../Scripts/Game_Actor.rb>) | Có mã | exact | `447882288ccd` |
| 26 | [Game_Enemy](<../../../Scripts/Game_Enemy.rb>) | Có mã | exact | `5dc4d9996295` |
| 27 | [Game_Actors](<../../../Scripts/Game_Actors.rb>) | Có mã | exact | `90453f2a0e49` |
| 28 | [Game_Unit](<../../../Scripts/Game_Unit.rb>) | Có mã | exact | `233c92b15669` |
| 29 | [Game_Party](<../../../Scripts/Game_Party.rb>) | Có mã | exact | `7bf23e38fcb2` |
| 30 | [Game_Troop](<../../../Scripts/Game_Troop.rb>) | Có mã | exact | `954ce8ce7e7c` |
| 31 | [Game_Map](<../../../Scripts/Game_Map.rb>) | Có mã | exact | `e1bea2d18ffe` |
| 32 | [Game_CommonEvent](<../../../Scripts/Game_CommonEvent.rb>) | Có mã | exact | `b9ecf0aa1d22` |
| 33 | [Game_CharacterBase](<../../../Scripts/Game_CharacterBase.rb>) | Có mã | exact | `51b4ba3b9c8b` |
| 34 | [Game_Character](<../../../Scripts/Game_Character.rb>) | Có mã | exact | `9b9cbeb26da1` |
| 35 | [Game_Player](<../../../Scripts/Game_Player.rb>) | Có mã | exact | `38a5a6f1640d` |
| 36 | [Game_Follower](<../../../Scripts/Game_Follower.rb>) | Có mã | exact | `eff8c2f396be` |
| 37 | [Game_Followers](<../../../Scripts/Game_Followers.rb>) | Có mã | exact | `c8b3e46cf1ca` |
| 38 | [Game_Vehicle](<../../../Scripts/Game_Vehicle.rb>) | Có mã | exact | `93d903107510` |
| 39 | [Game_Event](<../../../Scripts/Game_Event.rb>) | Có mã | exact | `d8794eef439a` |
| 40 | [Game_Interpreter](<../../../Scripts/Game_Interpreter.rb>) | Có mã | exact | `da807d4b2b44` |
| 41 | (slot rỗng) | Rỗng/separator | — | `e3b0c44298fc` |
| 42 | ▼ Sprites | Rỗng/separator | — | `e3b0c44298fc` |
| 43 | [Sprite_Base](<../../../Scripts/Sprite_Base.rb>) | Có mã | line-endings-only | `ce8863a1033b` |
| 44 | [Sprite_Character](<../../../Scripts/Sprite_Character.rb>) | Có mã | line-endings-only | `a6e750b6db70` |
| 45 | [Sprite_Battler](<../../../Scripts/Sprite_Battler.rb>) | Có mã | exact | `1494e975a5b8` |
| 46 | [Sprite_Picture](<../../../Scripts/Sprite_Picture.rb>) | Có mã | exact | `0ad0ffdfd8b3` |
| 47 | [Sprite_Timer](<../../../Scripts/Sprite_Timer.rb>) | Có mã | exact | `4d2fbf1bb203` |
| 48 | [Spriteset_Weather](<../../../Scripts/Spriteset_Weather.rb>) | Có mã | exact | `3faf1077948c` |
| 49 | [Spriteset_Map](<../../../Scripts/Spriteset_Map.rb>) | Có mã | exact | `affc766ef5ea` |
| 50 | [Spriteset_Battle](<../../../Scripts/Spriteset_Battle.rb>) | Có mã | exact | `7cdcb62e1abb` |
| 51 | (slot rỗng) | Rỗng/separator | — | `e3b0c44298fc` |
| 52 | ▼ Windows | Rỗng/separator | — | `e3b0c44298fc` |
| 53 | [Window_Base](<../../../Scripts/Window_Base.rb>) | Có mã | exact | `b0e670d13812` |
| 54 | [Window_Selectable](<../../../Scripts/Window_Selectable.rb>) | Có mã | exact | `52756307205c` |
| 55 | [Window_Command](<../../../Scripts/Window_Command.rb>) | Có mã | exact | `0ad8162d218a` |
| 56 | [Window_HorzCommand](<../../../Scripts/Window_HorzCommand.rb>) | Có mã | exact | `9fc5d04d764a` |
| 57 | [Window_Help](<../../../Scripts/Window_Help.rb>) | Có mã | exact | `afbacc5e4375` |
| 58 | [Window_Gold](<../../../Scripts/Window_Gold.rb>) | Có mã | exact | `37f6229cde8d` |
| 59 | [Window_MenuCommand](<../../../Scripts/Window_MenuCommand.rb>) | Có mã | exact | `b3627a2bfe8a` |
| 60 | [Window_MenuStatus](<../../../Scripts/Window_MenuStatus.rb>) | Có mã | exact | `29c3aa3bf4c7` |
| 61 | [Window_MenuActor](<../../../Scripts/Window_MenuActor.rb>) | Có mã | exact | `169aa3beaf6e` |
| 62 | [Window_ItemCategory](<../../../Scripts/Window_ItemCategory.rb>) | Có mã | exact | `1ed42a783f02` |
| 63 | [Window_ItemList](<../../../Scripts/Window_ItemList.rb>) | Có mã | exact | `788e5a23bf7e` |
| 64 | [Window_SkillCommand](<../../../Scripts/Window_SkillCommand.rb>) | Có mã | exact | `baf9e0068c45` |
| 65 | [Window_SkillStatus](<../../../Scripts/Window_SkillStatus.rb>) | Có mã | exact | `636487b5565c` |
| 66 | [Window_SkillList](<../../../Scripts/Window_SkillList.rb>) | Có mã | exact | `50c21101b444` |
| 67 | [Window_EquipStatus](<../../../Scripts/Window_EquipStatus.rb>) | Có mã | exact | `a4fff935a996` |
| 68 | [Window_EquipCommand](<../../../Scripts/Window_EquipCommand.rb>) | Có mã | exact | `dac4d83d5e8c` |
| 69 | [Window_EquipSlot](<../../../Scripts/Window_EquipSlot.rb>) | Có mã | exact | `f98170b8819b` |
| 70 | [Window_EquipItem](<../../../Scripts/Window_EquipItem.rb>) | Có mã | exact | `13a7a5d76f46` |
| 71 | [Window_Status](<../../../Scripts/Window_Status.rb>) | Có mã | exact | `d2d366b00111` |
| 72 | [Window_SaveFile](<../../../Scripts/Window_SaveFile.rb>) | Có mã | exact | `856b8542f0be` |
| 73 | [Window_ShopCommand](<../../../Scripts/Window_ShopCommand.rb>) | Có mã | exact | `2517d2f71806` |
| 74 | [Window_ShopBuy](<../../../Scripts/Window_ShopBuy.rb>) | Có mã | exact | `af607236ee08` |
| 75 | [Window_ShopSell](<../../../Scripts/Window_ShopSell.rb>) | Có mã | exact | `a79a3cab234b` |
| 76 | [Window_ShopNumber](<../../../Scripts/Window_ShopNumber.rb>) | Có mã | exact | `7d16af579850` |
| 77 | [Window_ShopStatus](<../../../Scripts/Window_ShopStatus.rb>) | Có mã | exact | `8d7e5422243d` |
| 78 | [Window_NameEdit](<../../../Scripts/Window_NameEdit.rb>) | Có mã | exact | `071beaab51ef` |
| 79 | [Window_NameInput](<../../../Scripts/Window_NameInput.rb>) | Có mã | exact | `8c630667f052` |
| 80 | [Window_ChoiceList](<../../../Scripts/Window_ChoiceList.rb>) | Có mã | exact | `e572f0e59429` |
| 81 | [Window_NumberInput](<../../../Scripts/Window_NumberInput.rb>) | Có mã | exact | `d63a8853c37a` |
| 82 | [Window_KeyItem](<../../../Scripts/Window_KeyItem.rb>) | Có mã | exact | `2dd9a977929f` |
| 83 | [Window_Message](<../../../Scripts/Window_Message.rb>) | Có mã | exact | `d721af660951` |
| 84 | [Window_ScrollText](<../../../Scripts/Window_ScrollText.rb>) | Có mã | exact | `22737328c82e` |
| 85 | [Window_MapName](<../../../Scripts/Window_MapName.rb>) | Có mã | exact | `b34b6253eb92` |
| 86 | [Window_BattleLog](<../../../Scripts/Window_BattleLog.rb>) | Có mã | exact | `2c3674488c20` |
| 87 | [Window_PartyCommand](<../../../Scripts/Window_PartyCommand.rb>) | Có mã | exact | `d994bc56d4b2` |
| 88 | [Window_ActorCommand](<../../../Scripts/Window_ActorCommand.rb>) | Có mã | exact | `998d160a3cee` |
| 89 | [Window_BattleStatus](<../../../Scripts/Window_BattleStatus.rb>) | Có mã | exact | `0194b7c43c8a` |
| 90 | [Window_BattleActor](<../../../Scripts/Window_BattleActor.rb>) | Có mã | exact | `f11deabe73d2` |
| 91 | [Window_BattleEnemy](<../../../Scripts/Window_BattleEnemy.rb>) | Có mã | exact | `3fbae5ed0c69` |
| 92 | [Window_BattleSkill](<../../../Scripts/Window_BattleSkill.rb>) | Có mã | exact | `07d850307f00` |
| 93 | [Window_BattleItem](<../../../Scripts/Window_BattleItem.rb>) | Có mã | exact | `5543c70a7358` |
| 94 | [Window_TitleCommand](<../../../Scripts/Window_TitleCommand.rb>) | Có mã | exact | `3e4d2463423d` |
| 95 | [Window_GameEnd](<../../../Scripts/Window_GameEnd.rb>) | Có mã | exact | `dae6b57caf80` |
| 96 | [Window_DebugLeft](<../../../Scripts/Window_DebugLeft.rb>) | Có mã | exact | `407ca24153d0` |
| 97 | [Window_DebugRight](<../../../Scripts/Window_DebugRight.rb>) | Có mã | exact | `593e983a26b5` |
| 98 | (slot rỗng) | Rỗng/separator | — | `e3b0c44298fc` |
| 99 | ▼ Scenes | Rỗng/separator | — | `e3b0c44298fc` |
| 100 | [Scene_Base](<../../../Scripts/Scene_Base.rb>) | Có mã | exact | `1c720b70cbe4` |
| 101 | [Scene_Title](<../../../Scripts/Scene_Title.rb>) | Có mã | exact | `39ec2e4f2c09` |
| 102 | [Scene_Map](<../../../Scripts/Scene_Map.rb>) | Có mã | exact | `a8e223390be7` |
| 103 | [Scene_MenuBase](<../../../Scripts/Scene_MenuBase.rb>) | Có mã | exact | `116a97ce3078` |
| 104 | [Scene_Menu](<../../../Scripts/Scene_Menu.rb>) | Có mã | exact | `4e125eadfd82` |
| 105 | [Scene_ItemBase](<../../../Scripts/Scene_ItemBase.rb>) | Có mã | exact | `dfae44e529b6` |
| 106 | [Scene_Item](<../../../Scripts/Scene_Item.rb>) | Có mã | exact | `c0e0416b0252` |
| 107 | [Scene_Skill](<../../../Scripts/Scene_Skill.rb>) | Có mã | exact | `cf4e9e6f84e1` |
| 108 | [Scene_Equip](<../../../Scripts/Scene_Equip.rb>) | Có mã | exact | `b83029fbb323` |
| 109 | [Scene_Status](<../../../Scripts/Scene_Status.rb>) | Có mã | exact | `1c8bce3f31a7` |
| 110 | [Scene_File](<../../../Scripts/Scene_File.rb>) | Có mã | exact | `8606811e97be` |
| 111 | [Scene_Save](<../../../Scripts/Scene_Save.rb>) | Có mã | exact | `f3e37612c1ab` |
| 112 | [Scene_Load](<../../../Scripts/Scene_Load.rb>) | Có mã | exact | `9d36875c1e0a` |
| 113 | [Scene_End](<../../../Scripts/Scene_End.rb>) | Có mã | exact | `ffaf133f478a` |
| 114 | [Scene_Shop](<../../../Scripts/Scene_Shop.rb>) | Có mã | exact | `a8ae5ca8d20a` |
| 115 | [Scene_Name](<../../../Scripts/Scene_Name.rb>) | Có mã | exact | `5bb73e02d7f3` |
| 116 | [Scene_Debug](<../../../Scripts/Scene_Debug.rb>) | Có mã | exact | `c6e30a1d68cb` |
| 117 | [Scene_Battle](<../../../Scripts/Scene_Battle.rb>) | Có mã | exact | `465163610646` |
| 118 | [Scene_Gameover](<../../../Scripts/Scene_Gameover.rb>) | Có mã | exact | `9c9894972c9d` |
| 119 | (slot rỗng) | Rỗng/separator | — | `e3b0c44298fc` |
| 120 | ▼ Materials | Rỗng/separator | — | `e3b0c44298fc` |
| 121 | [( Insert here )](<../../../Scripts/( Insert here ).rb>) | Comment/tài liệu | exact | `a49c50342806` |
| 122 | [Theo Anti Lag](<../../../Scripts/Theo Anti Lag.rb>) | Comment/tài liệu | exact | `ffcd11d28ae6` |
| 123 | [MOG character effect](<../../../Scripts/MOG character effect.rb>) | Có mã | exact | `37e8a24afb49` |
| 124 | [Pictures under characters](<../../../Scripts/Pictures under characters.rb>) | Có mã | exact | `22f418cbc67d` |
| 125 | [Followers](<../../../Scripts/Followers.rb>) | Có mã | exact | `f229c9924997` |
| 126 | =================================== | Rỗng/separator | — | `e3b0c44298fc` |
| 127 | [Basic__Module](<../../../Scripts/Basic__Module.rb>) | Có mã | exact | `bc10a75ca6b7` |
| 128 | [victor module](<../../../Scripts/victor module.rb>) | Có mã | exact | `2ba0954c8ade` |
| 129 | [XS Core](<../../../Scripts/XS Core.rb>) | Có mã | exact | `469fb2f96811` |
| 130 | [Yanfly Core Engine](<../../../Scripts/Yanfly Core Engine.rb>) | Có mã | exact | `fd2255de84ac` |
| 131 | ================================== | Rỗng/separator | — | `e3b0c44298fc` |
| 132 | [Stairs Movement](<../../../Scripts/Stairs Movement.rb>) | Có mã | exact | `2d3fb058ce3f` |
| 133 | [MOG_Weather_EX](<../../../Scripts/MOG_Weather_EX.rb>) | Có mã | exact | `8e93dc08819c` |
| 134 | [Mog Event sensor range](<../../../Scripts/Mog Event sensor range.rb>) | Có mã | exact | `8b22bb1ef995` |
| 135 | [Lune Smooth Camera Sliding](<../../../Scripts/Lune Smooth Camera Sliding.rb>) | Có mã | exact | `143f65f18fb8` |
| 136 | [Victor Engine - Animations Settings](<../../../Scripts/Victor Engine - Animations Settings.rb>) | Có mã | exact | `0a1f05a7303a` |
| 137 | ==================== | Rỗng/separator | — | `e3b0c44298fc` |
| 138 | [Galv's Layer Graphics](<../../../Scripts/Galv's Layer Graphics.rb>) | Có mã | exact | `223f690c3230` |
| 139 | [parallax lock yanfly](<../../../Scripts/parallax lock yanfly.rb>) | Có mã | exact | `93da99eaa77f` |
| 140 | [animated parallax](<../../../Scripts/animated parallax.rb>) | Có mã | exact | `abb131bce921` |
| 141 | [anti-animation lag](<../../../Scripts/anti-animation lag.rb>) | Có mã | exact | `159d88eaf174` |
| 142 | [victor fog](<../../../Scripts/victor fog.rb>) | Có mã | exact | `32cc09ddbdac` |
| 143 | [Galv Char effect](<../../../Scripts/Galv Char effect.rb>) | Có mã | exact | `e078cecf275b` |
| 144 | ============================ | Rỗng/separator | — | `e3b0c44298fc` |
| 145 | [Pathfinder](<../../../Scripts/Pathfinder.rb>) | Có mã | exact | `eaec0bda069d` |
| 146 | [Dash Control](<../../../Scripts/Dash Control.rb>) | Có mã | exact | `5a152d0d6d1a` |
| 147 | [Picture bug](<../../../Scripts/Picture bug.rb>) | Có mã | exact | `cfda0f573adf` |
| 148 | [Fixed Pictures](<../../../Scripts/Fixed Pictures.rb>) | Có mã | different | `ec754bd06a78` |
| 149 | [Map Effects User Guide](<../../../Scripts/Map Effects User Guide.rb>) | Comment/tài liệu | exact | `a72d15fa1ce0` |
| 150 | [Map effects](<../../../Scripts/Map effects.rb>) | Có mã | exact | `8315e5eb6c89` |
| 151 | [Stop Movement](<../../../Scripts/Stop Movement.rb>) | Có mã | exact | `50c92d599894` |
| 152 | ========================== | Rỗng/separator | — | `e3b0c44298fc` |
| 153 | [Disable key](<../../../Scripts/Disable key.rb>) | Comment/tài liệu | exact | `2ea9f2bf651a` |
| 154 | [Map Screenshot](<../../../Scripts/Map Screenshot.rb>) | Có mã | exact | `576d3e1417e2` |
| 155 | ======================= | Rỗng/separator | — | `e3b0c44298fc` |
| 156 | [Yanfly Message System](<../../../Scripts/Yanfly Message System.rb>) | Có mã | exact | `a7225ac04713` |
| 157 | [Yanfly Message System addon](<../../../Scripts/Yanfly Message System addon.rb>) | Có mã | exact | `392d94a9427b` |
| 158 | [Yanfly Adjust Limits](<../../../Scripts/Yanfly Adjust Limits.rb>) | Có mã | exact | `ba5f81955804` |
| 159 | [Galv's Double Message](<../../../Scripts/Galv's Double Message.rb>) | Có mã | exact | `a0654b51bec7` |
| 160 | ==================== | Rỗng/separator | — | `e3b0c44298fc` |
| 161 | [Yanfly Event Chase Player](<../../../Scripts/Yanfly Event Chase Player.rb>) | Có mã | different | `8a38b80c6e32` |
| 162 | [Yanfly Event Popup](<../../../Scripts/Yanfly Event Popup.rb>) | Có mã | exact | `16c954f2894c` |
| 163 | [Yanfly Force Move Titles](<../../../Scripts/Yanfly Force Move Titles.rb>) | Có mã | exact | `b5104722648f` |
| 164 | [Yanfly Slippery Titles](<../../../Scripts/Yanfly Slippery Titles.rb>) | Có mã | exact | `9c0b3c85861a` |
| 165 | [Yanfly NPC Move Restrict](<../../../Scripts/Yanfly NPC Move Restrict.rb>) | Có mã | exact | `f0a75e266391` |
| 166 | [Yanfly Gabwindow](<../../../Scripts/Yanfly Gabwindow.rb>) | Có mã | exact | `ad12e175f9de` |
| 167 | ===================== | Rỗng/separator | — | `e3b0c44298fc` |
| 168 | [Yanfly Menu Engine](<../../../Scripts/Yanfly Menu Engine.rb>) | Có mã | exact | `7d6784c59566` |
| 169 | [Yanfly Save Engine](<../../../Scripts/Yanfly Save Engine.rb>) | Có mã | line-endings-only | `4233af1121fd` |
| 170 | [Yanfly Window Icons](<../../../Scripts/Yanfly Window Icons.rb>) | Có mã | exact | `6e164014e5c6` |
| 171 | [Yanfly Menu Cursor](<../../../Scripts/Yanfly Menu Cursor.rb>) | Có mã | line-endings-only | `6d82721c4933` |
| 172 | [Yanfly System Option](<../../../Scripts/Yanfly System Option.rb>) | Có mã | exact | `ea6cd5972069` |
| 173 | ==================== | Rỗng/separator | — | `e3b0c44298fc` |
| 174 | [Yanfly Flip Pictures](<../../../Scripts/Yanfly Flip Pictures.rb>) | Có mã | exact | `0485d012fb4c` |
| 175 | ==================== | Rỗng/separator | — | `e3b0c44298fc` |
| 176 | ================================= | Rỗng/separator | — | `e3b0c44298fc` |
| 177 | [KUL Core Library](<../../../Scripts/KUL Core Library.rb>) | Có mã | exact | `8cad9db143e2` |
| 178 | [KUL Graphics Library](<../../../Scripts/KUL Graphics Library.rb>) | Có mã | exact | `e7045a3ffcaa` |
| 179 | [KUL Graphics](<../../../Scripts/KUL Graphics.rb>) | Có mã | exact | `26dcb9641449` |
| 180 | [KUL Graphics Menu Add-on](<../../../Scripts/KUL Graphics Menu Add-on.rb>) | Comment/tài liệu | exact | `cc967e3109bd` |
| 181 | [KUL Item Lantern Add-on](<../../../Scripts/KUL Item Lantern Add-on.rb>) | Có mã | exact | `f7738bae5afa` |
| 182 | [KUL Fog Add-on](<../../../Scripts/KUL Fog Add-on.rb>) | Có mã | exact | `901754536e1c` |
| 183 | ======================= | Rỗng/separator | — | `e3b0c44298fc` |
| 184 | [Terrain and Region Effects](<../../../Scripts/Terrain and Region Effects.rb>) | Có mã | exact | `2520353d35a3` |
| 185 | [Galv's Region Effects](<../../../Scripts/Galv's Region Effects.rb>) | Comment/tài liệu | exact | `d3fac2f665f6` |
| 186 | [Text Over Event](<../../../Scripts/Text Over Event.rb>) | Có mã | exact | `e824840cd460` |
| 187 | ======================== | Rỗng/separator | — | `e3b0c44298fc` |
| 188 | [HP Bar Over Player](<../../../Scripts/HP Bar Over Player.rb>) | Có mã | exact | `e2e7f3b845c3` |
| 189 | [Particles](<../../../Scripts/Particles.rb>) | Có mã | exact | `2fcb6573ea34` |
| 190 | [Particles Weather](<../../../Scripts/Particles Weather.rb>) | Có mã | exact | `bbc370d04f93` |
| 191 | ======================== | Rỗng/separator | — | `e3b0c44298fc` |
| 192 | [MOG_T_Logo](<../../../Scripts/MOG_T_Logo.rb>) | Có mã | line-endings-only | `1835a8ba001a` |
| 193 | [MOG_T_Particles](<../../../Scripts/MOG_T_Particles.rb>) | Có mã | exact | `1e33a7b564df` |
| 194 | [MOG_T_Name](<../../../Scripts/MOG_T_Name.rb>) | Có mã | line-endings-only | `bfe266ab88b7` |
| 195 | [MOG_Picture_Gallery](<../../../Scripts/MOG_Picture_Gallery.rb>) | Có mã | exact | `edc0c0b45563` |
| 196 | [Move the Menu](<../../../Scripts/Move the Menu.rb>) | Có mã | exact | `deac30decd8b` |
| 197 | [Cutscene Group Chat](<../../../Scripts/Cutscene Group Chat.rb>) | Có mã | exact | `d9fbbb7c5377` |
| 198 | [Custom Menu](<../../../Scripts/Custom Menu.rb>) | Có mã | exact | `51ef64184713` |
| 199 | [BulletHell](<../../../Scripts/BulletHell.rb>) | Có mã | line-endings-only | `5f046f2e6063` |
| 200 | [Random Event Patch](<../../../Scripts/Random Event Patch.rb>) | Có mã | line-endings-only | `72e08c8015f5` |
| 201 | [Easy Script Importer-Exporter  ](<../../../Scripts/Easy Script Importer-Exporter  .rb>) | Có mã | exact | `fb255a4fadff` |
| 202 | [Galv's Cam Slide Control](<../../../Scripts/Galv's Cam Slide Control.rb>) | Comment/tài liệu | exact | `20defc298c45` |
| 203 | [Pop Message](<../../../Scripts/Pop Message.rb>) | Có mã | exact | `9dd32b3de199` |
| 204 | [Enhanced Camera ](<../../../Scripts/Enhanced Camera .rb>) | Có mã | exact | `97172d461ad0` |
| 205 | [The Art of Screenshake](<../../../Scripts/The Art of Screenshake.rb>) | Có mã | exact | `2594f422a3a6` |
| 206 | [Transform Form Selection](<../../../Scripts/Transform Form Selection.rb>) | Có mã | line-endings-only | `561dd6c82726` |
| 207 | (slot rỗng) | Rỗng/separator | — | `e3b0c44298fc` |
| 208 | (slot rỗng) | Rỗng/separator | — | `e3b0c44298fc` |
| 209 | [Catto Petting Minigame](<../../../Scripts/Catto Petting Minigame.rb>) | Có mã | line-endings-only | `2c24b77cbfec` |
| 210 | [Multi Switch Condition Helper](<../../../Scripts/Multi Switch Condition Helper.rb>) | Có mã | exact | `644db3d1e285` |
| 211 | [Atlantis Shrimp Fishing](<../../../Scripts/Atlantis Shrimp Fishing.rb>) | Có mã | exact | `e08e6aa18af6` |
| 212 | (slot rỗng) | Rỗng/separator | — | `e3b0c44298fc` |
| 213 | [Atlantis Mirror Maze Chase](<../../../Scripts/Atlantis Mirror Maze Chase.rb>) | Có mã | exact | `c2cc936ed050` |
| 214 | [WCF Snowball Rhythm](<../../../Scripts/WCF Snowball Rhythm.rb>) | Có mã | exact | `22bc90f47aa2` |
| 215 | (slot rỗng) | Rỗng/separator | — | `e3b0c44298fc` |
| 216 | (slot rỗng) | Rỗng/separator | — | `e3b0c44298fc` |
| 217 | ▼ Main Process | Rỗng/separator | — | `e3b0c44298fc` |
| 218 | [WCF Storage Memory Transition](<../../../Scripts/WCF Storage Memory Transition.rb>) | Có mã | exact | `12873b29e63e` |
| 219 | [WCF Test Hub](<../../../Scripts/WCF Test Hub.rb>) | Có mã | exact | `f9c6ad6eea8a` |
| 220 | [Main](<../../../Scripts/Main.rb>) | Có mã | exact | `05ee51c5e379` |
| 221 | (slot rỗng) | Rỗng/separator | — | `e3b0c44298fc` |

## Phạm vi xác minh

Inventory không thực thi script game. Các slot chuẩn VX Ace được liệt kê đầy đủ để nhận diện cả code gốc đã chỉnh. File có code nhưng nằm trong nhánh điều kiện không dùng vẫn xuất hiện là “Có mã”.

Tái tạo nội dung: `ruby tools/script_inventory.rb markdown`. Đọc chênh lệch: `ruby tools/script_inventory.rb differences`. Kiểm tra token: `ruby tools/script_inventory.rb semantic`.
