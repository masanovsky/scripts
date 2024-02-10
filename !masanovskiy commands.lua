script_author = "masanovskiy"
script_name = "commands"
script_description("2")

local dlstatus = require('moonloader').download_status
local sampev = require 'samp.events'
local imgui = require('imgui')
local ffi = require('ffi')
local encoding = require 'encoding'
local keys = require 'vkeys'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local effil = require 'effil'
local inicfg = require 'inicfg'
        
local window = imgui.ImBool(false)

ffi.cdef[[
  void ExitProcess(unsigned int uExitCode);
  struct std_string { union { char buf[16]; char* ptr; }; unsigned size; unsigned capacity; };
  struct stCommandInfo { struct std_string name; int type; void* owner; };
  struct std_vector_stCommandInfo{ struct stCommandInfo* first; struct stCommandInfo* last; struct stCommandInfo* end; };
]]

local _getChatCommands = ffi.cast('struct std_vector_stCommandInfo(__thiscall*)()', getModuleProcAddress('SAMPFUNCS.asi', '?getChatCommands@SAMPFUNCS@@QAE?AV?$vector@UstCommandInfo@@V?$allocator@UstCommandInfo@@@std@@@std@@XZ'))

function getChatCommands()
    local t = {}
    local commands1 = _getChatCommands()
    local it = commands1.first
    while it ~= commands1.last do
        table.insert(t, '/'..ffi.string(it[0].name.size <= 0x0F and it[0].name.buf or it[0].name.ptr))
        it = it + 1
    end
    return t
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
        if (s.filename == '!masanovskiy easy cmd.luac' or s.filename == '!masanovskiy easy cmd.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
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

local update_url = "https://github.com/masanovsky/scripts/raw/main/commands%20update.ini"
local update_path = getWorkingDirectory() .. "/commands%20update.ini"

local script_url = "https://github.com/masanovsky/scripts/raw/main/!masanovskiy%20autologin.luac?raw=true"
local script_path = thisScript().path

function main()
    while not isSampAvailable() do wait(200) end
    kell()
    sampRegisterChatCommand('commands', cmd_imgui)
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

function sampev.onSendSpawn()
    sampAddChatMessage(' {ffffff}Введите /commands чтобы посмотреть список команд', 0x177517)
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
        local sizeX, sizeY = 315, 540
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 - sizeX / 2, resY / 2 - sizeY / 2), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Список команд [masanovskiy]', window, imgui.WindowFlags.NoCollapse)
        for _, cmd in ipairs(getChatCommands()) do
            local descriptions = {
                ["/eblo"] = { "Чекер игроков в сети", "Параметры: /eblo [/help/mafia/bikers/gang]" },
                ["/prmenu"] = { "Удаление игроков в зоне стрима [Опционально]" },
                ["/ghelper"] = { "Помощник для гетто" },
                ["/bhelper"] = { "Помощник для байкеров" },
                ["/fgg"] = { "Быстрое взятие оружия с сейфа семьи и склада" },
                ["/getkills"] = { "Счетчик убийств и смертей" },
                ["/tinfo"] = { "Команды наркотаймера" },
                ["/dmg"] = { "Damage informer" },
                ["/mlines"] = { "Отрисованные линии зоны стрел для мафий" },
                ["/al"] = { "Автологин" },
                ["/sv"] = { "Работа в свернутом режиме" },
                ["/ctime"] = { "Время на экране" },
                ["/list"] = { "Запоминание диалогов" },
                ["/carfix"] = { "Исправление багов с машинами" },
                ["/flood"] = { "Флудер", "Параметры: /flood menu" },
                ["/scm"] = { "Sweet connect" },
                ["/cmd"] = { "Сокращенные команды" },
                ["/uf"] = { "Полезные функции" },
                ["/sens"] = { "Насйтрока чувствительности мыши" },
            }
            local desc = descriptions[cmd]
            if desc and imgui.CollapsingHeader(cmd, 0) then
                for _, line in ipairs(desc) do
                    imgui.TextWrapped(u8(line))
                end
            end
        end
        imgui.End()
    end
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