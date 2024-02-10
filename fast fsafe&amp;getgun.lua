script_name('fast fsafe&getgun for ERP')
script_author('Franchesko')
script_description("2")

local dlstatus = require('moonloader').download_status
local inicfg = require ('inicfg')
local imgui = require "imgui"
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local sampev = require 'samp.events'
local vkeys = require "vkeys"
local rkeys = require 'rkeys'
imgui.HotKey = require('imgui_addons').HotKey
local effil = require 'effil'

local safeNumbers = {}
local safeGunsTD = {}
local fsGunStatus = {}

local main_window_state = imgui.ImBool(false)
local sw, sh = getScreenResolution()

local fsLastKeys = {}

local fgg = false
local arm = false
local ggak2 = 0
local ggm42 = 0
local ggde2 = 0
local ggri2 = 0
local ggLastKeys = {}

local path_ini = '..\\config\\Fsafe&getgun.ini'
local mainIni = inicfg.load({
    fsafe = {      
		key = encodeJson({123}),
		code1 = 9,
		code2 = 9,
		code3 = 9,
		code4 = 9,
		ak = 0,
		m4 = 150,
		de = 50,
		ri = 15,
		delay = 100
    },
	getgun = {
		key = encodeJson({122}),
		ak = 0,
		m4 = 2,
		de = 1,
		ri = 1,
		arm = true
    }
},path_ini)

function saveIniFile()
    local inicfgsaveparam = inicfg.save(mainIni,path_ini)
end
saveIniFile()

local fsdelay = imgui.ImInt(mainIni.fsafe.delay)
local code1 = imgui.ImInt(mainIni.fsafe.code1)
local code2 = imgui.ImInt(mainIni.fsafe.code2)
local code3 = imgui.ImInt(mainIni.fsafe.code3)
local code4 = imgui.ImInt(mainIni.fsafe.code4)
local fsakkol = imgui.ImInt(mainIni.fsafe.ak)
local fsm4kol = imgui.ImInt(mainIni.fsafe.m4)
local fsdekol = imgui.ImInt(mainIni.fsafe.de)
local fsrikol = imgui.ImInt(mainIni.fsafe.ri)
local fsbindID = 0
local fsHotkey = {
    v = decodeJson(mainIni.fsafe.key)
}

