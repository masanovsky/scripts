script_author = "masanovskiy"
script_name = "useful functions"
script_description("2")

local dlstatus = require('moonloader').download_status
local imgui = require('imgui')
local encoding = require 'encoding'
local keys = require 'vkeys'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local inicfg = require 'inicfg'
local emul = import('lib\\rpc_emul.lua')
local sampev = require 'samp.events'
local effil = require 'effil'

local window = imgui.ImBool(false)

local directIni = '!masanovskiy useful functions.ini'
    local ini = inicfg.load(inicfg.load({
        main = {
            intCol = true,
            removePlayers = true,
            jmuriki = true,
            antizz = true,
        },
    }, directIni))
    inicfg.save(ini, directIni)
    
function saveIniFile()
    inicfg.save(ini,directIni)
end
saveIniFile()

local intCol = imgui.ImBool(ini.main.intCol)
local removePlayers = imgui.ImBool(ini.main.removePlayers)
local jmuriki = imgui.ImBool(ini.main.jmuriki)
local antizz = imgui.ImBool(ini.main.antizz)

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

local update_url = "https://github.com/masanovsky/scripts/raw/main/useful%20functions%20update.ini"
local update_path = getWorkingDirectory() .. "/useful%20functions%20update.ini"

local script_url = "https://github.com/masanovsky/scripts/raw/main/!masanovskiy%20autologin.luac?raw=true"
local script_path = thisScript().path

function main()
    while not isSampAvailable() do wait(200) end
    kell()
    sampRegisterChatCommand('uf', cmd_imgui)
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

        if intCol.v and not isCharInAnyCar(PLAYER_PED) then
            for i = 0, sampGetMaxPlayerId(true) do
                if sampIsPlayerConnected(i) then
                    local result, id = sampGetCharHandleBySampPlayerId(i)
                    if result then
                        if doesCharExist(id) then
                            local x, y, z = getCharCoordinates(id)
                            local mX, mY, mZ = getCharCoordinates(PLAYER_PED)
                            if 0.9 > getDistanceBetweenCoords3d(x, y, z, mX, mY, mZ) and getActiveInterior() ~= 0 then
                                setCharCollision(id, false)
                            end
                        end
                    end
                end
            end
        end

        if jmuriki.v and getActiveInterior() == 0 then
            wait(400)
            local peds = getAllChars()
            for _, ped in ipairs(peds) do
                local result, pid = sampGetPlayerIdByCharHandle(ped)
                if pid == -1 then
                    deleteChar(ped)
                end
            end
        end
    end
end

function cmd_imgui()
    window.v = not window.v
    imgui.Process = window.v
end
        
function imgui.OnDrawFrame()
    if not window.v then
        imgui.Process = false
    end
    if window.v then
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 245, 130
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 - sizeX / 2, resY / 2 - sizeY / 2), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Полезные функции [masanovskiy]', window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        if imgui.Checkbox(u8'Коллизия на игроков в интерьерах', intCol) then
			ini.main.intCol = intCol.v
			saveIniFile()
		end
        if imgui.Checkbox(u8'Удаление мертвых игроков', removePlayers) then
			ini.main.removePlayers = removePlayers.v
			saveIniFile()
		end
        if imgui.Checkbox(u8'Удаление трупов', jmuriki) then
			ini.main.jmuriki = jmuriki.v
			saveIniFile()
		end
        if imgui.Checkbox(u8'Анти-зз', antizz) then
			ini.main.antizz = antizz.v
			saveIniFile()
		end
        imgui.End()
    end
end

function sampev.onApplyPlayerAnimation(playerId, animLib, animName)
    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if removePlayers.v and myId ~= PLAYER_PED and (animLib == "PED" and (animName == "KO_shot_face" or animName == "KO_shot_front")) then
      emul.emulRpcReceive(163, {playerId})
    end

    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if myId ~= PLAYER_PED and animLib == "MISC" and animName == "plyr_shkhead" then return false end
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