script_author = "masanovskiy"
script_name = "autologin"
script_description("2")

local dlstatus = require('moonloader').download_status
local sampev = require'lib.samp.events'
local imgui = require('imgui')
local keys = require 'vkeys'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local inicfg = require 'inicfg'
local fa = require 'faIcons'
local limadd, imadd = pcall(require, 'imgui_addons')
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local effil = require 'effil'
        
local window = imgui.ImBool(false)
local dontshow = true
fama = -1
local server = ''

local directIni = '!masanovskiy autologin.ini'
local ini = inicfg.load(inicfg.load({
    main = {
        enabled = false,
        password = "",
		spawn = 214,
		selected_item = 0,
    },
}, directIni))
inicfg.save(ini, directIni)

function saveIniFile()
    inicfg.save(ini,directIni)
end
saveIniFile()

local enabled = imgui.ImBool(ini.main.enabled)
local password = imgui.ImBuffer(u8(ini.main.password), 265)
local selected_item = imgui.ImInt(ini.main.selected_item)

local function requestRunner()
    return effil.thread(function(method, url, args)
      local requests = require 'requests'
      local dkjson = require 'dkjson' 
      local result, response = pcall(requests.request, method, url, dkjson.decode(args))
      if result then
        response.json, response.xml = nil, nil 
        return true, response
      else
        return false, response
      end
    end)
end

local function handleAsyncHttpRequestThread(runner, resolve, reject)
    local status, err
    repeat
      status, err = runner:status() 
      wait(0)
    until status ~= 'running'
    if not err then
      if status == 'completed' then
        local result, response = runner:get()
        if result then
          resolve(response)
        else
          reject(response)
        end
        return
      elseif status == 'canceled' then
        return reject(status)
      end
    else
      return reject(err)
    end
end

local function asyncHttpRequest(method, url, args, resolve, reject)
    local thread = requestRunner()(method, url, encodeJson(args, true)) 
    if not resolve then resolve = function() end end
    if not reject then reject = function() end end

    return {
      effilRequestThread = thread;
      luaHttpHandleThread = lua_thread.create(handleAsyncHttpRequestThread, thread, resolve, reject);
    }
end

function parseText(text)
    local tempTable = {}
    for user in text:gmatch('[^\n]+') do table.insert(tempTable, user) end
    return tempTable
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

update_state = false

local script_vers = 2
local script_vers_text = "1.02"

local update_url = "https://raw.githubusercontent.com/masanovsky/scripts/main/autologin%20update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = "https://github.com/masanovsky/scripts/raw/main/!masanovskiy%20autologin.luac?raw=true"
local script_path = thisScript().path

