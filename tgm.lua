local _G, _ = _G or getfenv()

local TGM = CreateFrame("Frame")

TGM.prefix = 'GM_ADDON'

-- .shop log accountname
TGM.flag = '0'
TGM.sort = '↓'
TGM.tickets = {}
TGM.ticket = nil
TGM.ticketFrames = {}
TGM.AntiCheatOn = false
TGM.triggerCount=0
TGM.gmCount=0
TGM.gm={}
TGM.BanAccList={}
TGM.CheaterList={}
TGM.cheaterFrames={}
TGM.iplist = {}
TGM.realm=GetRealmName()

TGM.bantypes = {
    [1] = 'RMT行为',
    [2] = '脚本/外挂',
    [3] = '恶意利用bug刷副本',
    [4] = '组织参与PVP互刷',
    [5] = '长时间AA',
    [6] = '过度开发游戏资源',
    [7] = '大带小',
    [8] = '屡次辱骂工作人员',
    [9] = '欺诈/钓鱼'
}

TGM.bandue = {
    [1] = '永久',    
    [2] = '30天',
    [3] = '7天'
    
}

TGM.gotogps = {
    [1] = '暴风城',
    [2] = '奥格瑞玛',
    [3] = '闪金镇',
    [4] = '十字路口',
    [5] = '玛格拉姆村',
    [6] = '吉尔吉斯村',
    [7] = '蕨墙村'

}

TGM.lookuptypes ={
    [1] = '物品',
    [2] = '任务'

}

TGM.races = {
    [1] = '人类',
    [2] = '兽人',
    [3] = '矮人',
    [4] = '暗夜精灵',
    [5] = '亡灵',
    [6] = '牛头人',
    [7] = '侏儒',
    [8] = '巨魔',
    [9] = '地精',
    [10] = '高等精灵'
}

TGM.classes = {
    [1] = '战士',
    [2] = '圣骑士',
    [3] = '猎人',
    [4] = '盗贼',
    [5] = '牧师',
    [7] = '萨满祭司',
    [8] = '法师',
    [9] = '术士',
    [11] = '德鲁伊'
}

