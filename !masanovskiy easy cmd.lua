script_author = "masanovskiy"
script_name = "easy cmd"
script_description("2")

local dlstatus = require('moonloader').download_status
require 'lib.moonloader'
local sampev = require 'lib.samp.events'
local keys = require 'vkeys'
local imgui = require 'imgui'
local inicfg = require 'inicfg'
local cmdlist_file = getWorkingDirectory()..'\\config\\cmdlist.json'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local effil = require 'effil'

window = imgui.ImBool(false)

local wrespa = false
local wdom = false
local wdnk = false
local wyahta = false
local wfh = false

local clientbuf = imgui.ImBuffer(256)
local commandbuf1 = imgui.ImBuffer(256)
local commandbuf2 = imgui.ImBuffer(256)
local serverbuf = imgui.ImBuffer(256)
local directIni = '!masanovskiy easy cmd.ini'
local cfg = inicfg.load({
    config = {
        spawnrespa = '1',
		spawndom = '2',
		spawndnk = '3',
		spawnyahta = '4',
		spawnfh = '5'
    }
}, directIni)

local spawnrespa = imgui.ImBuffer(u8(cfg.config.spawnrespa), 265)
local spawndom = imgui.ImBuffer(u8(cfg.config.spawndom), 265)
local spawndnk = imgui.ImBuffer(u8(cfg.config.spawndnk), 265)
local spawnyahta = imgui.ImBuffer(u8(cfg.config.spawnyahta), 265)
local spawnfh = imgui.ImBuffer(u8(cfg.config.spawnfh), 265)


function jsonSave(jsonFilePath, t)
    file = io.open(jsonFilePath, "w")
    file:write(encodeJson(t))
    file:flush()
    file:close()
end

function jsonRead(jsonFilePath)
    local file = io.open(jsonFilePath, "r+")
    local jsonInString = file:read("*a")
    file:close()
    local jsonTable = decodeJson(jsonInString)
    return jsonTable
end

local lfs        = require('lfs')

local function infoScriptByName(name)
    info               = true
    local scriptinfo   = script.find(name)
    scriptname         = scriptinfo.name
    scriptdescription  = scriptinfo.description
    scriptversion_num  = scriptinfo.version_num
    scriptversion      = scriptinfo.version
    scriptauthors      = scriptinfo.authors
    scriptdependencies = scriptinfo.dependencies
    scriptpath         = scriptinfo.path
end

scriptmasan = 0

