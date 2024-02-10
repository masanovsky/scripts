script_name('Bikers helper for ERP')
script_author('Franchesko')
script_description("2")

local dlstatus = require('moonloader').download_status
local keys = require 'vkeys'
local inicfg = require ('inicfg')
local rkeys = require 'rkeys'
local imgui = require "imgui"
imgui.HotKey = require('imgui_addons').HotKey
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local sampev = require 'samp.events'
local effil = require 'effil'

local main_window_state = imgui.ImBool(false)
local second_window_state = imgui.ImBool(false)
local sw, sh = getScreenResolution()
local spawncaractive = false
local fsafeactive = false
local fbankactive = false
local captureactive = false
local activeautoload = false
local proccesautoload = false
local changedlivpos = false
local admids = ""
local dlivtimer = 0
local offmembers = {}
local offmembersrangs = {}

local path_ini = '..\\config\\bikershelperUPD.ini'
local mainIni = inicfg.load({
    maincfg = {
		spawncar = false,
		fsafecmd = "fswl",
		deletekiy = false,
		smskontr = false,
		uvedkontr = false,
		autobar = false,
		autodrugs = false,
		admcopyid = false,
		dtimer = false,
		autodrugsdeath = false,
		fbankcmd = "fbwl",
		automget = "amg",
		dtimertext = "Длив",
		keys = encodeJson({112}),
		dlivposx = 20,
		dlivposy = 400,
		dlivtime = 118,
		dlivcolor = -16776961,
		dlivrazmer = 11,
		ctime = 550,
		clist = 1
    }
},path_ini)

function saveIniFile()
    local inicfgsaveparam = inicfg.save(mainIni,path_ini)
end
saveIniFile()

function join_argb(a, r, g, b)
  local argb = b  -- b
  argb = bit.bor(argb, bit.lshift(g, 8))  -- g
  argb = bit.bor(argb, bit.lshift(r, 16)) -- r
  argb = bit.bor(argb, bit.lshift(a, 24)) -- a
  return argb
end

function explode_argb(argb)
  local a = bit.band(bit.rshift(argb, 24), 0xFF)
  local r = bit.band(bit.rshift(argb, 16), 0xFF)
  local g = bit.band(bit.rshift(argb, 8), 0xFF)
  local b = bit.band(argb, 0xFF)
  return a, r, g, b
end