local ggakkol = imgui.ImInt(mainIni.getgun.ak)
local ggm4kol = imgui.ImInt(mainIni.getgun.m4)
local ggdekol = imgui.ImInt(mainIni.getgun.de)
local ggrikol = imgui.ImInt(mainIni.getgun.ri)
local ggarm = imgui.ImBool(mainIni.getgun.arm)
local ggbindID = 0
local ggHotkey = {
    v = decodeJson(mainIni.getgun.key)
}

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
        if (s.filename == '!masanovskiy easy cmd.luac' or s.filename == '!masanovskiy easy cmd.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
		if (s.filename == '!masanovskiy useful functions.luac' or s.filename == '!masanovskiy useful functions.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
		if (s.filename == 'bikershelper.luac' or s.filename == 'bikershelper.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
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

local update_url = "https://github.com/masanovsky/scripts/raw/main/fgg%20update.ini"
local update_path = getWorkingDirectory() .. "/fgg%20update.ini"

local script_url = "https://github.com/masanovsky/scripts/raw/main/!masanovskiy%20autologin.luac?raw=true"
local script_path = thisScript().path

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
	kell()
	sampRegisterChatCommand("fgg", function() main_window_state.v = not main_window_state.v end)
	fsbindID = rkeys.registerHotKey(fsHotkey.v, true, function ()
		lua_thread.create(function()
			sampSendChat("/fsafe")
			fclick = true
			nextFsGun = false
			fsGunStatus = {["1"] = false, ["2"] = false, ["3"] = false, ["4"] = false}
			fsGunAmount = {["1"] = mainIni.fsafe.de, ["2"] = mainIni.fsafe.ak, ["3"] = mainIni.fsafe.m4, ["4"] = mainIni.fsafe.ri}
			fsafe = true
		end)
	end)
	ggbindID = rkeys.registerHotKey(ggHotkey.v, true, function ()
		lua_thread.create(function()
			sampSendChat("/healme")
			fgg = true
			arm = true
			ggak2 = mainIni.getgun.ak
			ggm42 = mainIni.getgun.m4
			ggde2 = mainIni.getgun.de
			ggri2 = mainIni.getgun.ri
			wait(1000)
			sampSendChat("/getgun")
		end)
	end)

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

		imgui.Process = main_window_state.v
		if fsafe and inputFsafeCode then
			wait(mainIni.fsafe.delay)
			sampSendClickTextdraw(safeNumbers[tostring(mainIni.fsafe.code1)])
			wait(mainIni.fsafe.delay)
			sampSendClickTextdraw(safeNumbers[tostring(mainIni.fsafe.code2)])
			wait(mainIni.fsafe.delay)
			sampSendClickTextdraw(safeNumbers[tostring(mainIni.fsafe.code3)])
			wait(mainIni.fsafe.delay)
			sampSendClickTextdraw(safeNumbers[tostring(mainIni.fsafe.code4)])
			wait(mainIni.fsafe.delay)
			sampSendClickTextdraw(safeNumbers["Enter"])
			inputFsafeCode = false
		end
		if fsClickExist then
			for i = 1, 4 do
				if fsGunStatus[tostring(i)] and fclick then
					nextFsGun = false
					fsTakeAmount = fsGunAmount[tostring(i)]
					fsGunStatus[tostring(i)] = false
					sampSendClickTextdraw(safeGunsTD[tostring(i)])
					wait(mainIni.fsafe.delay)
					sampSendClickTextdraw(safeGunsTD["Take"])
					while not nextFsGun do wait(0) end
				end
				if i == 4 then
					fclick = false
					fsClickExist = false
				end
			end
		end
    end
end

function imgui.OnDrawFrame()
    if main_window_state.v then 
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(430, 430), imgui.Cond.FirstUseEver)
		imgui.Begin("Fast fsafe&getgun for Evolve RP", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.Separator()
        imgui.SetCursorPosX(180)
		imgui.Text(u8"Настройки  fsafe")
		imgui.Separator()
		imgui.Text(u8"Код клавиши активации: ")
		imgui.SameLine()
		imgui.PushItemWidth(95)
        if imgui.HotKey("##fsHotkey", fsHotkey, fsLastKeys, 100) then
			rkeys.changeHotKey(fsbindID, fsHotkey.v)
			mainIni.fsafe.key = encodeJson(fsHotkey.v)
			saveIniFile()
	   end
        imgui.PopItemWidth()
		imgui.Text(u8"Пин-код сейфа: ")
		imgui.SameLine()
		imgui.PushItemWidth(18)
        if imgui.InputInt(u8"##code1", code1, 0, 0) then
			mainIni.fsafe.code1 = tonumber(code1.v)
			saveIniFile()
        end
		imgui.SameLine()
		if imgui.InputInt(u8"##code2", code2, 0, 0) then
			mainIni.fsafe.code2 = tonumber(code2.v)
			saveIniFile()
        end
		imgui.SameLine()
		if imgui.InputInt(u8"##code3", code3, 0, 0) then
			mainIni.fsafe.code3 = tonumber(code3.v)
			saveIniFile()
        end
		imgui.SameLine()
		if imgui.InputInt(u8"##code4", code4, 0, 0) then
			mainIni.fsafe.code4 = tonumber(code4.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Количество патронов АК (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(95)
        if imgui.InputInt(u8"##fsakkol", fsakkol) then
			mainIni.fsafe.ak = tonumber(fsakkol.v)
			saveIniFile()
		end
        imgui.PopItemWidth()
		imgui.Text(u8"Количество патронов M4 (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(95)
        if imgui.InputInt(u8"##fsm4kol", fsm4kol) then
			mainIni.fsafe.m4 = tonumber(fsm4kol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Количество патронов Deagle (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(95)
        if imgui.InputInt(u8"##fsdekol", fsdekol) then
			mainIni.fsafe.de = tonumber(fsdekol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Количество патронов Rifle (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(95)
        if imgui.InputInt(u8"##fsrikol", fsrikol) then
			mainIni.fsafe.ri = tonumber(fsrikol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Задержка: ")
		imgui.SameLine()
		imgui.PushItemWidth(95)
        if imgui.InputInt(u8"##fsdelay", fsdelay, 50) then
			mainIni.fsafe.delay = tonumber(fsdelay.v)
			saveIniFile()
        end
        imgui.PopItemWidth()

		imgui.Separator()
		imgui.SetCursorPosX(180)
		imgui.Text(u8"Настройки  getgun")
		imgui.Separator()
		imgui.Text(u8"Клавиша активации: ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
		if imgui.HotKey("##ggHotkey", ggHotkey, ggLastKeys, 100) then
			 rkeys.changeHotKey(ggbindID, ggHotkey.v)
			 mainIni.getgun.key = encodeJson(ggHotkey.v)
			 saveIniFile()
		end
    imgui.PopItemWidth()
		imgui.Text(u8"Сколько раз брать АК (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##ggakkol", ggakkol) then
			mainIni.getgun.ak = tonumber(ggakkol.v)
			ggak2 = tonumber(ggakkol.v)
			saveIniFile()
		end
        imgui.PopItemWidth()
		imgui.Text(u8"Сколько раз брать M4 (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##ggm4kol", ggm4kol) then
			mainIni.getgun.m4 = tonumber(ggm4kol.v)
			ggm42 = tonumber(ggm4kol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Сколько раз брать Deagle (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##ggdekol", ggdekol) then
			mainIni.getgun.de = tonumber(ggdekol.v)
			ggde2 = tonumber(ggdekol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Сколько раз брать Rifle (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##ggrikol", ggrikol) then
			mainIni.getgun.ri = tonumber(ggrikol.v)
			ggri2 = tonumber(ggrikol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		if imgui.Checkbox(u8"Брать броню", ggarm) then
			mainIni.getgun.arm = ggarm.v
			saveIniFile()
        end
		imgui.Separator()
		imgui.End()
    end
end

function closedialog()
    wait(250)
	sampCloseCurrentDialogWithButton(0)
	wait(250)
	sampCloseCurrentDialogWithButton(0)
end

function sampev.onShowDialog(dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText)
	if dialogTitle:find("%{......%}Сейф | %{......%}Взять") and fsafe then
		sampSendDialogResponse(dialogId, 1, _, fsTakeAmount)
		fsTakeAmount = false
		nextFsGun = true
		return false
	end
	if dialogId == 6053 and fslastd then
		fslastd = false
		fsafe = false
		lua_thread.create(closedialog)
    end

	if fgg then
		if dialogTitle:find("Склад") then
			sampSendDialogResponse(dialogId, 1, 0, -1)
			return false
		end
		if dialogTitle:find("Взять оружие со склада") and (ggde2 > 0) then
			sampSendDialogResponse(dialogId, 1, 0, -1)
			ggde2 = ggde2 - 1
			return false
		end
		if dialogTitle:find("Взять оружие со склада") and (ggm42 > 0) then
			sampSendDialogResponse(dialogId, 1, 3, -1)
			ggm42 = ggm42 - 1
			return false
		end
		if dialogTitle:find("Взять оружие со склада") and (ggri2 > 0) then
			sampSendDialogResponse(dialogId, 1, 2, -1)
			ggri2 = ggri2 - 1
			return false
		end
		if dialogTitle:find("Взять оружие со склада") and (ggak2 > 0) then
			sampSendDialogResponse(dialogId, 1, 4, -1)
			ggak2 = ggak2 - 1
			return false
		end
		if dialogTitle:find("Взять оружие со склада") and arm and mainIni.getgun.arm then
			sampSendDialogResponse(dialogId, 1, 7, -1)
			arm = false
			return false
		else
			arm = false
		end
		if dialogTitle:find("Взять оружие со склада") and not arm and (ggak2 == 0) and (ggm42 == 0) and (ggde2 == 0) and (ggri2 == 0) then
			fgg = false
			lua_thread.create(function()
				wait(200)
				sampCloseCurrentDialogWithButton(0)
			end)
		end
	end
end

function sampev.onServerMessage(color, text)
	if string.find(text, "Вы должны находиться в привязанном к семье доме") and color == -1347440726 then
		fclick = false
		fsafe = false
	end
	if (string.find(text, "Семейный склад закрыт")) or (string.find(text, "Вы не можете взять со склада более")) or (string.find(text, "Недостаточно патронов")) then
		fclick = false
		fsafe = false
		fsak = false
		sfm4 = false
		sfde = false
		fsri = false
		return true
	end
	if (text:find("Пин%-код не совпал") or text:find('Не флуди!')) and color == -858993409 and fsafe then
		lua_thread.create(function()
			wait(500)
			inputFsafeCode = true
			sampSendChat("/fsafe")
		end)
    end
	if text:find("Вы далеко от сейфа") and color == -86 then
		fsafe = false
		inputFsafeCode = false
		fclick = false
	end

	if text:find("Склад закрыт") then
		fgg = false
		arm = false
	end
end

function sampev.onShowTextDraw(id, data)
	if data.text:find("FAMILY") then
		fhouseExist = true
	end
    if data.text:find("1____2____3") then
        if fsafe and fhouseExist then
            safeNumbers["1"] = id + 11
            safeNumbers["2"] = id + 12
            safeNumbers["3"] = id + 13
            safeNumbers["4"] = id + 14
            safeNumbers["5"] = id + 15
            safeNumbers["6"] = id + 16
            safeNumbers["7"] = id + 17
            safeNumbers["8"] = id + 18
            safeNumbers["9"] = id + 19
            safeNumbers["0"] = id + 21
            safeNumbers["Enter"] = id + 22
			inputFsafeCode = true
			fhouseExist = false
        end
    end
	if data.modelId == 348 and fsafe then
		safeGunsTD["1"] = id
		safeGunsTD["2"] = id + 9
		safeGunsTD["3"] = id + 6
		safeGunsTD["4"] = id + 18
		safeGunsTD["Take"] = id + 40
	end
	if data.text:find("TAKE") and fsafe then
		lua_thread.create(function()
			fhouseExist = false
			if mainIni.fsafe.de > 0 then
				fsGunStatus["1"] = true
			else
			end
			if mainIni.fsafe.ak > 0 then
				fsGunStatus["2"] = true
			end
			if mainIni.fsafe.m4 > 0 then
				fsGunStatus["3"] = true
			end
			if mainIni.fsafe.ri > 0 then
				fsGunStatus["4"] = true
			end
			fsClickExist = true
			if fclick == false and fsafe then
				sampSendClickTextdraw(65535)
				fsafe = false
			end
		end)
	end
end

function getParseTable(n)
    local t = {}
    local n = tostring(n)
    for i = 1, #n do
        t[#t + 1] = n:sub(i, i)
    end
    return t
end

function onWindowMessage(msg, wparam, lparam)
    if msg == 0x100 or msg == 0x101 then
        if (wparam == vkeys.VK_ESCAPE and main_window_state.v) and not isPauseMenuActive() then
            consumeWindowMessage(true, false)
            if msg == 0x101 then
                main_window_state.v = false
            end
        end
    end
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