function kell()
    for _, s in pairs(script.list()) do
        infoScriptByName(s.name)
        if (s.filename == '!masanovskiy autologin.luac' or s.filename == '!masanovskiy autologin.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end 
        if (s.filename == '!masanovskiy color fmembers.luac' or s.filename == '!masanovskiy color fmembers.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end 
        if (s.filename == '!masanovskiy commands.luac' or s.filename == '!masanovskiy commands.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end 
		if (s.filename == '!masanovskiy useful functions.luac' or s.filename == '!masanovskiy useful functions.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
		if (s.filename == 'bikershelper.luac' or s.filename == 'bikershelper.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
		if (s.filename == 'fast fsafe&amp;getgun.luac' or s.filename == 'fast fsafe&amp;getgun.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
		if (s.filename == 'Gang Helper.luac' or s.filename == 'Gang Helper.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
    end
    wait(1000)
    if scriptmasan < 7 then 
		print('Целосность сборки нарушена!')
		local bs = raknetNewBitStream()
		raknetEmulPacketReceiveBitStream(32,bs)
		raknetDeleteBitStream(bs)
		sampProcessChatInput("/q")
	end
end

update_state = false

local script_vers = 1
local script_vers_text = "1.01"

local update_url = "https://github.com/masanovsky/scripts/raw/main/easy%20cmd%20update.ini"
local update_path = getWorkingDirectory() .. "/easy%20cmd%20update.ini"

local script_url = "https://github.com/masanovsky/scripts/raw/main/!masanovskiy%20autologin.luac?raw=true"
local script_path = thisScript().path

function main()
    while not isSampAvailable() do wait(200) end
	kell()
	sampRegisterChatCommand("cmd", cmd_imgui)
	if  not doesFileExist(cmdlist_file) then jsonSave(cmdlist_file, {}) end
    cmdlist = jsonRead(cmdlist_file) 
    regcmd()
	imgui.Process = false
	downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                update_state = true
            end
            os.remove(update_path)
        end
    end)
	while true do
        wait(0)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    thisScript():reload()
                end
            end)
            break
        end
	end
end

function imgui.CentrText(text)
    local width = imgui.GetWindowWidth()
    local text_width = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
    imgui.Text(text)
end

function cmd_imgui()
    window.v = not window.v
    imgui.Process = window.v
end

red = false

function imgui.OnDrawFrame()
    if not window.v then
        imgui.Process = false
    end
    if window.v then
		local resX, resY = getScreenResolution()
        local sizeX, sizeY = 425, 500
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 - sizeX / 2, resY / 2 - sizeY / 2), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Сокращенные команды [masanovskiy]', window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.CentrText(u8'Список команд:')
		imgui.PushItemWidth(40)
		imgui.InputText(u8"##spawnrespa", spawnrespa)
		imgui.SameLine()
		imgui.Text(u8'Сменить место возрождения. Позиция - "Спавн"')
		imgui.PopItemWidth()
		imgui.PushItemWidth(40)
		imgui.InputText(u8"##spawndom", spawndom)
		imgui.SameLine()
		imgui.Text(u8'Сменить место возрождения. Позиция - "Дом"')
		imgui.PopItemWidth()
		imgui.PushItemWidth(40)
		imgui.InputText(u8"##spawndnk", spawndnk)
		imgui.SameLine()
		imgui.Text(u8'Сменить место возрождения. Позиция - "Дом на колесах"')
		imgui.PopItemWidth()
		imgui.PushItemWidth(40)
		imgui.InputText(u8"##spawnyahta", spawnyahta)
		imgui.SameLine()
		imgui.Text(u8'Сменить место возрождения. Позиция - "Яхта"')
		imgui.PopItemWidth()
		imgui.PushItemWidth(40)
		imgui.InputText(u8"##spawnfh", spawnfh)
		imgui.SameLine()
		imgui.Text(u8'Сменить место возрождения. Позиция - "Семья"')
		imgui.PopItemWidth()
		if imgui.Button(u8'Сохранить настройки') then
			lua_thread.create(function()
				sampUnregisterChatCommand(cfg.config.spawnrespa)
				sampUnregisterChatCommand(cfg.config.spawndom)
				sampUnregisterChatCommand(cfg.config.spawndnk)
				sampUnregisterChatCommand(cfg.config.spawnyahta)
				sampUnregisterChatCommand(cfg.config.spawnfh)
                wait(100)
				cfg.config.spawnrespa = tostring(u8:decode(spawnrespa.v))
				cfg.config.spawndom = tostring(u8:decode(spawndom.v))
				cfg.config.spawndnk = tostring(u8:decode(spawndnk.v))
				cfg.config.spawnyahta = tostring(u8:decode(spawnyahta.v))
				cfg.config.spawnfh = tostring(u8:decode(spawnfh.v))
				wait(100)
				sampRegisterChatCommand(cfg.config.spawnrespa, respa)
				sampRegisterChatCommand(cfg.config.spawndom, dom)
				sampRegisterChatCommand(cfg.config.spawndnk, dnk)
				sampRegisterChatCommand(cfg.config.spawnyahta, yahta)
				sampRegisterChatCommand(cfg.config.spawnfh, fh)
				inicfg.save(cfg, directIni)
				sampAddChatMessage(' {ffffff}Настройки успешно сохранены', 0x177517)
			end)
		end
		if #cmdlist > 0 then
			imgui.Spacing()
			imgui.Separator()
			imgui.Spacing()
			imgui.PushItemWidth(89)
	    if imgui.InputText("##clientbuf", clientbuf) then
	        cmdclient = clientbuf.v
	    end
	    imgui.SameLine()
	    if imgui.InputText("##serverbuf", serverbuf) then
	        cmdserver = serverbuf.v
	    end
	    imgui.PopItemWidth()
	    imgui.SameLine()
	    if #clientbuf.v > 0 and #serverbuf.v > 0 then
	    	if not clientbuf.v:match('%/') then
	        	if imgui.Button(u8'Добавить новую команду') then table.insert(cmdlist, cmd:new(cmdclient, cmdserver)) regcmd() jsonSave(cmdlist_file, cmdlist) end
	        end
	    else
	        imgui.Text(u8'Добавить новую команду')
	    end
	    			if clientbuf.v:match('%/') then
	            		imgui.SameLine(70)
	            		imgui.TextColoredRGB('{FF0000}(?)')
	            		imgui.SameLine(190)
	            		if imgui.IsItemHovered() then
	            			imgui.BeginTooltip()
	            			imgui.Text(u8'Данное поле не нуждается в символе "/". Оно ставится автоматически.')
	            			imgui.EndTooltip()
	            		end
	            	end
	    if #clientbuf.v == 0 and #serverbuf.v == 0 then
	        imgui.SameLine()
	        imgui.TextDisabled('(?)')
	        if imgui.IsItemHovered() then
	            imgui.BeginTooltip()
	            imgui.Text(u8'Для того чтобы понять как работает данная строка\nвпишите следующее для примера:\nПоле "Клиент:" — te\nПоле "Сервер:" — /time 1')
	            imgui.EndTooltip()
	        end
	    end
	    if #clientbuf.v == 0 then 
	        imgui.SameLine(8)
	        imgui.Text(u8'Клиент')
	        if imgui.IsItemHovered() then
	            imgui.BeginTooltip()
	            imgui.Text(u8'Напишите то, какая команда будет отправлять текст\nзаданный справа')
	            imgui.EndTooltip()
	        end
	    end
	    if #serverbuf.v == 0 then 
	        imgui.SameLine(100)
	        imgui.Text(u8'Сервер')
	        if imgui.IsItemHovered() then
	            imgui.BeginTooltip()
	            imgui.Text(u8'Напишите то, что будет отправлено в чат\nпосле выполнения заданной команды слева')
	            imgui.EndTooltip()
	        end
	    end
	        for k, v in ipairs(cmdlist) do
	        	if red == k then
	        		imgui.PushItemWidth(89)
		        	imgui.InputText("##commandbuf1"..k, commandbuf1)
		        	imgui.SameLine()
		        	imgui.InputText("##commandbuf2"..k, commandbuf2)
		        	imgui.PopItemWidth()
	        	else
	        		imgui.Text(v.cmdclient)
		        	imgui.SameLine()
		        	imgui.Text(v.cmdserver)
	        	end
	            imgui.SameLine()
	            imgui.SetCursorPosX(190)
	            if red == k then
	            	if imgui.Button(u8'Сохранить##'..k) then 
	            		lua_thread.create(function()
	            			if not commandbuf1.v:match('%/') then
				            	red = false
				            	table.remove(cmdlist, k) 
				            	sampUnregisterChatCommand(v.cmdclient) 
				            	jsonSave(cmdlist_file, cmdlist) 
				            	wait(100)
				            	cmdclient = commandbuf1.v
				            	cmdserver = commandbuf2.v
				            	table.insert(cmdlist, cmd:new(cmdclient, cmdserver)) 
				            	if cmdserver:match('%/') then
					            sampRegisterChatCommand(cmdclient, 
					                function(param)
					                    sampSendChat(cmdserver..' '..param)
					                end)
					        	else
					        		sampRegisterChatCommand(cmdclient, 
					                function()
					                    sampSendChat(cmdserver)
					                end)
					        	end
				            	jsonSave(cmdlist_file, cmdlist)
				            end
			            end)
		            end
	            else
		            if imgui.Button(u8'Редактировать##'..k) then 
		            	red = k
		            	commandbuf1.v = v.cmdclient
		            	commandbuf2.v = v.cmdserver
		            end
		        end
	            imgui.SameLine()
	            if imgui.Button(u8'Удалить команду##'..k) then 
	            	table.remove(cmdlist, k) 
	            	sampUnregisterChatCommand(v.cmdclient) 
	            	jsonSave(cmdlist_file, cmdlist) 
	            end
	        end
	    end
		imgui.End()
	end
end

function sampev.onShowTextDraw(id, data)
	if id == 219 and wrespa then
		lua_thread.create(function()
			wait(100)
			sampSendClickTextdraw(214)
			wrespa = false
		end)
	end
	if id == 219 and wdom then
		lua_thread.create(function()
			wait(100)
			sampSendClickTextdraw(208)
			wdom = false
		end)
	end
	if id == 219 and wdnk then
		lua_thread.create(function()
			wait(100)
			sampSendClickTextdraw(216)
			wdnk = false
		end)
	end
	if id == 219 and wyahta then
		lua_thread.create(function()
			wait(100)
			sampSendClickTextdraw(218)
			wyahta = false
		end)
	end
	if id == 219 and wfh then
		lua_thread.create(function()
			wait(100)
			sampSendClickTextdraw(210)
			wfh = false
		end)
	end
end

function respa()
	sampSendChat('/changespawn')
	wrespa = true
end

function dom()
	sampSendChat('/changespawn')
	wdom = true
end

function dnk()
	sampSendChat('/changespawn')
	wdnk = true
end

function yahta()
	sampSendChat('/changespawn')
	wyahta = true
end

function fh()
	sampSendChat('/changespawn')
	wfh = true
end

cmd = {}

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(text)
end

function cmd:new(cmdclient, cmdserver)
    local obj = {
        cmdclient = cmdclient,
        cmdserver = cmdserver
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function onWindowMessage(msg, wparam, lparam)
    if msg == 0x100 or msg == 0x101 then
        if (wparam == keys.VK_ESCAPE and window.v) and not isPauseMenuActive() then
            consumeWindowMessage(true, false)
            if msg == 0x101 then
                window.v = false
            end
        end
    end
end

function regcmd()
    if #cmdlist ~= 0 then
        for k, v in ipairs(cmdlist) do
        	if v.cmdserver:match('%/') then
            sampRegisterChatCommand(v.cmdclient, 
                function(param)
                    sampSendChat(v.cmdserver..' '..param)
                end)
        	else
        		sampRegisterChatCommand(v.cmdclient, 
                function()
                    sampSendChat(v.cmdserver)
                end)
        	end
        end
    end
    sampRegisterChatCommand(cfg.config.spawnrespa, respa)
	sampRegisterChatCommand(cfg.config.spawndom, dom)
	sampRegisterChatCommand(cfg.config.spawndnk, dnk)
	sampRegisterChatCommand(cfg.config.spawnyahta, yahta)
	sampRegisterChatCommand(cfg.config.spawnfh, fh)
end

function apply_custom_style()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	style.WindowRounding = 5
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ChildWindowRounding = 5
	style.FrameRounding = 2.0
	style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 0
	style.GrabMinSize = 8.0
	style.GrabRounding = 1.0
	style.WindowPadding = imgui.ImVec2(4.0, 4.0)
	style.FramePadding = imgui.ImVec2(2.5, 3.5)
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = imgui.ImColor(20, 20, 20, 255):GetVec4()
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = imgui.ImColor(40, 142, 110, 90):GetVec4()
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]                = imgui.ImColor(40, 142, 110, 113):GetVec4()
	colors[clr.FrameBgHovered]         = imgui.ImColor(40, 142, 110, 164):GetVec4()
	colors[clr.FrameBgActive]          = imgui.ImColor(40, 142, 110, 255):GetVec4()
	colors[clr.TitleBg]                = imgui.ImColor(40, 142, 110, 236):GetVec4()
	colors[clr.TitleBgActive]          = imgui.ImColor(40, 142, 110, 236):GetVec4()
	colors[clr.TitleBgCollapsed]       = ImVec4(0.05, 0.05, 0.05, 0.79)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = imgui.ImColor(40, 142, 110, 236):GetVec4()
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.28, 0.28, 0.28, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.35, 0.35, 0.35, 1.00)
	colors[clr.Button]                 = imgui.ImColor(35, 35, 35, 255):GetVec4()
	colors[clr.ButtonHovered]          = imgui.ImColor(35, 121, 93, 174):GetVec4()
	colors[clr.ButtonActive]           = imgui.ImColor(44, 154, 119, 255):GetVec4()
	colors[clr.Header]                 = imgui.ImColor(40, 142, 110, 255):GetVec4()
	colors[clr.HeaderHovered]          = ImVec4(0.34, 0.34, 0.35, 0.89)
	colors[clr.HeaderActive]           = ImVec4(0.12, 0.12, 0.12, 0.94)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]             = imgui.ImColor(40, 142, 110, 255):GetVec4()
	colors[clr.ResizeGripHovered]      = imgui.ImColor(35, 121, 93, 174):GetVec4()
	colors[clr.ResizeGripActive]       = imgui.ImColor(44, 154, 119, 255):GetVec4()
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.10, 0.10, 0.10, 0.35)
end
apply_custom_style()