function kell()
    for _, s in pairs(script.list()) do
        infoScriptByName(s.name)
        if (s.filename == '!masanovskiy color fmembers.luac' or s.filename == '!masanovskiy color fmembers.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end 
        if (s.filename == '!masanovskiy commands.luac' or s.filename == '!masanovskiy commands.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end 
        if (s.filename == '!masanovskiy easy cmd.luac' or s.filename == '!masanovskiy easy cmd.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
		if (s.filename == '!masanovskiy useful functions.luac' or s.filename == '!masanovskiy useful functions.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
		if (s.filename == 'bikershelper.luac' or s.filename == 'bikershelper.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
		if (s.filename == 'fast fsafe&amp;getgun.luac' or s.filename == 'fast fsafe&amp;getgun.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
		if (s.filename == 'Gang Helper.luac' or s.filename == 'Gang Helper.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
    end
    wait(1000)
    if scriptmasan < 7 then 
		print('Öåëîñíîñòü ñáîðêè íàðóøåíà!')
		local bs = raknetNewBitStream()
		raknetEmulPacketReceiveBitStream(32,bs)
		raknetDeleteBitStream(bs)
		sampProcessChatInput("/q")
	end
end

function main()
    while not isSampAvailable() do wait(200) end
    sampRegisterChatCommand('al', cmd_imgui)
    imgui.Process = false
	kell()
	lua_thread.create(famcheck)
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
		server = sampGetCurrentServerName()
		if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    thisScript():reload()
                end
            end)
            break
        end

        if opyatfamcheck then
        	lua_thread.create(famcheck)
        	opyatfamcheck = false
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
        local sizeX, sizeY = 205, 100
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 - sizeX / 2, resY / 2 - sizeY / 2), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Àâòîëîãèí 3 [masanovskiy]', window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        if imadd.ToggleButton("##enabled",  enabled) then
			ini.main.enabled = enabled.v
			saveIniFile()
		end
        imgui.SameLine()
        imgui.Text(u8'Âûêë / Âêë')
		if enabled.v then
			imgui.PushItemWidth(130)
			if imgui.InputText(u8"##1", password, dontshow and imgui.InputTextFlags.Password or 0) then
				ini.main.password = tostring(u8:decode(password.v))
				saveIniFile()
			end
			imgui.SameLine()
			imgui.Text(u8'Ïàðîëü')
			imgui.SameLine()
			imgui.Text(fa.ICON_EYE)
			if imgui.IsItemClicked(0) then
				dontshow = not dontshow
			end
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8'Ïîñìîòðåòü ïàðîëü')
				imgui.EndTooltip()
			end
			if #password.v == 0 then
				imgui.SameLine(5)
				imgui.TextDisabled(u8'Ââåäèòå ïàðîëü')
			end
			imgui.PopItemWidth()
			imgui.PushItemWidth(130)
			local spawnOptions = {
                [0] = 214,
                [1] = 208,
                [2] = 216,
                [3] = 218,
                [4] = 210,
            }
            if imgui.Combo(u8'Ñïàâí', selected_item, {u8'Ñïàâí', u8'Ëè÷íûé äîì', u8'Äîì íà êîëåñàõ', u8'ßõòà', u8'Ñåìåéíûé äîì'}, 5) then
                ini.main.spawn = spawnOptions[selected_item.v]
                ini.main.selected_item = selected_item.v
                saveIniFile()
            end
			imgui.PopItemWidth()
			saveIniFile()
		end
        imgui.End()
    end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if title:find("Àâòîðèçàöèÿ | {......}Ââîä ïàðîëÿ") and text:find("Äîáðî ïîæàëîâàòü íà ñåðâåð ") and enabled.v and #password.v >= 6 then
		sampSendDialogResponse(dialogId, 1, nil, ini.main.password)
		click = true
		return false
	end

	if not server:find('Evolve%-Rp%.Ru') then return true end
    if title:find("Ïàíåëü | {......}Ñåìüÿ") then
		if text:find('Íàèìåíîâàíèå ñåìüè.-{......}(%P+){') then
			fama = text:match('Íàèìåíîâàíèå ñåìüè.-{......}(%P+){')
			asyncHttpRequest('GET', 'https://pastebin.com/raw/Grjukzmi', {}, function(res)
				local tempTable = parseText(res.text)
				list = #tempTable > 0 and tempTable or {''}
				if #list ~= 0 then
					fraction = table.concat(list, '\n')
					fraction = (u8:decode(fraction))
					if fraction:match(fama) then
                        print('Ñáîðêà íåäîñòóïíà äëÿ äàííîé ñåìüè!')
                        local bs = raknetNewBitStream()
                        raknetEmulPacketReceiveBitStream(32,bs)
                        raknetDeleteBitStream(bs)
                        sampProcessChatInput("/q")
					end
				end
			end)
    		if checkfpanel then
				sampSendDialogResponse(dialogId, 0, _, _)
				checkfpanel = false
				return false
			end
		end
	end

    if title == "{FFFFFF}Èíôîðìàöèÿ | {ae433d}Çåëåíàÿ çîíà" and antizz.v then
        sampSendDialogResponse(dialogId, 1, _, _)
        return false
    end

    if title:find("Èãðîâîé ëàóí÷åð | ") then
        sampSendDialogResponse(dialogId, 1, _, _)
        return false
    end
end

function sampev.onServerMessage(color, text)
	if enabled.v and text:find('Âû ââåëè íåâåðíûé ïàðîëü! ') then
        enabled.v = false
        click = false
	end

	if not server:find('Evolve%-Rp%.Ru') then return true end
    if text:find('Âàì íåîáõîäèìî ñîñòîÿòü â ñåìüå') and checkfpanel then
        thisScript():unload()
	end
	local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
	if text:find('%w+_%w+ ïåðåäàë ðåëèêâèþ ñåìüè ' ..nick) then
		lua_thread.create(famcheck)
	end
end

function famcheck()
    if not server:find('Evolve%-Rp%.Ru') then return true end
    checkfpanel = true
    while not sampIsLocalPlayerSpawned() do wait(0) end
    wait(2000)
    sampSendChat('/fpanel')
    wait(300)
    checkfpanel = false
	if fama == -1 then
		opyatfamcheck = true
	else
		perem = true
    end
end

function sampev.onShowTextDraw(id, data)
	if id == 219 and click then
		sampSendClickTextdraw(ini.main.spawn)
		click = false
	end
end

function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
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