TGM.classColors = {
    ["猎人"] = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
    ["术士"] = { r = 0.58, g = 0.51, b = 0.79, colorStr = "ff9482c9" },
    ["牧师"] = { r = 1.0, g = 1.0, b = 1.0, colorStr = "ffffffff" },
    ["圣骑士"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" },
    ["法师"] = { r = 0.41, g = 0.8, b = 0.94, colorStr = "ff69ccf0" },
    ["盗贼"] = { r = 1.0, g = 0.96, b = 0.41, colorStr = "fffff569" },
    ["德鲁伊"] = { r = 1.0, g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
    ["萨满祭司"] = { r = 0.0, g = 0.44, b = 0.87, colorStr = "ff0070de" },
    ["战士"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" }
};

TGM:RegisterEvent("ADDON_LOADED")
TGM:RegisterEvent("CHAT_MSG_ADDON")
TGM:RegisterEvent("CHAT_MSG_SYSTEM")
TGM:RegisterEvent("CHAT_MSG_WHISPER")




TGM:SetScript("OnEvent", function()
    if event then
        if event == "ADDON_LOADED" and string.lower(arg1) == 'tgm' then
            TGM.init()
        end
        if event == 'CHAT_MSG_SYSTEM' then
            TGM.handleSystemMessage(arg1)
            TGM.handleSysMessage(arg1)    
        end


        if event == 'CHAT_MSG_ADDON' and arg1 == TGM.prefix then
            TGM.handleAddonMessage(arg2)
        end
        

    end

end)

function TGM.init()

    if not TGM_BAN_DATA then
        TGM_BAN_DATA ={
            data={}
        }
    end

    if not TGM_DATA then
        TGM_DATA = {
            scale = 1,
            serverinfo="",
            servertime="",
            serveruptime="",
            server="",
            gm={},
            tickets=0,
            ticketlast="",
            templates = {
                {
                    text = "亲爱的玩家 您好。您所描述的NPC无法点击情况。可以打开声望界面，找到该NPC所属的阵营，点击后确保移除<交战状态>的标记，这样才能打开对话窗口与NPC进行对话。",
                    title = "NPC交战状态",
                },
                 {
                    text = "Turtle WoW严禁任何RMT方式（包括代币/金币）寻求提升服务。您可以与自身等级相符的玩家进入等级相符的地下城进行活动。",
                    title = "代练等级",
                },
                 {
                    text = "您好！首先需要您确保没有处于团队中。或者，关闭游戏客户端并清除WDB文件夹，禁用所有插件后登录游戏尝试。祝你有一个愉快的一天！",
                    title = "任务无法完成",
                },
                 {
                    text = "您好，NPC卡住问题已经处理完毕，您可以来到NPC处尝试对话上交/接取任务，祝您游戏愉快。",
                    title = "NPC卡住",
                },
                 {
                    text = "亲爱的玩家，您好。若您在游戏过程中遇到语言骚扰情况，我们十分理解您的心情。建议您可以先将对方进行屏蔽。举报情况会有相关工作人员进行跟进核实。",
                    title = "骚扰1",
                },
                 {
                    text = "亲爱的玩家 您好，收到您的语言举报，您可以在方便时前往KOOK【频道号100000】-举证频道 发送截图，并附带服务器与角色名，以便工作人员进行查证核实。",
                    title = "骚扰2",
                },
                 {
                    text = "您好！您所描述的骚扰情况，建议您输入“/ignore”命令从而屏蔽其他玩家。若骚扰问题持续存在，如创建多角色以避免被屏蔽，请与客服联系。",
                    title = "骚扰3",
                },
                 {
                    text = "您好。感谢您对于我们项目的支持。麻烦您将相关【完整截图 - 游戏内账户名】发送邮箱【cnturtlewow@gmail.com】并简单说明情况。后续会有工作人员核实。",
                    title = "代币丢失",
                },
                 {
                    text = "您好，战争模式在您的角色60级前可激活两次，但只能主动取消一次。第一次激活战争模式，可以找雕文大师NPC取消。但如果第二次激活战争模式，60级之前无法取消。",
                    title = "移除战争模式",
                },
                 {
                    text = "您好，工作人员无法对战利品进行二次分配，建议您的团队在后续活动前团队进行确认分配模式，分配时多确认分配成员情况，以免造成误会。祝您游戏愉快",
                    title = "重新分配掉落",
                },
                 {
                    text = "您好，以下是有关名称的信息，所有不活跃的名称将在每个星期三自动清理。您可以前往：https://forum.turtle-wow.org/viewtopic.php?t=5599 进行参考。祝您游戏愉快",
                    title = "名字预订",
                },
                 {
                    text = "您好。非常抱歉 游戏内无任何复活硬核角色相关服务以及方式，给您带来不便还望海涵。祝您的游戏旅程一路顺利。",
                    title = "复活硬核角色",
                },
                 {
                    text = "您好，就PVP行为对您造成困扰情况我们十分理解。pvp作为游戏内正常设定，工作人员无法进行干涉。您可以自主选择开启或关闭战争模式。",
                    title = "PVP被杀①",
                },
                 {
                    text = "您好，PVP行为属于游戏内正常游戏设定，您可以寻找游戏内其他高等级伙伴进行帮助，或者尝试关闭战争模式。祝您游戏愉快。",
                    title = "PVP被杀②",
                },
                 {
                    text = "您好。目前游戏内没有【种族转换】或【阵营转换】相关服务。还请您以游戏内实际情况为准。",
                    title = "转种族/阵营",
                },
                 {
                    text = "您好。请确保您的【NPC】名字准确后尝试使用【/目标 NPC名字】进行查找。",
                    title = "目标NPC找不到",
                },
                 {
                    text = "您好。无法找到尸体的情况该建议您可以寻找一下附近的天使NPC进行虚弱复活，并无直接复活功能。",
                    title = "虚弱复活",
                },
                 {
                    text = "您好。您所举报的【游戏行为】相关工作人员正在跟进，感谢您与我们一起维护美好的线上游戏环境。",
                    title = "多人举报",
                },
                 {
                    text = "您好。建议您持续保持正常游戏行为，【乌龟服行为准则】您可以前往KOOK频道进行查看。祝您游戏愉快",
                    title = "行为准则",
                },
                 {
                    text = "您好，经验无法获取问题，建议您尝试禁用所有插件后登录游戏，右键点击你的头像。确保经验设置为 启用。如果这没有起作用，请在聊天中键入.xp on 进行查看",
                    title = "无法获得经验",
                },
                 {
                    text = "您好！抱歉。您可以登录（https://github.com/slowtorta/turtlewow-bug-tracker）提交游戏错误情况，以便工作人员查看。你还可以尝试关闭客户端并清除WDB文件夹查看",
                    title = "BUG提交",
                },
                 {
                    text = "您好，账号封禁相关情况，官网-账号管理中进行查看参考。关于【乌龟服行为准则】您可以前往KOOK频道进行查阅。祝您游戏愉快",
                    title = "账号为什么被冻结",
                },
                 {
                    text = "您好，该情况工作人员无法进行处理，还请您以游戏内实际情况为准。给您带来不便还请您多多谅解。祝您游戏愉快",
                    title = "无法处理",
                },
                 {
                    text = "您好，游戏攻略类情况建议您可以与游戏内 或者 KOOK频道与其他玩家一同沟通交流游戏经验，祝您游戏愉快",
                    title = "攻略类问题",
                },
                 {
                    text = "您好，收到您的语言举报，您可以在方便时前往KOOK【频道号100000】--举证频道 发送截图，并附带服务器与角色名，以便工作人员进行查证核实。",
                    title = "语言类举报",
                },
                 {
                    text = "您好。请您放心，幻化物品的其他属性奖励仍然正常加成。 在装备界面上看不到套装属性是一个显示错误。祝您游戏愉快",
                    title = "幻化效果不显示",
                },
                 {
                    text = "您好，怪物刷新均为随机，建议您耐心等待多多尝试，祝您游戏愉快",
                    title = "怪物刷新",
                },
                 {
                    text = "您好，物品掉落均为随机，建议您多多尝试来获得心怡物品，祝您好运。",
                    title = "物品掉落几率",
                },
                 {
                    text = "您好。工作人员无法对战利品进行二次分配，建议您的团队在后续活动开始前确认分配模式以及分配团员，以免造成误会。祝您游戏愉快",
                    title = "团本装备再分配",
                },
                 {
                    text = "您好！我们无法恢复从未被拾取的物品。如果你有这个事情的视频证据，请附上它，并请队伍的队长提交一张工单，指明应该接收该物品的玩家的名字。",
                    title = "无法拾取",
                },
                 {
                    text = "您好！很抱歉，根据你所提供的信息，我无法确定你的工单的具体内容。如果你仍然遇到问题，请创建一个新的工单并提供更多的信息。",
                    title = "细节不足",
                },
                 {
                    text = "隐藏在此安全点违反了我们的规定。我将对您的账户进行警告。如果再次进行此操作，可能会采取进一步的惩罚措施",
                    title = "无法被攻击的点",
                },
                 {
                    text = "你好！如果一件重要物品被出售或销毁了,请前往垃圾收集者处找回，联盟在暴风城贸易区(60,69)部落在幽暗城(72,36)处能找到他。",
                    title = "物品被摧毁或出售",
                },
                 {
                    text = "在他人使用您的账号时，您需对任何违规行为负责。我们不会撤销由他人在使用您的账号时造成的任何角色变更。",
                    title = "账号被盗恢复",
                },
                 {
                    text = "您好！您希望退还的物品购买时间已经超过一周，因此不符合退款条件。",
                    title = "退款拒绝",
                },
                 {
                    text = "您好！非常感谢您的反馈，我们将会关注并调查此玩家的行为，调查核实后，若该玩家存在违反社区规则的行为，将会按照社区规则处罚",
                    title = "举报回复",
                },
                 {
                    text = "您好！非常感谢反馈，我们已对违反社区规则的玩家做出相应处罚，再次期待你的的反馈。祝您游戏愉快！",
                    title = "完成回复",
                },
                 {
                    text = "您好，麻烦您将所举报内容相关的 证据截图和服务器名称发到kook举证频道，以便工作人员进行查证核实。",
                    title = "举证",
                },
                 {
                    text = "您好，商城按钮消失，请使用恢复命令：/twshop showbutton，如果依然不能恢复，我们建议您重装客户端。祝您游戏愉快！",
                    title = "商城图标消失",
                },
                 {
                    text = "你好，商城问题会有专人为你处理或者回复，这可能会需要几个工作日。已上报，请不要撤回本工单。",
                    title = "商城回复1",
                },
                 {
                    text = "重新提交工单描述 项目要退还的物品名称：   数量：  等待商城工作人员处理。这可能会需要几个工作日。",
                    title = "商城回复2",
                },
                 {
                    text = "您好，捐赠属于玩家自愿，目前只有重复购买以及购买的物品无法使用等情况，我们才视为错误购买。没帮到您，很遗憾！",
                    title = "商城拒退",
                },
                 {
                    text = "您好，GM必须严格执行Twow规则，以保护遵守规则的Twow玩家。很抱歉，无法为你更改处罚决定。",
                    title = "申诉驳回",
                },
                 {
                    text = "请到荆棘谷31.8 ，70.9 找到血帆叛徒接取任务。",
                    title = "血帆叛徒",
                },
                 {
                    text = "你好！如果一件重要物品被出售了,请前往垃圾收集者处找回，该npc已经更换位置,联盟在暴风城贸易区(60,69)部落在幽暗城(72,36)处能找到他。",
                    title = "物品找回",
                },
                 {
                    text = "乌龟亚服官网：https://cn.turtle-wow.org/",
                    title = "官网地址",
                },
                 {
                    text = "您好！相同问题创建多个工单或报复性举报这类滥用工单的行为，GM警告：希望你能跟GM团队一起维护环境而不是滥用工单系统。",
                    title = "滥用工单",
                },
                 {
                    text = "您好，创个小号，捏你喜欢的脸。然后回到大号，聊天框输入“.copy 小号id”即可。",
                    title = "外观无效",
                },
                 {
                    text = "您好！请将公会申请表放入你的主背包中，然后再试一次。",
                    title = "公会无法创建",
                },
            },
            alpha = 1
        }
    end


    _G['TGM']:SetScale(TGM_DATA.scale)
    _G['TGM']:SetAlpha(TGM_DATA.alpha)
    TGM.triggerCount=0
    TGM_DATA.server=GetRealmName()
    TGM.disableButtonsAndText()
end

function TGM.clearScrollbarTexture(frame)
    _G[frame:GetName() .. 'ScrollUpButton']:SetNormalTexture(nil)
    _G[frame:GetName() .. 'ScrollUpButton']:SetDisabledTexture(nil)
    _G[frame:GetName() .. 'ScrollUpButton']:SetPushedTexture(nil)
    _G[frame:GetName() .. 'ScrollUpButton']:SetHighlightTexture(nil)

    _G[frame:GetName() .. 'ScrollDownButton']:SetNormalTexture(nil)
    _G[frame:GetName() .. 'ScrollDownButton']:SetDisabledTexture(nil)
    _G[frame:GetName() .. 'ScrollDownButton']:SetPushedTexture(nil)
    _G[frame:GetName() .. 'ScrollDownButton']:SetHighlightTexture(nil)

    _G[frame:GetName() .. 'ThumbTexture']:SetTexture(nil)
end

function TGM.disableButtonsAndText()
    TGMLeftPanelResponsePlayerName:SetText()
    TGMLeftPanelResponseAccount:SetText()
    TGMLeftPanelResponseIP:SetText()
    TGMLeftPanelResponseLevel:SetText()
    TGMLeftPanelResponseEmail:SetText()
    TGMLeftPanelResponseForum:SetText()
    TGMLeftPanelResponseOnlineStatus:SetText()
    TGMLeftPanelResponseRaceClass:SetText()

    TGMLeftPanelResponseRespondToMailbox:Disable()
    TGMLeftPanelResponseRespondToChat:Disable()
    TGMLeftPanelResponseCloseTicket:Disable()

    TGMLeftPanelResponseGoTo:Disable()
    TGMLeftPanelResponseSummon:Disable()
    TGMLeftPanelResponseInfo:Disable()
    TGMLeftPanelResponseRecall:Disable()
    TGMLeftPanelResponseBaninfo:Disable()
    TGMLeftPanelResponseTarget:Disable()
    TGMLeftPanelResponseShopLog:Disable()

    TGMLeftPanelResponsePlayerNameCopyButton:Disable()
    TGMLeftPanelResponseAccountCopyButton:Disable()
    TGMLeftPanelResponseIPCopyButton:Disable()
end

function TGM.enableButtons()
    TGMLeftPanelResponseRespondToMailbox:Enable()
    TGMLeftPanelResponseRespondToChat:Enable()
    TGMLeftPanelResponseCloseTicket:Enable()

    TGMLeftPanelResponseGoTo:Enable()
    TGMLeftPanelResponseSummon:Enable()
    TGMLeftPanelResponseInfo:Enable()
    TGMLeftPanelResponseRecall:Enable()
    TGMLeftPanelResponseBaninfo:Enable()
    TGMLeftPanelResponseTarget:Enable()
    TGMLeftPanelResponseShopLog:Enable()

    TGMLeftPanelResponsePlayerNameCopyButton:Enable()
    TGMLeftPanelResponseAccountCopyButton:Enable()
    TGMLeftPanelResponseIPCopyButton:Enable()
end



-- Function to find and remove or add a string
function findAndModifyString(array, searchString)
    local found = false

    for i, str in ipairs(array) do
        if str == searchString then
            -- String exists in the array, so remove it
            table.remove(array, i)
            found = true
            break
        end
    end

    if not found then
        -- String doesn't exist, so add it
        table.insert(array, searchString)
    end
end


function TGM_AccCheckAll()

    local checked = _G['TGMLookupPanelCheckAllButton']:GetChecked()

    
    if (__length(TGM.BanAccList)>0 and not checked) then
        for i, str in ipairs(TGM.iplist) do    
            _G["TGMIpLookup_"..i.."CheckButton"]:SetChecked(false)
        end
        TGM.BanAccList={}
        _G['TGMLookupPanelCheckAllButton']:SetChecked(false)
    else
        for i, str in ipairs(TGM.iplist) do
            _G["TGMIpLookup_"..i.."CheckButton"]:SetChecked(true)
            table.insert(TGM.BanAccList, TGM.iplist[i].name)
        end

    end
    _G['TGMLookupPanelFooterText']:SetText("已选中 "..__length(TGM.BanAccList).." 账号")

end


function TGM_AccCheck(id)

    Dump(table.concat(TGM.iplist[id].char, "\n"))
    findAndModifyString(TGM.BanAccList,TGM.iplist[id].name)

    _G['TGMLookupPanelFooterText']:SetText("已选中 "..__length(TGM.BanAccList).." 账号")

end


function Lookup_OnLoad()



    UIDropDownMenu_Initialize(this, function()

        for id, type in pairs(TGM.lookuptypes) do
            local info = {}
            info.text = type
            info.value = id
            info.arg1 = id
            info.checked = LUP_TYPE == id
            info.func = Lookup_OnClick
            UIDropDownMenu_AddButton(info)
        end
       
    end)
    UIDropDownMenu_SetWidth(80, TGMBottomPanelLookupCMDSelect);

end

function Lookup_OnClick(a)
    LUP_TYPE = a
    UIDropDownMenu_SetText(TGM.lookuptypes[LUP_TYPE], _G['TGMBottomPanelLookupCMDSelect'])

 

   

end    

function TGM_LookupCheck()

    local targetName = UnitName("target")
    local r = UIDropDownMenu_GetText( _G['TGMBottomPanelLookupCMDSelect'])
    local id = TGMBottomPanelIDBox:GetText()
    local cmd =''

    Dump(r)
    if targetName == nil then

        _G['TGMBottomPanellookuptext']:SetText('目标玩家：|cffffffff没有目标')

        if r=='物品' then
         cmd = '.lookup item '..id
        end

           if r=='任务' then
            cmd = '.lookup quest '..id
           end
        
    else

        _G['TGMBottomPanellookuptext']:SetText('目标玩家：|cffffffff'..targetName)


        if r=='物品' then
             cmd = '.char hasitem '..id
        end
       

       if r=='任务' then
        cmd = '.quest status '..id
       end

    end   


    SendChatMessage(cmd)
    Dump(cmd)




end


function TGM_LookupDel()

    local targetName = UnitName("target")
    local r = UIDropDownMenu_GetText( _G['TGMBottomPanelLookupCMDSelect'])
    local id = TGMBottomPanelIDBox:GetText()
    local cmd =''

    Dump(r)
    if targetName == nil then

        _G['TGMBottomPanellookuptext']:SetText('目标玩家：|cffffffff没有目标')

        Dump("请选择一个目标")
        return
    else

        _G['TGMBottomPanellookuptext']:SetText('目标玩家：|cffffffff'..targetName)


        if r=='物品' then
             cmd = '.deleteitem '..id..' 1 '..targetName
        end
       

       if r=='任务' then        
            cmd = '.quest remove '..id..' '..targetName
       end

    end   


    SendChatMessage(cmd)
    Dump(cmd)



end




function Goto_OnLoad()
    UIDropDownMenu_Initialize(this, function()

        for id, type in pairs(TGM.gotogps) do
            local info = {}
            info.text = type
            info.value = id
            info.arg1 = id
            info.checked = GOTO_TYPE == id
            info.func = Goto_OnClick
            UIDropDownMenu_AddButton(info)
        end
       
    end)
    UIDropDownMenu_SetWidth(150, TGMLeftPanelResponseGotoSelect);   
    UIDropDownMenu_SetText('快捷传送地点', _G['TGMLeftPanelResponseGotoSelect'])
end

function Goto_OnClick(a)
    GOTO_TYPE = a

    Dump(a)

    if a == 1 then
    SendChatMessage(".go -8852.03 652.88 96.46 0")
    end

    if a == 2 then
    SendChatMessage(".go 1502.71 -4415.43 21.56 1")
end

    if a == 3 then
    SendChatMessage(".go -9443.45 59.89 56.07 0")
end

    if a == 4 then
    SendChatMessage(".go -456.26 -2652.7 95.62 1")
end
    if a == 5 then
    SendChatMessage(".go -1996.20 2603.95 62.18 1")
end
    if a == 6 then
    SendChatMessage(".go -3129.38 -2864.51 34.8711 1")
end
    if a == 7 then
    SendChatMessage(".go -6907.88 -4831.81 8.25 1")
end    



    
end		

function BanType_OnLoad()
    UIDropDownMenu_Initialize(this, function()

        for id, type in pairs(TGM.bantypes) do
            local info = {}
            info.text = type
            info.value = id
            info.arg1 = id
            info.checked = BAN_TYPE == id
            info.func = BanType_OnClick
            UIDropDownMenu_AddButton(info)
        end
       
    end)
    UIDropDownMenu_SetWidth(150, TGMLookupPanelTypeSelect);
end





function BanType_OnClick(a)
    BAN_TYPE = a
    UIDropDownMenu_SetText(TGM.bantypes[BAN_TYPE], _G['TGMLookupPanelTypeSelect'])
    
end



function BanDue_OnLoad()
    UIDropDownMenu_Initialize(this, function()

        for id, type in pairs(TGM.bandue) do
            local info = {}
            info.text = type
            info.value = id
            info.arg1 = id
            info.checked = BAN_DUE == id
            info.func = BanDue_OnClick
            UIDropDownMenu_AddButton(info)
        end
       
    end)
    UIDropDownMenu_SetWidth(80, TGMLookupPanelDueSelect);
end

function BanDue_OnClick(a)
    BAN_DUE = a
    UIDropDownMenu_SetText(TGM.bandue[BAN_DUE], _G['TGMLookupPanelDueSelect'])
    
end




function TGM_BanAccList()

    local dd=''

    local r = UIDropDownMenu_GetText( _G['TGMLookupPanelTypeSelect'])
 
    if r == '' or r == nil then
        Dump('请选择封禁理由')
        return
    end

    local  d= UIDropDownMenu_GetText( _G['TGMLookupPanelDueSelect'])
 
    if d == '' or d == nil then
        Dump('请选择封禁时间')
        return
    end

    if d == '永久' then
      dd = "-1"
    end

    if d== '7天' then
        dd="7d"
    end

    if d=='30天' then
        dd = '30d'
    end
    

    
    for i, acc in ipairs(TGM.BanAccList) do
    Dump('.ban acc \'' .. acc ..'\' '..dd..' \''.. r ..'\'')
    SendChatMessage('.ban acc \'' .. acc ..'\' '..dd..' \''.. r ..'\'')
    --  SendChatMessage('.ban acc \'' .. acc ..'\' -1 \'工作室/脚本/外挂/多开/第三方工具\'')  
   
    local key= acc .. '_banby_' .. UnitName('player').."-1" .. date("%Y%m%d")

    TGM_BAN_DATA.data[key] = {
        hash = key,    
        account = acc,
        command = 'ban acc',
        due = dd,
        note = r,
        gm = UnitName('player'),
        realm = TGM.realm,
        date =  date("%A, %d %B %Y  %H:%M:%S")
    }

    end

end


local  col, row = 1, 1
local ban=0

TGM.lookupFrames={}

function TGM.handleSysMessage(s) 
 

if string.find(s, "No players found!", 1, true) then
TGM.iplist = {}
col, row = 1, 1
ban =0

for _, frame in next, TGM.lookupFrames do   
    frame:Hide()
end

elseif string.find(s, 'at account', 1, true) then
ban =0
ltooltipText=tooltipText
tooltipText=""

local i=__length(TGM.iplist) + 1

if string.find(s, '[BANNED]', 1, true) then
    ban=1
end
if not TGM.lookupFrames[i] then
TGM.lookupFrames[i]=CreateFrame("Frame", "TGMIpLookup_" ..i, TGMLookupPanel, "TGMIpLookupTemplate")
end
local frame = "TGMIpLookup_" ..i 
local lframe = "TGMIpLookup_" .. i-1

_G[frame]:SetPoint("TOPLEFT", TGMLookupPanel, "TOPLEFT", 11-160+160*col, -50+26-26 * row)
    local t = __explode(s, ' ')
    local acc=""
    if t[5]=="(Id:" or t[5]=="[BANNED]"then
     acc=t[4]
    elseif t[6]=="(Id:" or t[6]=="[BANNED]"then
     acc=t[4].." "..t[5]
    elseif t[7]=="(Id:" or t[7]=="[BANNED]"then
    acc=t[4].." "..t[5].." "..t[6]
    end


    _G[frame .. 'CheckButton']:SetID(i)
    _G[frame .. 'CheckButton']:SetChecked(false)


-- Function to show the tooltip
if i>1 then 
_G[lframe .. 'CheckButton']:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
    GameTooltip:SetText(table.concat(TGM.iplist[i-1].char, "\n"))
    GameTooltip:Show()
end)

-- Function to hide the tooltip
_G[lframe .. 'CheckButton']:SetScript("OnLeave", function(self)
  GameTooltip:Hide()
end)
end

    _G[frame .. 'TicketIndex']:SetText('|cffffffff' .. i)    
    _G[frame .. 'TicketTextShort']:SetText(acc)
    if ban == 1 then
        _G[frame .. 'TicketTextShort']:SetTextColor(0.5,0.5,0.5,1)
        _G[frame .. 'CheckButton']:Hide()
    else
        _G[frame .. 'CheckButton']:Show()
        _G[frame .. 'TicketTextShort']:SetTextColor(0,1,0,1)
    end


    _G[frame]:Show()

    col = col + 1

    if col > 3 then
        col = 1
        row = row + 1
    end

    TGM.iplist[i] = {
        
        id =  t[4],
        name = acc,
        ban = ban,
        char = {}
    }

elseif string.find(s, ' - ', 1, true) then   

--    CreateFrame("Frame", "TGMIpLookupTemplate_" .. count, TGMLookupPanel, "TGMIpLookupTemplate")
--    local frame = "TGMIpLookupTemplate_" .. count
 --   _G[frame .. 'TicketTextShort']:SetText(s)
 --   _G[frame]:Show()
    if __length(TGM.iplist)>0 then
    TGM.iplist[__length(TGM.iplist)] .char[__length(TGM.iplist[__length(TGM.iplist)] .char) + 1]=s

    end
end

if string.find(s, "Anticheat messages will be hidden", 1, true) then

SendChatMessage(".anticheat cheatinform")
    
end

if string.find(s, "AntiCheat", 1, true) then
        -- SendChatMessage(s)
             local s = string.gsub(s,'|', '')
            local m = __explode(s, ":")
            local n = __explode(m[3], " ") 
            local cheater={}
         
        --  Dump(n[2])

          -- 要添加的字符串
        cheater.name = n[2]
        cheater.bot = 0
        cheater.count = 1

        if string.find(s, "possible bot", 1, true) then  
        cheater.bot = 3
        end

        if string.find(s, "MultiJump", 1, true) then  
         cheater.bot = 1
        end

        if string.find(s, "gate", 1, true) then  
            cheater.bot = 2
        end
   
        if string.find(s, "door", 1, true) then  
            cheater.bot = 2
        end

        if cheater.name ~="<none>" then
            -- 检查字符串是否已存在于表中
            local isUnique = true
            for i, str in ipairs(TGM.CheaterList) do
                if str.name == cheater.name then
                    isUnique = false
                    TGM.CheaterList[i].count = TGM.CheaterList[i].count + 1
                    break
                end
            end

            -- 如果字符串是唯一的，则添加到表中
            if isUnique then
                table.insert(TGM.CheaterList, cheater)
                TGM.processCheaterList()
            end
     end

end

if string.find(s, "PassiveAnticheat", 1, true) then
    -- SendChatMessage(s)
    --     local s = string.gsub(s,'|', '')
    --    local m = __explode(s, ":")
    --    local n = __explode(m[2], " ")
      
    --  Dump(m[2])
  --    Dump(n[4])

end

    if string.find(s, "guid", 1, true) then

        local m = string.gsub(s,'|', '')
        local m = string.gsub(m,'h%[', '||')
        local m = string.gsub(m,'%]h', '||')

        local pinfo = __explode(m, "||")

      TGMBottomPanelInputBox:SetText(pinfo[2]) 
      TGMBottomPanelInputBoxAcc:SetText(pinfo[4])  
      
    
       local pinfo2 =__explode(pinfo[5], ":")

       TGMBottomPanelInputBoxIp:SetText(pinfo2[5])  

     return
    end


end

function Dump(variable)
    if type(variable) == "table" then
        for key, value in pairs(variable) do
            DEFAULT_CHAT_FRAME:AddMessage(tostring(key) .. ": " .. tostring(value))
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage(tostring(variable))
    end
end

function TGM.handleSystemMessage(text)

           -- refresh tickets on ticket assign


    -- refresh tickets on new ticket
    if string.find(text, "New ticket", 1, true) then
		PlaySoundFile("Sound\\Interface\\igTextPopupPing02.wav")
       --  TGM_refreshTickets()
        return
    end

    -- refresh tickets on ticket assign
    if string.find(text, "Ticket", 1, true) and
            string.find(text, "Assigned to", 1, true) then
      --   TGM_refreshTickets()
        return
    end

    -- stop if no ticket is active
    if not TGM.ticket then
        return
    end




end

function TGM.handleAddonMessage(m)

    if string.find(m, 'tickets;;start', 1, true) then
        TGM.tickets = {}
    elseif string.find(m, 'tickets;;end', 1, true) then
        TGM.processTickets()
    elseif string.find(m, 'tickets;;', 1, true) then

        --tickets;;id;;name;;playeronlinestatus;;ticketassignedstatus;;tickettimestamp;;ticket_text

        local t = __explode(m, ';;')

        local stamp = string.format(SecondsToTime(time() - tonumber(t[6])))

        TGM.tickets[__length(TGM.tickets) + 1] = {
            id = tonumber(t[2]),
            name = t[3],
            onlineStatus = t[4] == 'online' and '|cff00ff00在线' or '|cffff0000离线',
            assigned = t[5],
            stamp = stamp,
            message = t[7],
            message_replaced = __replace(t[7], "\n", ""),
        }

    elseif string.find(m, 'playerinfo;;', 1, true) then

        --playerinfo;;guid;;account;;ip;;level;;email;;forumusername;;race;;class

        local pi = __explode(m, ";;")
        local guid = pi[2]
        local account = pi[3]
        local ip = pi[4]
        local level = tonumber(pi[5])
        local email = pi[6]
        local forum = pi[7]
        local race = pi[8]
        local class = pi[9]

        if TGM.ticket then
            TGM.ticket.guid = guid
            TGM.ticket.account = account
            TGM.ticket.ip = ip
            TGM.ticket.level = level
            TGM.ticket.email = email
            TGM.ticket.forum = forum
            TGM.ticket.raceClass = TGM.races[tonumber(race)] ..
                    " |c" ..
                    TGM.classColors[string.upper(TGM.classes[tonumber(class)])].colorStr ..
                    TGM.classes[tonumber(class)]

            TGMLeftPanelResponseTitle:SetText("工单 |cffffffff" .. TGM.ticket.id .. " |r已 |cffffffff" ..
                    TGM.ticket.stamp .. "|r之前创建 |c" .. TGM.classColors[string.upper(TGM.classes[tonumber(class)])].colorStr .. TGM.ticket.name)

            TGMLeftPanelResponsePlayerName:SetText("姓名: |cffffffff" .. TGM.ticket.name)
            TGMLeftPanelResponsePlayerNameCopyEditbox:SetText(TGM.ticket.name)
            TGMLeftPanelResponseAccount:SetText("账户: |cffffffff" .. TGM.ticket.account)
            TGMLeftPanelResponseAccountCopyEditbox:SetText(TGM.ticket.account)
            TGMLeftPanelResponseIP:SetText("IP地址: |cffffffff" .. TGM.ticket.ip)
            TGMLeftPanelResponseLevel:SetText("等级: |cffffffff" .. TGM.ticket.level)
            TGMLeftPanelResponseEmail:SetText("邮箱: |cffffffff" .. TGM.ticket.email)
            TGMLeftPanelResponseForum:SetText("论坛: |cffffffff" .. TGM.ticket.forum)
            TGMLeftPanelResponseOnlineStatus:SetText("在线状态: |cffffffff" .. TGM.ticket.onlineStatus)
            TGMLeftPanelResponseRaceClass:SetText("种族/职业: |cffffffff" .. TGM.ticket.raceClass)

            TGMLeftPanelResponseTicketScrollFrameTicketBox:SetText(TGM.ticket.message)

            TGMLeftPanelResponseCloseTicket:SetID(TGM.ticket.id)

            TGM.enableButtons()

            TGMLeftPanelResponseReplyScrollFrameReplyBox:SetText('')
            TGMLeftPanelResponseReplyScrollFrameReplyBox:ClearFocus()

        end
    end
end



-- Function to compare two entries based on the 'bot' and 'count' fields
local function compareByBotThenCount(a, b)
    if a.bot ~= b.bot then
        -- First, compare by 'bot' field
        return a.bot > b.bot
    else
        -- If 'bot' fields are equal, then compare by 'count' field
        return a.count > b.count
    end
end


function TGM.processCheaterList()

    --排序
    table.sort(TGM.CheaterList, compareByBotThenCount)


    local  col, row = 1, 1

    for i, frame in next, TGM.cheaterFrames do
        frame:Hide()
    end
    _G['TGMAntiCheatPanelTitle']:SetText('标识：|cffff0000机器人|cffffffff（怀疑）|cffff9c00瞬移|cffffffff（需查证）|cffff9bff穿门|cffffffff（需查证）')


    for i, data in next, TGM.CheaterList do
        --只显示前48个
        if i <=48 then 

                if not TGM.cheaterFrames[i] then
                    TGM.cheaterFrames[i] = CreateFrame("Frame", "TGM_Cheater_" .. i, TGMAntiCheatPanel, "TGMAntiCheatTemplate")
                end

                local frame = "TGM_Cheater_" .. i

                _G[frame]:SetPoint("TOPLEFT", TGMAntiCheatPanel, "TOPLEFT", 11-160+160*col, -50+26-26 * row)

                _G[frame .. 'TicketIndex']:SetText('|cffffffff' .. i)
                _G[frame .. 'TicketTextShort']:SetText(data.name)
                if data.bot ==0 then
                    _G[frame .. 'TicketTextShort']:SetTextColor(1,1,1,1) --白色
            elseif data.bot ==3 then
                    _G[frame .. 'TicketTextShort']:SetTextColor(1,0,0,1) --红色
                elseif data.bot ==1 then
                    _G[frame .. 'TicketTextShort']:SetTextColor(1,0.61,0,1) --黄色
                elseif data.bot ==2 then
                    _G[frame .. 'TicketTextShort']:SetTextColor(1,0.61,1,1) --粉色     
                end
                _G[frame .. 'AntiCheatButtonFly']:SetID(i)
                _G[frame .. 'AntiCheatButtonFly']:SetText(data.count)
                _G[frame .. 'AntiCheatButtonDel']:SetID(i)
                _G[frame]:Show()

                col = col + 1
            
                if col > 3 then
                    col = 1
                    row = row + 1
                end
        end

    end


    
end

function TGM_AntiCheatButtonFly(id)
    local cheater=TGM.CheaterList[id]
    if cheater ~= nil then
    SendChatMessage(".pinfo "..cheater.name)
    SendChatMessage(".goname "..cheater.name)
    else
        TGM.processCheaterList()
    end
end

function TGM_AntiCheatButtonDel(id)
   
    
    table.remove(TGM.CheaterList, id)
    local newTable = {}
    local newIndex = 1
    for _, value in pairs(TGM.CheaterList) do
        newTable[newIndex] = value
        newIndex = newIndex + 1
    end
    TGM.CheaterList=newTable
    TGM.processCheaterList()
end

function TGM.processTickets()

    for i, frame in next, TGM.ticketFrames do
        frame:Hide()
    end

    local c=1

    local reversedArray = {}
    if(TGM.sort == '↑') then
      

        for i = __length(TGM.tickets), 1, -1 do
            table.insert(reversedArray, TGM.tickets[i])
        end
        TGM_DATA.ticketlast=TGM.tickets[1].id;
    else
        reversedArray=TGM.tickets
        TGM_DATA.ticketlast=TGM.tickets[__length(TGM.tickets)].id;
    end


    for i, data in next, reversedArray do

                if TGM.flag == '0' then 
                    if not TGM.ticketFrames[i] then
                        TGM.ticketFrames[i] = CreateFrame("Frame", "TGM_Ticket_" .. i, TGMRightPanelScrollFrameChild, "TGMTicketTemplate")
                    end

                    local frame = "TGM_Ticket_" .. i

                    _G[frame]:SetPoint("TOPLEFT", TGMRightPanelScrollFrameChild, "TOPLEFT", 11, 26 - 26 * i)

                    _G[frame .. 'TicketIndex']:SetText('|cffffffff' .. i)
                    _G[frame .. 'PlayerName']:SetText(data.name)
                    _G[frame .. 'TicketTextShort']:SetText(string.sub(data.message_replaced, 1, 35) .. '...')
                    _G[frame .. 'AssignButton']:SetID(data.id)
                    _G[frame .. 'ManageTicket']:SetID(data.id)
                    _G[frame .. 'ForceDelButton']:SetID(data.id)

                    _G[frame .. 'Selected']:Hide()

                    if TGM.ticket and data.id == TGM.ticket.id then
                        _G[frame .. 'Selected']:Show()
                    end

                    if data.assigned == '0' then
                        _G[frame .. 'AssignButton']:SetText('分配')
                    else
                        _G[frame .. 'AssignButton']:SetText('|cffffffff' .. data.assigned)
                    end
                    _G[frame]:Show()
                elseif TGM.flag == '1' and data.assigned == '0' then
                
                        if not TGM.ticketFrames[i] then
                            TGM.ticketFrames[i] = CreateFrame("Frame", "TGM_Ticket_" .. i, TGMRightPanelScrollFrameChild, "TGMTicketTemplate")
                        end
    
                        local frame = "TGM_Ticket_" .. i
    
                        _G[frame]:SetPoint("TOPLEFT", TGMRightPanelScrollFrameChild, "TOPLEFT", 11, 26 - 26 * c)
    
                        _G[frame .. 'TicketIndex']:SetText('|cffffffff' .. i)
                        _G[frame .. 'PlayerName']:SetText(data.name)
                        _G[frame .. 'TicketTextShort']:SetText(string.sub(data.message_replaced, 1, 35) .. '...')
                        _G[frame .. 'AssignButton']:SetID(data.id)
                        _G[frame .. 'ManageTicket']:SetID(data.id)
    
                        _G[frame .. 'Selected']:Hide()
    
                        if TGM.ticket and data.id == TGM.ticket.id then
                            _G[frame .. 'Selected']:Show()
                        end
    
                        if data.assigned == '0' then
                            _G[frame .. 'AssignButton']:SetText('分配')
                        else
                            _G[frame .. 'AssignButton']:SetText('|cffffffff' .. data.assigned)
                        end
                        _G[frame]:Show()
                        c = c + 1
                elseif TGM.flag == '2' and data.assigned == UnitName('player') then    
                   
                        if not TGM.ticketFrames[i] then
                            TGM.ticketFrames[i] = CreateFrame("Frame", "TGM_Ticket_" .. c, TGMRightPanelScrollFrameChild, "TGMTicketTemplate")
                        end
    
                        local frame = "TGM_Ticket_" .. i
    
                        _G[frame]:SetPoint("TOPLEFT", TGMRightPanelScrollFrameChild, "TOPLEFT", 11, 26 - 26 * c)
    
                        _G[frame .. 'TicketIndex']:SetText('|cffffffff' .. i)
                        _G[frame .. 'PlayerName']:SetText(data.name)
                        _G[frame .. 'TicketTextShort']:SetText(string.sub(data.message_replaced, 1, 35) .. '...')
                        _G[frame .. 'AssignButton']:SetID(data.id)
                        _G[frame .. 'ManageTicket']:SetID(data.id)
    
                        _G[frame .. 'Selected']:Hide()
    
                        if TGM.ticket and data.id == TGM.ticket.id then
                            _G[frame .. 'Selected']:Show()
                        end
    
                        if data.assigned == '0' then
                            _G[frame .. 'AssignButton']:SetText('分配')
                        else
                            _G[frame .. 'AssignButton']:SetText('|cffffffff' .. data.assigned)
                        end
                        _G[frame]:Show()
                        c = c+ 1
                end
                
    end

    if (TGM.flag == '0') then
       TGMRightPanelTicketCount:SetText('工单 (' .. __length(TGM.tickets) .. ')')
    else
        TGMRightPanelTicketCount:SetText('工单 (' .. c-1 .. '/'..__length(TGM.tickets)..')')
    end
    TGM_DATA.tickets=__length(TGM.tickets);
    TGMRightPanelSortButton:SetText(TGM.sort)
    TGMRightPanelScrollFrame:UpdateScrollChildRect();
    TGMRightPanelScrollFrame:SetVerticalScroll(0)

    TGM.clearScrollbarTexture(TGMRightPanelScrollFrameScrollBar)


end

function TGM_AssignTicket(id)

    for _, data in next, TGM.tickets do
        if data.id == id then
            if data.assigned == '0' then
                SendChatMessage('.ticket unassign ' .. id)
                SendChatMessage('.ticket assign ' .. id .. ' ' .. UnitName('player'))
            else
                SendChatMessage('.ticket unassign ' .. id)
            end
        end
    end
    --TGM_refreshTickets()
end

function TGM_DeleteTicket(id)



    for _, data in next, TGM.tickets do
        if data.id == id then
         --   if data.assigned == '0' then
          --      TGM_CloseTicket(id)
          --  else
                SendChatMessage('.ticket unassign ' .. id)
                TGM_CloseTicket(id)
         --   end
        end
    end


end

function TGM_ManageTicket(id)
    
    TGM.ticket = {}
    for i, data in next, TGM.tickets do
        if data.id == id then
            TGM.ticket = data
            _G["TGM_Ticket_" .. i .. 'Selected']:Show()
            _G["TGM_Ticket_" .. i .. 'Selected']:SetVertexColor(1, 1, 1, 0.2)
        elseif  _G["TGM_Ticket_" .. i .. 'Selected'] ~= nil then
            _G["TGM_Ticket_" .. i .. 'Selected']:Hide()
           
        end
    end

    if not TGM.ticket.name then
        return
    end

    TGM.send("PLAYER_INFO:" .. TGM.ticket.name)
    -- rest is in addon_message handler
end

function TGM_filterTickets()
    TGM.flag = "1"
    TGM_refreshTickets() 
end

function TGM_filterNoneTickets()
    TGM.flag = "0"
    TGM_refreshTickets() 
end

function TGM_filterOwnTickets()
    TGM.flag = "2"
    TGM_refreshTickets() 
end

function TGM_refreshTickets()

    TGM.send("GET_TICKETS")
end

function TGM_CloseTicket(id)
    SendChatMessage('.ticket close ' .. id)

    TGMLeftPanelResponseTicketScrollFrameTicketBox:SetText('')
    TGMLeftPanelResponseTicketScrollFrameTicketBox:ClearFocus()
    TGMLeftPanelResponseReplyScrollFrameReplyBox:SetText('')
    TGMLeftPanelResponseReplyScrollFrameReplyBox:ClearFocus()

    TGM.disableButtonsAndText()
    TGM_refreshTickets()

    TGM.ticket = nil
end

function TGM_MailPlayer()

    local text = TGMLeftPanelResponseReplyScrollFrameReplyBox:GetText()
    if text == '' then
        return
    end

    SendChatMessage('.send mail ' .. TGM.ticket.name .. ' "Ticket" "' .. text .. '"')

    TGMLeftPanelResponseReplyScrollFrameReplyBox:SetText('')
    TGMLeftPanelResponseReplyScrollFrameReplyBox:ClearFocus()
end

function TGM_WhisperPlayer()
    local text = TGMLeftPanelResponseReplyScrollFrameReplyBox:GetText()
    if text == '' then
        return
    end

    SendChatMessage(text, "WHISPER", DEFAULT_CHAT_FRAME.editBox.languageID, TGM.ticket.name);

    TGMLeftPanelResponseReplyScrollFrameReplyBox:SetText('')
    TGMLeftPanelResponseReplyScrollFrameReplyBox:ClearFocus()
end


-- add by k8o

function TGM_changeSort()


   if(TGM.sort == '↓') then
    TGM.sort = '↑'
   else
    TGM.sort = '↓'
   end

   TGMRightPanelSortButton:SetText(TGM.sort)
   TGM_refreshTickets()

end


function TGM_GoToPlayer2()

    local text = TGMBottomPanelInputBox:GetText()
    if text == '' then
        return
    end

    SendChatMessage('.goname ' .. text)
end

function TGM_PlayerInfo2()

    TGMBottomPanelInputBoxAcc:SetText('')
    TGMBottomPanelInputBoxIp:SetText('')
    local text = TGMBottomPanelInputBox:GetText()
    if text == '' then
        return
    end
    SendChatMessage('.char hasitem 81118 ' .. text)
    SendChatMessage('.pinfo ' .. text)
    SendChatMessage('.baninfo character ' .. text)
    
    
    
end


function TGM_PlayerLookupAcc()

--    TGMBottomPanelInputBoxAcc:SetText('')
    local text = TGMBottomPanelInputBoxAcc:GetText()
    if text == '' then
        return
    end

    SendChatMessage('.bi '.. text) 
    SendChatMessage('.lookup player account \'' .. text..'\'')
    
end

function TGM_PlayerLookupIp()

    TGM_ToggleLookup()
    local text = TGMBottomPanelInputBoxIp:GetText()
    if text == '' then
        return
    end

    
    SendChatMessage('.lookup player ip ' .. text)
    
end


function TGM_PlayerLookup()

    local text = TGMBottomPanelInputBox:GetText()
    if text == '' then
        return
    end

    SendChatMessage('.lookup player character ' .. text)
end




function TGM_PlayerSummon()

    local text = TGMBottomPanelInputBox:GetText()
    if text == '' then
        return
    end

    SendChatMessage('.summon ' .. text)
end


function TGM_PlayerKick()

    local text = TGMBottomPanelInputBox:GetText()
    if text == '' then
        return
    end

    SendChatMessage('.kick ' .. text ..' -force')
end



function TGM_PlayerWarn()

    local id = TGMBottomPanelInputBox:GetText()
    if id == '' then
        return
    end
	
	local note = TGMBottomPanelNoteBox:GetText()
    if note == '' then
        return
    end

--	local msg = '警告原因：' ..note.. ' 请确认收到并回复!'
	
    SendChatMessage('.ban warn ' .. id ..' ' ..note )
--	SendChatMessage(msg, "WHISPER", DEFAULT_CHAT_FRAME.editBox.languageID, id)
    
end



function TGM_PlayerBan()

    local id = TGMBottomPanelInputBox:GetText()
    if id == '' then
        return
    end

	local note = TGMBottomPanelNoteBox:GetText()
    if note == '' then
        return
    end
	
	local due = TGMBottomPanelDueBox:GetText()
    if note == '' then
        return
    end
	
    SendChatMessage('.ban character ' .. id ..' '.. due ..' '..note)

    local key= id .. '_banby_' .. UnitName('player')..due .. date("%Y%m%d")

    TGM_BAN_DATA.data[key] = {
        hash = key,    
        account = id,
        command = 'ban char',
        due = due,
        note = note,
        gm = UnitName('player'),
        realm = TGM.realm,
        date =  date("%A, %d %B %Y  %H:%M:%S")
    }

end

function TGM_PlayerBanAcc()

    local id = TGMBottomPanelInputBoxAcc:GetText()
    if id == '' then
        return
    end

	local note = TGMBottomPanelNoteBox:GetText()
    if note == '' then
        return
    end
	
	local due = TGMBottomPanelDueBox:GetText()
    if note == '' then
        return
    end
	
    SendChatMessage('.ban acc \'' .. id ..'\' '.. due ..' \''..note..'\'')

    local key= id .. '_banby_' .. UnitName('player')..due .. date("%Y%m%d")

    TGM_BAN_DATA.data[key] = {
        hash = key,    
        account = id,
        command = 'ban acc',
        due = due,
        note = note,
        gm = UnitName('player'),
        realm = TGM.realm,
        date =  date("%A, %d %B %Y  %H:%M:%S")
    }

end


function TGM_PlayerMute()

    local id = TGMBottomPanelInputBox:GetText()
    if id == '' then
        return
    end
	
    local note = TGMBottomPanelNoteBox:GetText()
    
    if note == nil then
        note = ''
    end

	local due = TGMBottomPanelDueBox:GetText()
    if due == '' then
        return
    end
	
    SendChatMessage('.mute ' .. id ..' '.. due)

    
    local key= id .. '_muteby_' .. UnitName('player')..due..date("%Y%m%d")

    TGM_BAN_DATA.data[key] = { 
                hash = key,       
                account = id,
                command = 'mute',                
                due = due,
                note = note,                
                gm = UnitName('player'),
                realm = TGM.realm,
                date =  date("%A, %d %B %Y  %H:%M:%S")
            }
	
end

-- end add by k8o


function TGM_GoToPlayer()
    SendChatMessage('.goname ' .. TGM.ticket.name)
end

function TGM_SummonPlayer()
    SendChatMessage('.summon ' .. TGM.ticket.name)
end

function TGM_PlayerInfo()
    SendChatMessage('.pinfo ' .. TGM.ticket.name)
end

function TGM_Target()
    TargetByName(TGM.ticket.name)
end

function TGM_BanInfo()
    SendChatMessage('.baninfo account ' .. TGM.ticket.account)
end

function TGM_Recall()
    SendChatMessage('.recall ' .. TGM.ticket.name)
end

function TGM_ShopLog()
    SendChatMessage('.shop log ' .. TGM.ticket.account)
end

function TGM_Toggle()
    if _G['TGM']:IsVisible() then
        _G['TGM']:Hide()
    else
        _G['TGM']:Show()
    end
end

function TGM_CopyButtonOnClick(field)

    if IsShiftKeyDown() then


        if ChatFrameEditBox:IsVisible() then
            if field == 'PlayerName' then
                ChatFrameEditBox:Insert(TGM.ticket.name);
            end
            if field == 'Account' then
                ChatFrameEditBox:Insert(TGM.ticket.account);
            end
            if field == 'IP' then
                ChatFrameEditBox:Insert(TGM.ticket.ip);
            end
            return
        end

        --DEFAULT_CHAT_FRAME:AddMessage("|Hplayer:Sausage|h" .. "[Sausage]" .. "|h");
        return
    end

    --_G['TGMLeftPanelResponse' .. field .. 'CopyButton']:Hide()
    --_G['TGMLeftPanelResponse' .. field .. 'CopyEditbox']:Show()
    --_G['TGMLeftPanelResponse' .. field .. 'CopyEditbox']:SetFocus()
    --_G['TGMLeftPanelResponse' .. field .. 'CopyEditbox']:HighlightText()
end

function TGM_CopyEditboxOnEscape(field)
    --_G['TGMLeftPanelResponse' .. field .. 'CopyButton']:Show()
    --_G['TGMLeftPanelResponse' .. field .. 'CopyEditbox']:Hide()
    --_G['TGMLeftPanelResponse' .. field .. 'CopyEditbox']:ClearFocus()
end

function TGM_OnMouseWheel()

    if IsControlKeyDown() then
        TGM_DATA.alpha = TGM_DATA.alpha + arg1 * 0.05
        if TGM_DATA.alpha > 1 then
            TGM_DATA.alpha = 1
        end
        if TGM_DATA.alpha < 0.1 then
            TGM_DATA.alpha = 0.1
        end
        _G['TGM']:SetAlpha(TGM_DATA.alpha)
        return
    end

    if IsShiftKeyDown() then
        TGM_DATA.scale = 1
        _G['TGM']:SetScale(TGM_DATA.scale)
        return
    end
    TGM_DATA.scale = TGM_DATA.scale + arg1 * 0.05
    _G['TGM']:SetScale(TGM_DATA.scale)
end


TGM.lookupFrames = {}

function TGM_ToggleLookup()

    TGM.BanAccList={} 
    _G['TGMLookupPanelFooterText']:SetText("已选中 "..__length(TGM.BanAccList).." 账号")    
    TGMRightPanel:Hide()
    TGMTemplatesPanel:Hide()
    TGMLookupPanel:Show()
    

    for _, frame in next, TGM.lookupFrames do
        frame:Hide()
    end

end

function TGM_CloseLookup()
    TGMLookupPanel:Hide()
    TGMRightPanel:Show()
end

TGM.templatesFrames = {}

function TGM_ToggleTemplates()

    TGMRightPanel:Hide()
    TGMLookupPanel:Hide()
    TGMTemplatesPanel:Show()

    for _, frame in next, TGM.templatesFrames do
        frame:Hide()
    end

    local col, row = 1, 1

    for i, data in next, TGM_DATA.templates do

        if not TGM.templatesFrames[i] then
            TGM.templatesFrames[i] = CreateFrame("Frame", "TGM_ResponseTemplate_" .. i, TGMTemplatesPanel, "TGM_ResponseTemplate")
        end

        local frame = "TGM_ResponseTemplate_" .. i

        _G[frame]:SetPoint("TOPLEFT", TGMTemplatesPanel, "TOPLEFT", 18 - 170+ 170 * col, -30 * row)
        --_G[frame .. 'Button']:SetSize(150,30) 
        _G[frame .. 'Button']:SetText(data.title) 
        _G[frame .. 'Button']:SetID(i)
        _G[frame .. 'EditButton']:SetID(i)
        _G[frame .. 'DeleteButton']:SetID(i)

        _G[frame]:Show()

        col = col + 1

        if col > 3 then
            col = 1
            row = row + 1
        end


    end

end


function TGM_UseTemplate()

    TGMLeftPanelResponseReplyScrollFrameReplyBox:SetText(TGM_DATA.templates[this:GetID()].text)

    TGMTemplatesPanel:Hide()
    TGMRightPanel:Show()
end

function TGM_SaveTemplate()
    TGMLeftPanelResponseReplyScrollFrameReplyBox:ClearFocus()
    StaticPopup_Show('TGM_NEW_TEMPLATE')
end

TGM.templateToDelete = 0
function TGM_DeleteTemplate()
    TGM.templateToDelete = this:GetID()
    StaticPopup_Show('CONFIRM_DELETE_TEMPLATE')
end

function TGM.send(m)
    --DEFAULT_CHAT_FRAME:AddMessage("Send:" .. m)
    SendAddonMessage(TGM.prefix, m, "GUILD")
end

TGM.templateToEdit = 0
function TGM_EditTemplate()
    TGM.templateToEdit = this:GetID()
    StaticPopup_Show('TGM_EDIT_TEMPLATE_TITLE')
end

function TGM_CloseTemplates()
    TGMTemplatesPanel:Hide()
    TGMRightPanel:Show()
end

function TGM_CloseAntiCheat()
    TGMAntiCheatPanel:Hide()
    TGMLeftPanelResponse:Show()
end

function TGM_CleanAntiCheat()

    TGM.CheaterList = {}
    TGM.processCheaterList()

end

function TGM_OpenAntiCheat()
    SendChatMessage(".anticheat cheatinform")
    TGMAntiCheatPanel:Show()
    TGMLeftPanelResponse:Hide()
end


function __length(arr)
    if not arr then
        return 0
    end
    local rd = 0
    for a in next, arr do
        rd = rd + 1
    end
    return rd
end

function __explode(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from, 1, true)
    while delim_from do
        tinsert(result, string.sub(str, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from, true)
    end
    tinsert(result, string.sub(str, from))
    return result
end

function __replace(s, c, cc)
    return (string.gsub(s, c, cc))
end

StaticPopupDialogs["TGM_NEW_TEMPLATE"] = {
    text = "Enter Template Title:",
    button1 = "Save",
    button2 = "Cancel",
    hasEditBox = 1,
    autoFocus = 1,
    OnAccept = function()
        local templateTitle = getglobal(this:GetParent():GetName() .. "EditBox"):GetText()
        if templateTitle == '' then
            StaticPopup_Show('TGM_TEMPLATES_EMPTY_TITLE')
            return
        end

        TGM_DATA.templates[table.getn(TGM_DATA.templates) + 1] = {
            title = templateTitle,
            text = TGMLeftPanelResponseReplyScrollFrameReplyBox:GetText(),
        }

        getglobal(this:GetParent():GetName() .. "EditBox"):SetText('')
        DEFAULT_CHAT_FRAME:AddMessage('Template ' .. templateTitle .. ' added.')

    end,
    timeout = 0,
    whileDead = 0,
    hideOnEscape = 1,
};

StaticPopupDialogs["TGM_TEMPLATES_EMPTY_TITLE"] = {
    text = "Template Title cannot be empty.",
    button1 = "Okay",
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1
};

StaticPopupDialogs["TGM_TEMPLATES_EMPTY_TEXT"] = {
    text = "Template Text cannot be empty.",
    button1 = "Okay",
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_DELETE_TEMPLATE"] = {
    text = "您确定要删除模板?",
    button1 = TEXT(YES),
    button2 = TEXT(NO),
    OnAccept = function()
        DEFAULT_CHAT_FRAME:AddMessage("Template " .. TGM_DATA.templates[TGM.templateToDelete].title .. " deleted.")
        TGM_DATA.templates[TGM.templateToDelete] = nil
        TGM_ToggleTemplates()
        TGM.templateToDelete = 0
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
};

StaticPopupDialogs["TGM_EDIT_TEMPLATE_TITLE"] = {
    text = "编辑模板标题:",
    button1 = "保存",
    button2 = "取消",
    hasEditBox = 1,
    autoFocus = 1,
    OnShow = function()
        getglobal(this:GetName() .. "EditBox"):SetText(TGM_DATA.templates[TGM.templateToEdit].title)
    end,
    OnAccept = function()
        local templateTitle = getglobal(this:GetParent():GetName() .. "EditBox"):GetText()
        if templateTitle == '' then
            StaticPopup_Show('TGM_TEMPLATES_EMPTY_TITLE')
            return
        end

        TGM_DATA.templates[TGM.templateToEdit].title = templateTitle
        StaticPopup_Show('TGM_EDIT_TEMPLATE_TEXT')
    end,
    timeout = 0,
    whileDead = 0,
    hideOnEscape = 1,
};

StaticPopupDialogs["TGM_EDIT_TEMPLATE_TEXT"] = {
    text = "Edit Template Text:",
    button1 = "Save",
    button2 = "Cancel",
    hasEditBox = 1,
    autoFocus = 1,
    OnShow = function()
        getglobal(this:GetName() .. "EditBox"):SetText(TGM_DATA.templates[TGM.templateToEdit].text)
    end,
    OnAccept = function()
        local templateText = getglobal(this:GetParent():GetName() .. "EditBox"):GetText()
        if templateTitle == '' then
            StaticPopup_Show('TGM_TEMPLATES_EMPTY_TEXT')
            return
        end

        TGM_DATA.templates[TGM.templateToEdit].text = templateText
        DEFAULT_CHAT_FRAME:AddMessage("Template " .. TGM_DATA.templates[TGM.templateToEdit].title .. " updated.")
        TGM_ToggleTemplates()
        TGM.templateToEdit = 0

    end,
    timeout = 0,
    whileDead = 0,
    hideOnEscape = 1,
};





-- pfadmin 的鼠标右键增强


pfAdmin_config = {
    ["server"] = "Turtle",
    ["senditem"] = {
      ["subject"] = "",
      ["text"] = "",
    }
  }
  
  pfAdmin = CreateFrame("Frame")
  
  pfAdmin.commands = {
    ["Turtle"] = {
      -- actions
      ["GM_PLAYERINFO"]   = { ".pinfo #PLAYER", "玩家信息" },
      ["GM_COMBATSTOP"]   = { ".combatstop", "玩卡战斗解除" },
      ["GM_RENAME"]       = { ".rename #PLAYER", "强制玩家改名" },
      ["GM_APPEAR"]       = { ".goname #PLAYER", "传送" },
      ["GM_SUMMON"]       = { ".summon #PLAYER", "召唤" },    
      ["GM_SUMMONS"]       = { ".summon #PLAYER", "召唤玩家" },
      ["GM_MUTE_1H"]       = { ".mute #PLAYER 60  辱骂/刷屏/违规信息/歧视/涉政", "禁言1小时" },
      ["GM_MUTE_6H"]       = { ".mute #PLAYER 360 辱骂/刷屏/违规信息/歧视/涉政",  "禁言6小时" },
      ["GM_MUTE_12H"]      = { ".mute #PLAYER 720  辱骂/刷屏/违规信息/歧视/涉政", "禁言12小时" },
      ["GM_MUTE_24H"]       = { ".mute #PLAYER 1440  辱骂/刷屏/违规信息/歧视/涉政", "禁言24小时" },
      ["GM_MUTE_7D"]       = { ".mute #PLAYER 10080  辱骂/刷屏/违规信息/歧视/涉政", "禁言7天" },
      ["GM_MUTE_14D"]      = { ".mute #PLAYER 20160  辱骂/刷屏/违规信息/歧视/涉政", "禁言14天" },
      ["GM_MUTE_30D"]      = { ".mute #PLAYER 43200  辱骂/刷屏/违规信息/歧视/涉政", "禁言30天" },
      ["GM_UNMUTE"]       = { ".unmute #PLAYER", "解除禁言" },
      ["GM_FREEZE"]       = { ".freeze #PLAYER", "冻结玩家" },
      ["GM_UNFREEZE"]     = { ".unfreeze #PLAYER", "取消冻结" },
      ["GM_ZHENG1"]       = { ".ban character #PLAYER 7d “谈论争议性话题!”", "谈论敏感话题7天封禁" },    
     ["GM_ZHENG2"]       = { ".ban character #PLAYER 30d “谈论争议性话题!”", "谈论敏感话题30天封禁" },      
      ["GM_ZHENG3"]       = { ".ban character #PLAYER -1 “谈论争议性话题!”", "谈论敏感话题永久封禁" },  
     ["GM_WARNBG"]       = { ".ban warn #PLAYER GM警告:战场禁止使用脚本和外挂挂机！", "战场挂机警告" },
      ["GM_AURA1d"]       = { ".aura 26013 86400", "战场禁入1天" },
      ["GM_AURA3d"]       = { ".aura 26013 259200", "战场禁入3天" },
      ["GM_AURA7d"]       = { ".aura 26013 604800", "战场禁入7天" },
      ["GM_AURA30d"]       = { ".aura 26013 2592000", "战场禁入30天" },
      ["GM_AURAS"]        = { ".ban character #PLAYER -1 “战场脚本外挂”",  "战场脚本外挂永久封禁" },
     ["GM_WARNHC"]       = { ".ban warn #PLAYER GM警告:挑战模式(HC和PVP)禁止多开练级！", "HC/PVP多开警告" },
     ["GM_HC"]           = { ".ban character #PLAYER -1 “HC/PVP多开”", "HC/PVP多开永久封禁" },
     ["GM_HC1"]          = { ".ban warn #PLAYER GM警告:禁止帮助硬核模式(HC)的角色进行提升", "帮助硬核模式(HC)警告" },
     ["GM_HC3"]          = { ".ban character #PLAYER 30d “帮助硬核模式(HC)的角色进行提升!”", "帮助硬核模式(HC)30天封禁" },      
     ["GM_HC2"]          = { ".ban character #PLAYER -1 “帮助硬核模式(HC)的角色进行提升!”", "帮助硬核模式(HC)永久封禁" },  
     ["GM_BBOS"]         = { ".ban warn #PLAYER GM警告:禁止高等级号带低等级号升级的行为！", "代练/带老板警告" },
     ["GM_BBOS1"]        = { ".ban character #PLAYER -1 “代练/带老板!”", "代练/带老板永久封禁" },           
     ["GM_WARNBOT"]      = { ".ban warn #PLAYER GM警告:禁止使用脚本和外挂挂机！", "脚本挂机警告" },
     ["GM_WARN1"]      = { ".ban warn #PLAYER GM警告:禁止过度开发资源", "过度开发资源警告" },
      ["GM_BAN1"]         = { ".ban character #PLAYER 1d “脚本挂机”", "脚本挂机封禁1天" },
      ["GM_BANS"]         = { ".ban character #PLAYER -1 “脚本外挂”", "脚本外挂永久封禁" },
     ["GM_BANSSO"]       = { ".ban warn #PLAYER GM警告:禁止多开升级！", "多开升级警告" },
     ["GM_BANSSOO"]      = { ".ban character #PLAYER 30d “多开升级”", "多开升级封禁30天" },
      ["GM_BANSS"]        = { ".ban character #PLAYER -1 “多开或者同步器”", "多开/同步器永久封禁" },
     ["GM_RMTS"]         = { ".ban character #PLAYER -1 “金团行为”", "金团行为永久封禁" },
      ["GM_RMT1"]         = { ".ban character #PLAYER -1 “卖金/买G行为”", "卖金/买金喊话永久封禁" },  
     ["GM_NAMES"]        = { ".ban character #PLAYER -1 “敏感角色名”", "敏感角色名永久封禁" },      
      ["GM_RMT"]          = { ".ban character #PLAYER -1 “RMT行为”", "RMT行为永久封禁" },
      ["GM_RMTSS"]        = { ".ban character #PLAYER -1 “工作室行为”", "工作室行为永久封禁" },   
     ["GM_RP1"]          = { ".ban warn #PLAYER GM警告:游戏内禁止AA行为和干扰RP玩家正常游戏！", "AA/干扰RP警告" },
      ["GM_RP2"]          = { ".ban character #PLAYER 7d “AA行为/干扰角色扮演(RP)活动”", "AA/干扰RP7天封禁" },
      ["GM_RP3"]          = { ".ban character #PLAYER 30d “AA行为/干扰角色扮演(RP)活动”", "AA/干扰RP30天封禁" },        
      ["GM_REVIVE"]       = { ".revive", "复活玩家" },
      ["GM_KICK"]         = { ".kick #PLAYER force", "踢出玩家" },
  
      ["GM_INFO"]         = { ".s info", "查询在线/排队玩家" },
      ["GM_SPEED_BOOST"]  = { ".modify aspeed 5", "增速5倍" },
      ["GM_SPEED_MAX"]    = { ".modify aspeed 10", "增速10倍" },
      ["GM_SPEED_MAXS"]    = { ".modify aspeed 20", "增速20倍" },
      ["GM_SPEED_RESET"]  = { ".modify aspeed 1", "速度重置" },
      ["GM_GMON"]         = { ".gm on", "开启GM模式" },
      ["GM_GMOFF"]        = { ".gm off", "关闭GM模式" },
      ["GM_DIES"]         = { ".die", "杀死目标" },
      ["GM_RESPAWN"]      = { ".respawn", "复活目标" },    
      ["GM_NPCINFO"]      = { ".npc info", "检查NPC标记" },       
      ["GM_NPCFLAG"]      = { ".npc flag 3", "分配NPC标记" },   
      ["SENDITEM"]        = { ".send item \"#PLAYER\" \"#TITLE\" \"#BODY\" #ITEMID", "群发邮件" },
  
      -- filter strings
    },
  }


  
  -- [[ dropdown menus ]] --
UnitPopupButtons["GM_HEADER"] = { text = TEXT("\n"), dist = 0 }
for label, data in pairs(pfAdmin.commands[pfAdmin_config["server"]]) do
  local displayname = data[2]
  UnitPopupButtons[label] = { text = TEXT("|cffaaccff" .. displayname), dist = 0 }
end

-- chat dropdown
table.insert(UnitPopupMenus["FRIEND"], "GM_PLAYERINFO")
table.insert(UnitPopupMenus["FRIEND"], "GM_RENAME")
table.insert(UnitPopupMenus["FRIEND"], "GM_APPEAR")
table.insert(UnitPopupMenus["FRIEND"], "GM_SUMMON")
table.insert(UnitPopupMenus["FRIEND"], "GM_UNMUTE")
table.insert(UnitPopupMenus["FRIEND"], "GM_MUTE_1H")
table.insert(UnitPopupMenus["FRIEND"], "GM_MUTE_6H")
table.insert(UnitPopupMenus["FRIEND"], "GM_MUTE_12H")
table.insert(UnitPopupMenus["FRIEND"], "GM_MUTE_24H")
table.insert(UnitPopupMenus["FRIEND"], "GM_MUTE_7D")
table.insert(UnitPopupMenus["FRIEND"], "GM_MUTE_14D")
table.insert(UnitPopupMenus["FRIEND"], "GM_MUTE_30D")
--table.insert(UnitPopupMenus["FRIEND"], "GM_ZHENG1")
--table.insert(UnitPopupMenus["FRIEND"], "GM_ZHENG2")
--table.insert(UnitPopupMenus["FRIEND"], "GM_ZHENG3")
--table.insert(UnitPopupMenus["FRIEND"], "GM_RMTS")
--table.insert(UnitPopupMenus["FRIEND"], "GM_RMT1")
--table.insert(UnitPopupMenus["FRIEND"], "GM_RMT")
--table.insert(UnitPopupMenus["FRIEND"], "GM_RMTSS")
--table.insert(UnitPopupMenus["FRIEND"], "GM_NAMES")
table.insert(UnitPopupMenus["FRIEND"], "GM_KICK")

-- player dropdown
table.insert(UnitPopupMenus["SELF"], "GM_INFO")
table.insert(UnitPopupMenus["SELF"], "GM_SPEED_BOOST")
table.insert(UnitPopupMenus["SELF"], "GM_SPEED_MAX")
table.insert(UnitPopupMenus["SELF"], "GM_SPEED_MAXS")
table.insert(UnitPopupMenus["SELF"], "GM_SPEED_RESET")
table.insert(UnitPopupMenus["SELF"], "GM_GMON")
table.insert(UnitPopupMenus["SELF"], "GM_GMOFF")
--table.insert(UnitPopupMenus["SELF"], "GM_DIES")
--table.insert(UnitPopupMenus["SELF"], "GM_RESPAWN")
--table.insert(UnitPopupMenus["SELF"], "GM_REVIVE")
--table.insert(UnitPopupMenus["SELF"], "GM_NPCINFO")
--table.insert(UnitPopupMenus["SELF"], "GM_NPCFLAG")

-- player target dropdown
table.insert(UnitPopupMenus["PLAYER"], "GM_PLAYERINFO")
table.insert(UnitPopupMenus["PLAYER"], "GM_COMBATSTOP")
table.insert(UnitPopupMenus["PLAYER"], "GM_RENAME")
table.insert(UnitPopupMenus["PLAYER"], "GM_FREEZE")
table.insert(UnitPopupMenus["PLAYER"], "GM_UNFREEZE")
table.insert(UnitPopupMenus["PLAYER"], "GM_MUTE_1H")
table.insert(UnitPopupMenus["PLAYER"], "GM_MUTE_6H")
table.insert(UnitPopupMenus["PLAYER"], "GM_MUTE_12H")
table.insert(UnitPopupMenus["PLAYER"], "GM_MUTE_24H")
table.insert(UnitPopupMenus["PLAYER"], "GM_MUTE_7D")
table.insert(UnitPopupMenus["PLAYER"], "GM_MUTE_14D")
table.insert(UnitPopupMenus["PLAYER"], "GM_MUTE_30D")
table.insert(UnitPopupMenus["PLAYER"], "GM_WARNBG")
table.insert(UnitPopupMenus["PLAYER"], "GM_AURA3d")
table.insert(UnitPopupMenus["PLAYER"], "GM_AURA7d")
table.insert(UnitPopupMenus["PLAYER"], "GM_AURA30d")
--table.insert(UnitPopupMenus["PLAYER"], "GM_AURAS")
table.insert(UnitPopupMenus["PLAYER"], "GM_WARNHC")
--table.insert(UnitPopupMenus["PLAYER"], "GM_HC")
--table.insert(UnitPopupMenus["PLAYER"], "GM_HC1")
--table.insert(UnitPopupMenus["PLAYER"], "GM_HC3")
--table.insert(UnitPopupMenus["PLAYER"], "GM_HC2")
table.insert(UnitPopupMenus["PLAYER"], "GM_BBOS")
--table.insert(UnitPopupMenus["PLAYER"], "GM_BBOS1")
--table.insert(UnitPopupMenus["PLAYER"], "GM_WARNBOT")
table.insert(UnitPopupMenus["PLAYER"], "GM_WARN1")
--table.insert(UnitPopupMenus["PLAYER"], "GM_BAN1")
--table.insert(UnitPopupMenus["PLAYER"], "GM_BANS")
--table.insert(UnitPopupMenus["PLAYER"], "GM_BANSSO")
--table.insert(UnitPopupMenus["PLAYER"], "GM_BANSSOO")
--table.insert(UnitPopupMenus["PLAYER"], "GM_BANSS")
--table.insert(UnitPopupMenus["PLAYER"], "GM_RMT")
table.insert(UnitPopupMenus["PLAYER"], "GM_RP1")
--table.insert(UnitPopupMenus["PLAYER"], "GM_RP2")
--table.insert(UnitPopupMenus["PLAYER"], "GM_RP3")
table.insert(UnitPopupMenus["PLAYER"], "GM_SUMMONS")
table.insert(UnitPopupMenus["PLAYER"], "GM_KICK")

-- party member dropdown
--table.insert(UnitPopupMenus["PARTY"], "BI")
--table.insert(UnitPopupMenus["PARTY"], "GM_PLAYERINFO")
--table.insert(UnitPopupMenus["PARTY"], "GM_COMBATSTOP")
--table.insert(UnitPopupMenus["PARTY"], "GM_RENAME")
--table.insert(UnitPopupMenus["PARTY"], "GM_APPEAR")
--table.insert(UnitPopupMenus["PARTY"], "GM_SUMMON")
--table.insert(UnitPopupMenus["PARTY"], "GM_MUTES")
--table.insert(UnitPopupMenus["PARTY"], "GM_UNMUTE")
--table.insert(UnitPopupMenus["PARTY"], "GM_WARNBG")
--table.insert(UnitPopupMenus["PARTY"], "GM_AURA24")
--table.insert(UnitPopupMenus["PARTY"], "GM_AURA72")
--table.insert(UnitPopupMenus["PARTY"], "GM_AURAS")
--table.insert(UnitPopupMenus["PARTY"], "GM_WARNHC")
--table.insert(UnitPopupMenus["PARTY"], "GM_HC")
--table.insert(UnitPopupMenus["PARTY"], "GM_WARNBOT")
--table.insert(UnitPopupMenus["PARTY"], "GM_BAN1")
--table.insert(UnitPopupMenus["PARTY"], "GM_BANS")
--table.insert(UnitPopupMenus["PARTY"], "GM_BANSSO")
--table.insert(UnitPopupMenus["PARTY"], "GM_BANSSOO")
--table.insert(UnitPopupMenus["PARTY"], "GM_BANSS")
--table.insert(UnitPopupMenus["PARTY"], "GM_RMT")
--table.insert(UnitPopupMenus["PARTY"], "GM_DIE")
--table.insert(UnitPopupMenus["PARTY"], "GM_REVIVE")
--table.insert(UnitPopupMenus["PARTY"], "GM_KICK")

-- raid member dropdown
--table.insert(UnitPopupMenus["RAID"], "GM_BI")
--table.insert(UnitPopupMenus["RAID"], "GM_PLAYERINFO")
--table.insert(UnitPopupMenus["RAID"], "GM_COMBATSTOP")
--table.insert(UnitPopupMenus["RAID"], "GM_RENAME")
--table.insert(UnitPopupMenus["RAID"], "GM_APPEAR")
--table.insert(UnitPopupMenus["RAID"], "GM_SUMMON")
--table.insert(UnitPopupMenus["RAID"], "GM_MUTES")
--table.insert(UnitPopupMenus["RAID"], "GM_UNMUTE")
--table.insert(UnitPopupMenus["RAID"], "GM_WARNBG")
--table.insert(UnitPopupMenus["RAID"], "GM_AURA24")
--table.insert(UnitPopupMenus["RAID"], "GM_AURA72")
--table.insert(UnitPopupMenus["RAID"], "GM_AURAS")
--table.insert(UnitPopupMenus["RAID"], "GM_WARNHC")
--table.insert(UnitPopupMenus["RAID"], "GM_HC")
--table.insert(UnitPopupMenus["RAID"], "GM_WARNBOT")
--table.insert(UnitPopupMenus["RAID"], "GM_BAN1")
--table.insert(UnitPopupMenus["RAID"], "GM_BANS")
--table.insert(UnitPopupMenus["RAID"], "GM_BANSSO")
--table.insert(UnitPopupMenus["RAID"], "GM_BANSSOO")
--table.insert(UnitPopupMenus["RAID"], "GM_BANSS")
--table.insert(UnitPopupMenus["RAID"], "GM_RMT")
--table.insert(UnitPopupMenus["RAID"], "DIE")
--table.insert(UnitPopupMenus["RAID"], "REVIVE")
--table.insert(UnitPopupMenus["RAID"], "GM_KICK")

-- [[ hook functions ]] --
local HookUnitPopup_OnClick = UnitPopup_OnClick
function UnitPopup_OnClick()
 local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
 local button = this.value
 local unit = dropdownFrame.unit
 local name = dropdownFrame.name
 local server = dropdownFrame.server

 for label, data in pairs(pfAdmin.commands[pfAdmin_config["server"]]) do
   local command = data[1]
   if button == label then

     if name then
       command = string.gsub(command, "#PLAYER", name)
       command = string.gsub(command, CHAT_FLAG_GM, "")
     end

     SendChatMessage(command)
   end
 end

 HookUnitPopup_OnClick()
end