function sampev.onServerMessage(color, text)
	if (string.find(text, "Выезд занят другим транспортным средством")) then
		spawncaractive = false
		return true
	end
	if (string.find(text, "Данный дом не привязан к Вашей семье")) then
		spawncaractive = false
		return true
	end
	if (string.find(text, "Отправитель: Контрабандист")) and mainIni.maincfg.smskontr then
		return false
	end
	if (string.find(text, "Сообщает: Контрабандист")) and mainIni.maincfg.uvedkontr then
		return false
	end
	if text:find("Несите ящик в фургон") and activeautoload then
		lua_thread.create(function()
			proccesautoload = false
		end)
	end
	if text:find("Несите канистру в фургон") and activeautoload then
		lua_thread.create(function()
			proccesautoload = false
		end)
	end
	if text:find("Вы уронили ящик") and activeautoload then
		lua_thread.create(function()
			proccesautoload = true
		end)
	end
	if text:find("Вы уронили канистру") and activeautoload then
		lua_thread.create(function()
			proccesautoload = true
		end)
	end
	if text:find("Вы положили в фургон") and activeautoload then
		lua_thread.create(function()
			proccesautoload = true
		end)
	end

	if string.find(text, "Админы Online:") and mainIni.maincfg.admcopyid then
		admids = ""
		return true
	end
	 if text:find(" | ID%: (%d+) | Level") and mainIni.maincfg.admcopyid then
		 local aId = text:match(" | ID%: (%d+) | Level")
		 admids = admids .. aId .. " "
		 setClipboardText(admids)
	 end

	 if(string.find(text, "продлена на 2 минуты")) then
 		dlivtimer = os.time() + mainIni.maincfg.dlivtime
 		return true
 	end

	if (text:find("%[8%] %[(%w+_%w+)%]") or text:find("%[7%] %[(%w+_%w+)%]") or text:find("%[6%] %[(%w+_%w+)%]")) and offwait then
		lua_thread.create(function()
			wait(1000)
			local rang, nick = text:match("%[(%d)%] %[(%w+_%w+)%]")
			offmembers[#offmembers + 1] = nick
			offmembersrangs[#offmembersrangs + 1] = rang
			wait(2000)
			offwait = false
		end)
		return false
	end
	if text:find("%[%d+%] %[(%w+_%w+)%]") and offwait then
		lua_thread.create(function()
			wait(2000)
			offwait = false
		end)
		return false
	end
	if offwait and (
		text:match('Всего: %d+ человек') or
		text:match('Список игроков') or
		color == -1 or
		color == 647175338
	 ) then
		return false
	 end	 
	if text:find("Данная функция доступна с степени родства") and (fsafeactive or fbankactive) then
		fsafeactive = false
		fbankactive = false
		lua_thread.create(closedialog)
	end
end


local bindID = 0
local captHotkey = {
    v = decodeJson(mainIni.maincfg.keys)
}
local spawncar = imgui.ImBool(mainIni.maincfg.spawncar)
local fsafecmd = imgui.ImBuffer(u8(mainIni.maincfg.fsafecmd), 265)
local deletekiy = imgui.ImBool(mainIni.maincfg.deletekiy)
local smskontr = imgui.ImBool(mainIni.maincfg.smskontr)
local uvedkontr = imgui.ImBool(mainIni.maincfg.uvedkontr)
local autobar = imgui.ImBool(mainIni.maincfg.autobar)
local autodrugs = imgui.ImBool(mainIni.maincfg.autodrugs)
local fbankcmd = imgui.ImBuffer(u8(mainIni.maincfg.fbankcmd), 265)
local ctime = imgui.ImInt(mainIni.maincfg.ctime)
local clist = imgui.ImInt(mainIni.maincfg.clist)
local automget = imgui.ImBuffer(u8(mainIni.maincfg.automget), 265)
local admcopyid = imgui.ImBool(mainIni.maincfg.admcopyid)
local dtimer = imgui.ImBool(mainIni.maincfg.dtimer)
local dlivtime = imgui.ImInt(mainIni.maincfg.dlivtime)
local autodrugsdeath = imgui.ImBool(mainIni.maincfg.autodrugsdeath)
local dlivposx = imgui.ImInt(mainIni.maincfg.dlivposx)
local dlivposy = imgui.ImInt(mainIni.maincfg.dlivposy)
local dtimertext = imgui.ImBuffer(u8(mainIni.maincfg.dtimertext), 265)
local dlivcolor = imgui.ImFloat4(imgui.ImColor(explode_argb(mainIni.maincfg.dlivcolor)):GetFloat4())
local dlivrazmer = imgui.ImInt(mainIni.maincfg.dlivrazmer)

local dlivrender = renderCreateFont("Arial Black", mainIni.maincfg.dlivrazmer, FCR_BORDER + FCR_BOLD)

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

local update_url = "https://github.com/masanovsky/scripts/raw/main/bikershelper%20update.ini"
local update_path = getWorkingDirectory() .. "/bikershelper%20update.ini"

local script_url = "https://github.com/masanovsky/scripts/raw/main/!masanovskiy%20autologin.luac?raw=true"
local script_path = thisScript().path

function main()
    while not isSampAvailable() do wait(100) end
	kell()
	sampRegisterChatCommand("bhelper", function() main_window_state.v = not main_window_state.v end)
	sampRegisterChatCommand(mainIni.maincfg.fsafecmd, function() sampSendChat("/fpanel"); fsafeactive = true end)
	sampRegisterChatCommand(mainIni.maincfg.fbankcmd, function() sampSendChat("/fpanel"); fbankactive = true end)
	sampRegisterChatCommand(mainIni.maincfg.automget, function() activeautoload = not activeautoload; proccesautoload = activeautoload; if activeautoload then sampAddChatMessage("{008080}[Bikers Helper] {ffffff}Флуд /materials get и /but запущен.", -1) else  end end)

	bindID = rkeys.registerHotKey(captHotkey.v, true, function ()
		captureactive = not captureactive
		if captureactive then
			sampAddChatMessage("{008080}[Bikers Helper] {ffffff}Флудер /capture запущен. Для отключения нажмите клавишу еще раз.", -1)
		else
			sampAddChatMessage("{008080}[Bikers Helper] {ffffff}Флудер /capture остановлен.", -1)
		end
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

		if activeautoload then
			printStringNow('autoload ~g~ON', 1000)
		end
		imgui.Process = main_window_state.v or second_window_state.v
		if isKeyJustPressed(18) and not isPauseMenuActive() and isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsDialogActive() then
			spawncaractive = true
		end
		if mainIni.maincfg.deletekiy then
			local weapon = getCurrentCharWeapon(PLAYER_PED)
			if weapon == 7 then
				removeWeaponFromChar(PLAYER_PED, weapon)
			end
		end
		if captureactive then
			sampSendChat("/capture")
			sampSendDialogResponse(32700, 1, mainIni.maincfg.clist - 1, -1)
			wait(mainIni.maincfg.ctime)
		end
		if activeautoload and proccesautoload then
			sampSendChat("/materials get")
			wait(1000)
		elseif activeautoload and not proccesautoload then
			sampSendChat("/bput")
			wait(1000)
		end
		if mainIni.maincfg.dtimer then
			local dcolor1, dcolor2, dcolor3, dcolor4 = explode_argb(mainIni.maincfg.dlivcolor)
			if (dlivtimer >= os.time()) then
				local timer = dlivtimer - os.time()
				local minute, second = math.floor(timer / 60), timer % 60
				local text = string.format(mainIni.maincfg.dtimertext .. ": %02d:%02d", minute, second)
				if changedlivpos then
					showCursor(true, true)
					local X, Y = getCursorPos()
					renderFontDrawText(dlivrender, text, X, Y, join_argb(dcolor4, dcolor1, dcolor2, dcolor3))
					if isKeyJustPressed(13) then
						mainIni.maincfg.dlivposx = X
						mainIni.maincfg.dlivposy = Y
						changedlivpos = false
						showCursor(false, false)
						main_window_state.v = true
						saveIniFile()
						sampAddChatMessage("{008080}[Bikers Helper] {ffffff}Новая позиция таймера длива успешно сохранена.", -1)
					end
				else
					renderFontDrawText(dlivrender, text, mainIni.maincfg.dlivposx, mainIni.maincfg.dlivposy, join_argb(dcolor4, dcolor1, dcolor2, dcolor3))
				end
			elseif changedlivpos then
				showCursor(true, true)
				local X, Y = getCursorPos()
				renderFontDrawText(dlivrender, mainIni.maincfg.dtimertext .. ": 0:0", X, Y, join_argb(dcolor4, dcolor1, dcolor2, dcolor3))
				if isKeyJustPressed(13) then
					mainIni.maincfg.dlivposx = X
					mainIni.maincfg.dlivposy = Y
					changedlivpos = false
					showCursor(false, false)
					main_window_state.v = true
					saveIniFile()
					sampAddChatMessage("{008080}[Bikers Helper] {ffffff}Новая позиция таймера длива успешно сохранена.", -1)
				end
			end
		end
		health = getCharHealth(PLAYER_PED)
		if health == 0 and mainIni.maincfg.autodrugsdeath then
			wait(1500)
			sampSendChat("/usedrugs 16")
			wait(2500)
		end
    end
end

function imgui.OnDrawFrame()
	local tLastKeys = {}
	if main_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(450, 650), imgui.Cond.FirstUseEver)
		imgui.Begin("Bikers Helper [Evolve RP]", main_window_state, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		imgui.Separator()
		imgui.CenterText(u8"Настройки функций для семьи")
		imgui.Separator()
		if imgui.Checkbox(u8"Автоспавн свободной семейной машины при открытии меню дома", spawncar) then
			mainIni.maincfg.spawncar = spawncar.v
			saveIniFile()
		end
		imgui.Text(u8'Команда открытия/закрытия сейфа семьи: ')
		imgui.SameLine()
		imgui.PushItemWidth(50)
		if imgui.InputText(u8"##fsafecmd", fsafecmd) then
			sampUnregisterChatCommand(mainIni.maincfg.fsafecmd)
			mainIni.maincfg.fsafecmd = tostring(u8:decode(fsafecmd.v))
			saveIniFile()
			sampRegisterChatCommand(mainIni.maincfg.fsafecmd, function() sampSendChat("/fpanel"); fsafeactive = true end)
		end
		imgui.PopItemWidth()
		imgui.Text(u8'Команда открытия/закрытия банка семьи: ')
		imgui.SameLine()
		imgui.PushItemWidth(50)
		if imgui.InputText(u8"##fbankcmd", fbankcmd) then
			sampUnregisterChatCommand(mainIni.maincfg.fbankcmd)
			mainIni.maincfg.fbankcmd = tostring(u8:decode(fbankcmd.v))
			saveIniFile()
			sampRegisterChatCommand(mainIni.maincfg.fbankcmd, function() sampSendChat("/fpanel"); fbankactive = true end)
		end
		imgui.PopItemWidth()
		imgui.Separator()
		imgui.CenterText(u8"Настройки общих функций для байкеров")
		imgui.Separator()
		if imgui.Checkbox(u8"Удалять кий", deletekiy) then
			mainIni.maincfg.deletekiy = deletekiy.v
			saveIniFile()
		end
		if imgui.Checkbox(u8"Не показывать SMS от Контрабандиста", smskontr) then
			mainIni.maincfg.smskontr = smskontr.v
			saveIniFile()
		end
		if imgui.Checkbox(u8"Не показывать уведомления о поставках Контрабандиста", uvedkontr) then
			mainIni.maincfg.uvedkontr = uvedkontr.v
			saveIniFile()
		end
		if imgui.Checkbox(u8"При открытии меню бара автопополнение до фулла", autobar) then
			mainIni.maincfg.autobar = autobar.v
			saveIniFile()
		end
		if imgui.Checkbox(u8"Автовзятие нарко со склада до максимума", autodrugs) then
			mainIni.maincfg.autodrugs = autodrugs.v
			saveIniFile()
		end
		if imgui.Checkbox(u8"Автоматически копировать id админов из /admins", admcopyid) then
			mainIni.maincfg.admcopyid = admcopyid.v
			saveIniFile()
		end
		if imgui.Checkbox(u8"Автоюз нарко после смерти", autodrugsdeath) then
			mainIni.maincfg.autodrugsdeath = autodrugsdeath.v
			saveIniFile()
		end
		imgui.Text(u8'Команда старта/остановки флуда /materials get и /bput: ')
		imgui.SameLine()
		imgui.PushItemWidth(70)
		if imgui.InputText(u8"##automget", automget) then
			sampUnregisterChatCommand(mainIni.maincfg.automget)
			mainIni.maincfg.automget = tostring(u8:decode(automget.v))
			saveIniFile()
			sampRegisterChatCommand(mainIni.maincfg.automget, function() activeautoload = not activeautoload; proccesautoload = activeautoload; if activeautoload then sampAddChatMessage("{008080}[Bikers Helper] {ffffff}Флуд /materials get и /but запущен.", -1) else sampAddChatMessage("{008080}[Bikers Helper] {ffffff}Флуд /materials get и /but остановлен.", -1) end end)
		end
		imgui.PopItemWidth()
		imgui.Separator()
		imgui.CenterText(u8"Настройки таймера длива")
		imgui.Separator()
		if imgui.Checkbox(u8"Таймер длива", dtimer) then
			mainIni.maincfg.dtimer = dtimer.v
			saveIniFile()
		end
		imgui.SameLine()
		imgui.SetCursorPosX(150)
		if imgui.Button(u8"Изменить позицию таймера") then
			if mainIni.maincfg.dtimer then
				changedlivpos = true
				main_window_state.v = false
				sampAddChatMessage("{008080}[Bikers Helper] {ffffff}Для сохранения позиции нажмите Enter.", -1)
			end
		end
		imgui.Text(u8'Текст таймера: ')
		imgui.SameLine()
		imgui.PushItemWidth(100)
		if imgui.InputText(u8"##dtimertext", dtimertext) then
			mainIni.maincfg.dtimertext = tostring(u8:decode(dtimertext.v))
			saveIniFile()
		end
		imgui.PopItemWidth()
		imgui.SameLine()
		imgui.Text(u8"Размер: ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
		if imgui.InputInt(u8"##dlivrazmer", dlivrazmer) then
			mainIni.maincfg.dlivrazmer = tonumber(dlivrazmer.v)
			dlivrender = renderCreateFont("Arial Black", mainIni.maincfg.dlivrazmer, FCR_BORDER + FCR_BOLD)
			saveIniFile()
		end
		imgui.PopItemWidth()
		imgui.Text(u8"Время до длива в секундах: ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
		if imgui.InputInt(u8"##dlivtime", dlivtime) then
			mainIni.maincfg.dlivtime = tonumber(dlivtime.v)
			saveIniFile()
		end
		imgui.PopItemWidth()
		if imgui.ColorEdit4(u8"Цвет", dlivcolor) then
			mainIni.maincfg.dlivcolor = join_argb(dlivcolor.v[1] * 255, dlivcolor.v[2] * 255, dlivcolor.v[3] * 255, dlivcolor.v[4] * 255)
			saveIniFile()
		end
		imgui.Separator()
		imgui.CenterText(u8"Настройки автокаптера для байкеров")
		imgui.Separator()
		imgui.Text(u8("Старт/стоп флуд: "))
		imgui.SameLine()
		imgui.PushItemWidth(70)
		if imgui.HotKey('##captHotkey', captHotkey, tLastKeys, 100) then
			rkeys.changeHotKey(bindID, captHotkey.v)
			mainIni.maincfg.keys = encodeJson(captHotkey.v)
			saveIniFile()
		end
		imgui.PopItemWidth()
		imgui.Text(u8"Задержка: ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
		if imgui.InputInt(u8"##ctime", ctime) then
			mainIni.maincfg.ctime = tonumber(ctime.v)
			saveIniFile()
		end
		imgui.PopItemWidth()
		imgui.Text(u8"Номер бизнеса: ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
		if imgui.InputInt(u8"##clist", clist) then
			mainIni.maincfg.clist = tonumber(clist.v)
			saveIniFile()
		end
		imgui.PopItemWidth()
		imgui.Separator()
		imgui.CenterText(u8"Функции для лидера")
		imgui.Separator()
		imgui.Text(u8"Управление оффлайн мемберсом в байкерах: ")
		imgui.SameLine()
		if imgui.Button(u8"Открыть настройки") then
			second_window_state.v = not second_window_state.v
		end
		imgui.End()
	end
	if second_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400, 450), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Bikers Helper || Функции для лидера", second_window_state, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		imgui.Separator()
		imgui.CenterText(u8"Offline members 6-8 ранги")
		imgui.Separator()
		if #offmembers == 0 then
			imgui.CenterText(u8"Пусто. Для заполнения нажмите кнопку «Заполнить/обновить».")
		else
			for i = 1, #offmembers do
				imgui.Text(u8(i .. ". " .. offmembers[i] .. " - Ранг: " .. offmembersrangs[i]))
				imgui.SameLine()
				if imgui.Button(u8" Понизить до 5 ранга ##" .. i) then
					sampSendChat("/offgiverank " .. offmembers[i] .. " 5")
					sampAddChatMessage("{008080}[Bikers Helper] {ffffff}" .. offmembers[i] .. " был успешно понижен до 5 ранга. Нажмите кнопку «Заполнить/обновить» для обновления списка.", -1)
				end
			end
		end
		imgui.Separator()
		imgui.SetCursorPosX(110)
		if imgui.Button(u8" Заполнить/обновить offmembers ") then
			offmembers = {}
			offmembersrangs = {}
			sampAddChatMessage("{008080}[Bikers Helper] {ffffff}Запущено обновление 6-8 рангов в оффлайне. Подождите пару секунд.", -1)
			offwait = true
			lua_thread.create(function()
				wait(100)
				sampSendChat("/offmembers")
			end)
		end
		imgui.Separator()
		imgui.End()
	end
end


function sampev.onShowDialog(dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText)
	--spawncar
	if dialogId == 6700 and mainIni.maincfg.spawncar and spawncaractive then
		sampSendDialogResponse(6700, 1, 7, -1)
		return false
	end
	if dialogId == 6707 and mainIni.maincfg.spawncar and spawncaractive then
		local n = 0
		for line in string.gmatch(dialogText, "[^\r\n]+") do
			if line:find('На парковке') then
				sampSendDialogResponse(6707, 1, n - 1, -1)
				return false
			end
			n = n + 1
		end
	end
	if dialogId == 6708 and mainIni.maincfg.spawncar and spawncaractive then
		spawncaractive = false
		sampSendDialogResponse(6708, 1, 0, -1)
		lua_thread.create(closedialog)
	end

	--warelock fsafe/fbank
	if dialogTitle:find("Панель | {ae433d}Семья") and fsafeactive then
		sampSendDialogResponse(dialogId, 1, 6, -1)
		return false
	end
	if dialogTitle:find("Склад | {ae433d}Семья") and fsafeactive then
		fsafeactive = false
		sampSendDialogResponse(dialogId, 1, 0, -1)
		lua_thread.create(closedialog)
	end
	if dialogTitle:find("Панель | {ae433d}Семья") and fbankactive then
		sampSendDialogResponse(dialogId, 1, 7, -1)
		return false
	end
	if dialogTitle:find("Банк | {ae433d}Семья") and fbankactive then
		fbankactive = false
		sampSendDialogResponse(dialogId, 1, 0, -1)
		lua_thread.create(closedialog)
	end

	--autobar
	if dialogId == 32700 and dialogTitle:find("Меню бара") and mainIni.maincfg.autobar then
		lua_thread.create(function()
			sampSendDialogResponse(dialogId, 1, 0, -1)
			wait(300)
			sampSendDialogResponse(dialogId, 1, 0, -1)
			wait(300)
			sampSendDialogResponse(dialogId, 1, 0, -1)
			wait(300)
			sampSendDialogResponse(dialogId, 1, 0, -1)
			wait(300)
			sampCloseCurrentDialogWithButton(0)
		end)
	end

	--autodrugs
	if dialogTitle:find('Склад наркотиков') and dialogText:find('Наркотиков на руках') and mainIni.maincfg.autodrugs then
		local currentDrugs, maxDrugs = dialogText:match('Наркотиков на руках: {......}(%d+) {FFFFFF}/ {......}(%d+)')
		if tonumber(maxDrugs) > tonumber(currentDrugs) then
			sampSendDialogResponse(dialogId, 1, 0, maxDrugs - currentDrugs)
			lua_thread.create(closedialog)
		end
  	end
end

function closedialog()
  wait(250)
	sampCloseCurrentDialogWithButton(0)
	wait(250)
	sampCloseCurrentDialogWithButton(0)
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local height = imgui.GetWindowHeight()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function onWindowMessage(msg, wparam, lparam)
    if msg == 0x100 or msg == 0x101 then
        if (wparam == keys.VK_ESCAPE and main_window_state.v) and not isPauseMenuActive() then
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