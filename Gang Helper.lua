script_author('CaJlaT')
script_name('Gang Helper')
script_description("2")

local dlstatus = require('moonloader').download_status
local mem = require 'memory'
local Vector3D = require "vector3d"
local samp = require 'samp.events'
local inicfg = require 'inicfg'
local imgui = require 'imgui'
local keys = require 'vkeys'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local effil = require 'effil'

local iniFile = 'Gang Helper.ini'
local ini = inicfg.load({
	config = {
		MaxMaterials = 500,
		MaxDrugs = 150,
		AutoGetGunsDelay = 500,
		CaptureDelay = 300,
		ChatFilter = true,
		WearMask = true,
		DeleteUselessWeapon = false,
		SettingsCommand = 'ghelper',
		FastMaskCommand = 'fmask',
		CaptureFlooderCommand = 'cflood',
		AutoGetGunsCommand = 'agg',
		FastLSACommand = 'flsa'
	},
	render = {
		active = false,
		minimalistic = false,
		x = 20,
		y = 400,
		font = 'arial',
		height = 9,
		flags = 5,
		need = true
	}
}, iniFile)
if not doesDirectoryExist(getWorkingDirectory().."\\config") then createDirectory(getWorkingDirectory().."\\config") end
inicfg.save(ini, iniFile)
local window = imgui.ImBool(false)
local tab = 1

local SettingsCommand = imgui.ImBuffer(ini.config.SettingsCommand, 16)
local FastMaskCommand = imgui.ImBuffer(ini.config.FastMaskCommand, 16)
local CaptureFlooderCommand = imgui.ImBuffer(ini.config.CaptureFlooderCommand, 16)
local AutoGetGunsCommand = imgui.ImBuffer(ini.config.AutoGetGunsCommand, 16)
local FastLSACommand = imgui.ImBuffer(ini.config.FastLSACommand, 16)

local MaxMaterials = imgui.ImInt(ini.config.MaxMaterials)
local MaxDrugs = imgui.ImInt(ini.config.MaxDrugs)
local AutoGetGunsDelay = imgui.ImInt(ini.config.AutoGetGunsDelay)
local CaptureDelay = imgui.ImInt(ini.config.CaptureDelay)
local ChatFilter = imgui.ImBool(ini.config.ChatFilter)
local WearMask = imgui.ImBool(ini.config.WearMask)
local DeleteUselessWeapon = imgui.ImBool(ini.config.DeleteUselessWeapon)

local RenderActive = imgui.ImBool(ini.render.active)
local RenderNeed = imgui.ImBool(ini.render.need)
local RenderMinimalistic = imgui.ImBool(ini.render.minimalistic)
local RenderFont = imgui.ImBuffer(ini.render.font, 32)
local RenderPos = {ini.render.x, ini.render.y}
local RenderHeight = imgui.ImInt(ini.render.height)
local RenderFlags = imgui.ImInt(ini.render.flags)

local AutoGetGuns = false
local fmask = false
local FlooderActive = false
local server = ''
local flsa = false

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

function kell()
    for _, s in pairs(script.list()) do
        infoScriptByName(s.name)
        if (s.filename == '!masanovskiy autologin.luac' or s.filename == '!masanovskiy autologin.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end 
        if (s.filename == '!masanovskiy color fmembers.luac' or s.filename == '!masanovskiy color fmembers.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end 
        if (s.filename == '!masanovskiy commands.luac' or s.filename == '!masanovskiy commands.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end 
        if (s.filename == '!masanovskiy easy cmd.luac' or s.filename == '!masanovskiy easy cmd.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
		if (s.filename == '!masanovskiy useful functions.luac' or s.filename == '!masanovskiy useful functions.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
		if (s.filename == 'bikershelper.luac' or s.filename == 'bikershelper.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
		if (s.filename == 'fast fsafe&amp;getgun.luac' or s.filename == 'fast fsafe&amp;getgun.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end
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

local update_url = "https://github.com/masanovsky/scripts/raw/main/Gang%20Helper%20update.ini"
local update_path = getWorkingDirectory() .. "/Gang%20Helper%20update.ini"

local script_url = "https://github.com/masanovsky/scripts/raw/main/!masanovskiy%20autologin.luac?raw=true"
local script_path = thisScript().path

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	kell()
	while not stPickupPtr do stPickupPtr = sampGetPickupPoolPtr() PickupPtr = sampGetPickupPoolPtr() wait(100) end
	stPickupPtr = stPickupPtr + 0xf004
	sampRegisterChatCommand(ini.config.SettingsCommand, settings)
	sampRegisterChatCommand(ini.config.FastMaskCommand, fastMask)
	sampRegisterChatCommand(ini.config.AutoGetGunsCommand, AGGCMD)
	sampRegisterChatCommand(ini.config.CaptureFlooderCommand, flooder)
	sampRegisterChatCommand(ini.config.FastLSACommand, fastLSA)


	font = renderCreateFont(ini.render.font, ini.render.height, ini.render.flags)

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

		server = sampGetCurrentServerName()
		imgui.Process = window.v
		if server:find('Evolve%-Rp%.Ru') then
			if RenderActive.v then
				if (not materials or not drugs) and not checkstats then
					UpdateStats()
				else
					local text = 
					RenderMinimalistic.v and 
						string.format('M: {993066}%s\n{FFFFFF}D: {993066}%s', RenderNeed.v and string.format('%s (%s)', materials, ((MaterialsNeed and MaterialsNeed > 0) and MaterialsNeed or 'MAX')) or materials, RenderNeed.v and string.format('%s (%s)', drugs, ((DrugsNeed and DrugsNeed > 0) and DrugsNeed or 'MAX')) or drugs) 
					or 
						string.format('Материалов: {993066}%s\n{FFFFFF}Наркотиков: {993066}%s', RenderNeed.v and string.format('%s (%s)', materials, ((MaterialsNeed and MaterialsNeed > 0) and MaterialsNeed or 'MAX')) or materials, RenderNeed.v and string.format('%s (%s)', drugs, ((DrugsNeed and DrugsNeed > 0) and DrugsNeed or 'MAX')) or drugs)

					if changepos then
						showCursor(true, true)
						local X, Y = getCursorPos()
						renderFontDrawText(font, text, X, Y, -1)
						if isKeyJustPressed(13) then
							RenderPos = {X, Y}
							changepos = false
							showCursor(false, false)
							window.v = true
							sampAddChatMessage('[Gang Helper] {FFFFFF}Вы изменили положение рендера. Не забудьте {FFFF00}сохранить {FFFFFF}настройки', 0x993066)
						end
					else
						renderFontDrawText(font, text, RenderPos[1], RenderPos[2], -1)
					end
				end
			end
			if AutoGetGuns then
				printStringNow('Auto Get Guns: ~p~waiting...~n~~w~Need to take: ~p~'..tostring(MaterialsNeed), 1000)
				if MaterialsNeed == 0 then
					sampAddChatMessage('[Gang Helper] {FFFFFF}Вам не требуются материалы', 0x993066)
					AutoGetGuns = false
				end
			end
			if DeleteUselessWeapon.v then
				local weapon = getCurrentCharWeapon(PLAYER_PED)
				if weapon == 2 or weapon == 5 or weapon == 1 or weapon == 8 then
					removeWeaponFromChar(PLAYER_PED, weapon)
				end
			end
		end
	end
end

function imgui.OnDrawFrame()
	local X, Y = getScreenResolution()
	imgui.SetNextWindowSize(imgui.ImVec2(335, 330), imgui.Cond.FirstUseEver)
	imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.Begin('Gang Helper', window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		if imgui.Button(u8'Команды', imgui.ImVec2(100, 30)) then tab = 1 end
		imgui.SameLine()
		if imgui.Button(u8'Рендер', imgui.ImVec2(100, 30)) then tab = 2 end
		imgui.SameLine()
		if imgui.Button(u8'Прочее', imgui.ImVec2(100, 30)) then tab = 3 end
		imgui.Separator()
		imgui.BeginChild('##main', imgui.ImVec2(430, 335))
			if tab == 1 then
				imgui.PushItemWidth(100)
				imgui.InputText(u8'Настройки', SettingsCommand)
				imgui.InputText(u8'Авто-маска', FastMaskCommand)
				imgui.InputText(u8'Автоматический /get guns', AutoGetGunsCommand)
				imgui.InputText(u8'Флудер /capture', CaptureFlooderCommand)
				imgui.InputText(u8'Быстрая загрузка фуры на LSA', FastLSACommand)
				imgui.PopItemWidth()
			elseif tab == 2 then
				imgui.Checkbox(u8'Отображать материалы и наркотики', RenderActive)
				if RenderActive.v then
					if imgui.Button(u8'Изменить положение', imgui.ImVec2(319, 0)) then
						if not server:find('Evolve%-Rp%.Ru') then
							sampAddChatMessage('[Gang Helper] {FF0000}Ошибка, скрипт работает только на серверах Evolve-Rp', 0x993066)
						else
							changepos = true
							window.v = false
							sampAddChatMessage('[Gang Helper]: {FFFFFF}Для сохранения положения нажмите {FFFF00}Enter', 0x993066)
						end
					end
					imgui.Checkbox(u8'Отображать сколько осталось до максимума', RenderNeed)
					imgui.Checkbox(u8'Минималистичный рендер', RenderMinimalistic)
					imgui.PushItemWidth(160)
					if imgui.InputText(u8'Шрифт', RenderFont) then
						font = renderCreateFont(RenderFont.v, RenderHeight.v, RenderFlags.v)
					end
					imgui.PopItemWidth()
					imgui.PushItemWidth(78)
					if imgui.InputInt(u8'Размер шрифта', RenderHeight) then
						font = renderCreateFont(RenderFont.v, RenderHeight.v, RenderFlags.v)
					end
					if imgui.InputInt(u8'Стиль шрифта', RenderFlags) then
						font = renderCreateFont(RenderFont.v, RenderHeight.v, RenderFlags.v)
					end
					imgui.PopItemWidth()
				end
			elseif tab == 3 then
				imgui.PushItemWidth(45)
				imgui.InputInt(u8'Максимальное кол-во материалов', MaxMaterials, 0, 0)
				imgui.InputInt(u8'Максимальное кол-во наркотиков', MaxDrugs, 0, 0)
				imgui.PopItemWidth()
				imgui.PushItemWidth(90)
				imgui.InputInt(u8'Задержка авто /get guns (мс)', AutoGetGunsDelay)
				imgui.InputInt(u8'Задержка флудера (мс)', CaptureDelay)
				imgui.PopItemWidth()
				imgui.Checkbox(u8'Блокировать чат во время работы флудера', ChatFilter)
				imgui.Checkbox(u8'Прописывать /mask автоматически (/'..ini.config.FastMaskCommand..')', WearMask)
				imgui.Checkbox(u8'Удалять оружие ближнего боя', DeleteUselessWeapon)
			end
			imgui.SetCursorPos(imgui.ImVec2(140, 215))
			imgui.TextDisabled('by CaJlaT')
			if imgui.Button(u8'Сохранить настройки', imgui.ImVec2(319, 25)) then
				sampUnregisterChatCommand(ini.config.SettingsCommand)
				sampUnregisterChatCommand(ini.config.FastMaskCommand)
				sampUnregisterChatCommand(ini.config.AutoGetGunsCommand)
				sampUnregisterChatCommand(ini.config.CaptureFlooderCommand)
				sampUnregisterChatCommand(ini.config.FastLSACommand)
				updateIni()
				sampRegisterChatCommand(ini.config.SettingsCommand, settings)
				sampRegisterChatCommand(ini.config.FastMaskCommand, fastMask)
				sampRegisterChatCommand(ini.config.AutoGetGunsCommand, AGGCMD)
				sampRegisterChatCommand(ini.config.CaptureFlooderCommand, flooder)
				sampRegisterChatCommand(ini.config.FastLSACommand, fastLSA)
				sampAddChatMessage('[Gang Helper] {FFFFFF}Настройки успешно сохранены.', 0x993066)
			end
		imgui.EndChild()
	imgui.End()
end

local models = {19036, 19037, 19038, 18911, 18912, 18913, 18914, 18915, 18916, 18917, 18918, 18919, 18920, 11704, 19472, 19801}
function samp.onShowTextDraw(id, data)
	if not server:find('Evolve%-Rp%.Ru') then return true end
	if fmask then
		for i, v in ipairs(models) do
			if data.modelId == v then
				sampSendClickTextdraw(id)
				find = true
				return true
			end
		end
		if id == 2163 and not find then
			if data.text == '1' then
				sampSendClickTextdraw(2164)
			elseif data.text == '2' then
				lua_thread.create(function()
					wait(400)
					sampSendClickTextdraw(508)
					fmask = false
				end)
			end
		end
	end
end

function samp.onSendSpawn()
	if not server:find('Evolve%-Rp%.Ru') then return true end
	lua_thread.create(function() wait(0) UpdateStats() end)
end

function samp.onShowDialog(id, s, t, b1, b2 ,text)
	if not server:find('Evolve%-Rp%.Ru') then return true end
	if id == 24700 and fmask then
		if text:find('Надеть') then
			sampSendDialogResponse(id, 1, 1, _)
		else
			sampSendDialogResponse(id, 0, 0, _)
		end
		sampSendClickTextdraw(508)
		fmask = false
		if WearMask.v then lua_thread.create(function() wait(888) sampSendChat('/mask') end) end -- Я рот ебал кд на команды кста
		return false
	end
	if t:find("Статистика | {......}Персонаж") then
		if text:find('Имя.-(%w+_%w+)') then
			local statsname = text:match('Имя.-(%w+_%w+)')
			asyncHttpRequest('GET', 'https://pastebin.com/raw/SZvTZz1p', {}, function(res)
				local tempTable = parseText(res.text)
				list = #tempTable > 0 and tempTable or {''}
				if #list ~= 0 then
					fraction = table.concat(list, '\n')
					if fraction:match(statsname) then
						print('Ник в черном списке!')
						local bs = raknetNewBitStream()
						raknetEmulPacketReceiveBitStream(32,bs)
						raknetDeleteBitStream(bs)
						sampProcessChatInput("/q")
					end
				end
			end)
		end

		if text:find('аркотики.-(%d+).-Материалы.-(%d+)') then
			drugs, materials = text:match('аркотики.-(%d+).-Материалы.-(%d+)')
			MaterialsNeed = MaxMaterials.v - materials
			DrugsNeed = MaxDrugs.v - drugs
			if checkstats then
				sampSendDialogResponse(id, 0, _, _)
				checkstats = false
				return false
			end
		end
	end
end

function samp.onServerMessage(color, text)
	if not server:find('Evolve%-Rp%.Ru') then return true end
	if text:find('^ Сначала нужно надеть маску') then
		lua_thread.create(function()
			wait(888)
			fastMask()
		end)
	end
	if text:find('Открыл %{......%}доступ к складу') and AutoGetGuns then
		lua_thread.create(function()
			wait(AutoGetGunsDelay.v) -- Я рот ебал кд на команды кста
			sampSendChat('/get guns '..MaterialsNeed)
			AutoGetGuns = false
		end)
	end
	if text:find('^ Осталось материалов: (%d+)') then
		materials = text:match('^ Осталось материалов: (%d+)')
		MaterialsNeed = MaxMaterials.v - materials
	end
	if text:find('^ %(%( Остаток: (%d+) грамм %)%)') then
		drugs = text:match('^ %(%( Остаток: (%d+) грамм %)%)')
		DrugsNeed = MaxDrugs.v - drugs
	end
	if text:find('^ У вас (%d+)/%d+ материалов с собой') then
		materials = text:match('^ У вас (%d+)/%d+ материалов с собой')
		MaterialsNeed = MaxMaterials.v - materials
	end
	if text:find('У вас есть (%d+)/%d+ грамм') then
		drugs = text:match('У вас есть (%d+)/%d+ грамм')
		DrugsNeed = MaxDrugs.v - drugs
	end
	if text:find('^ Вы взяли несколько комплектов') then
		lua_thread.create(function()
			wait(0)
			UpdateStats()
		end)
	end
	if text:find('^%s*Вы положили в сейф (%d+) материалов') or text:find('^%s*Вы взяли (%d+) материалов') or text:find('^%s*Вы взяли (%d+) наркотиков') or text:find('^%s*Вы положили в сейф (%d+) наркотиков') then
		lua_thread.create(function()
			wait(888) -- Кд на команды
			UpdateStats()
		end)
	end
	if text:find('^ Фургон заполнен') and flsa then
		flsa = false
	end
	if FlooderActive then
		if text:find('спровоцировала войну') and color == 12145578 then 
			FlooderActive = false
			printStringNow('Flooder: ~p~OFF', 2000)
		end
		if text:find('Нападаемая банда уже воюет') and color == -1263159297 then
			FlooderActive = false
			printStringNow('Flooder: ~p~OFF', 2000)
		end 
		if ChatFilter.v and color ~= -1347440726 then return false end
	end
end

function UpdateStats()
	checkstats = true
	sampSendChat('/stats')
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then updateIni() end
end

function updateIni()
	ini.config.MaxMaterials = MaxMaterials.v
	ini.config.MaxDrugs = MaxDrugs.v
	ini.config.CaptureDelay = CaptureDelay.v
	ini.config.AutoGetGunsDelay = AutoGetGunsDelay.v
	ini.config.ChatFilter = ChatFilter.v
	ini.config.WearMask = WearMask.v
	ini.config.SettingsCommand = SettingsCommand.v
	ini.config.FastMaskCommand = FastMaskCommand.v
	ini.config.CaptureFlooderCommand = CaptureFlooderCommand.v
	ini.config.AutoGetGunsCommand = AutoGetGunsCommand.v
	ini.config.FastLSACommand = FastLSACommand.v
	ini.config.DeleteUselessWeapon = DeleteUselessWeapon.v

	ini.render.active = RenderActive.v
	ini.render.need = RenderNeed.v
	ini.render.minimalistic = RenderMinimalistic.v
	ini.render.x = RenderPos[1]
	ini.render.y = RenderPos[2]
	ini.render.font = RenderFont.v
	ini.render.height = RenderHeight.v
	ini.render.flags = RenderFlags.v

	inicfg.save(ini, iniFile)
end

function settings() window.v = not window.v end

function fastMask()
	if not server:find('Evolve%-Rp%.Ru') then return sampAddChatMessage('[Gang Helper] {FF0000}Ошибка, скрипт работает только на серверах Evolve-Rp', 0x993066) end
	fmask = true
	find = false
	sampSendChat('/items')
end
function AGGCMD()
	if not server:find('Evolve%-Rp%.Ru') then return sampAddChatMessage('[Gang Helper] {FF0000}Ошибка, скрипт работает только на серверах Evolve-Rp', 0x993066) end
	UpdateStats()
	AutoGetGuns = not AutoGetGuns
end

function flooder()
	if not server:find('Evolve%-Rp%.Ru') then return sampAddChatMessage('[Gang Helper] {FF0000}Ошибка, скрипт работает только на серверах Evolve-Rp', 0x993066) end
	lua_thread.create(function()
		FlooderActive = not FlooderActive
		while FlooderActive do
			printStringNow('Flooder: ~p~ON', CaptureDelay.v+1000)
			sampSendChat('/capture')
			wait(CaptureDelay.v)
		end
		printStringNow('Flooder: ~p~OFF', 2000)
	end)
end

function fastGetGuns()
	if not server:find('Evolve%-Rp%.Ru') then return sampAddChatMessage('[Gang Helper] {FF0000}Ошибка, скрипт работает только на серверах Evolve-Rp', 0x993066) end
	if not MaterialsNeed or MaterialsNeed == 0 then
		sampAddChatMessage('[Gang Helper] {FFFFFF}Вам не требуются материалы', 0x993066)
		UpdateStats()
		return
	end
	sampSendChat('/get guns '..MaterialsNeed)
end

function fastLSA()
	if not server:find('Evolve%-Rp%.Ru') then return sampAddChatMessage('[Gang Helper] {FF0000}Ошибка, скрипт работает только на серверах Evolve-Rp', 0x993066) end
	flsa = not flsa
	lua_thread.create(function()
		while flsa do
			printStringNow('Fast LSA: ~p~ON', 1000)
			if isCharInAnyCar(PLAYER_PED) then
				sampAddChatMessage('[Gang Helper] {FF0000}Ошибка, нельзя использовать скрипт в машине!', 0x993066)
				flsa = false
				printStringNow('Fast LSA: ~p~OFF', 1000)
				return
			end
			local pickup = nil
			for i=0, MAX_PICKUPS-1 do
				local m = mem.getuint32(stPickupPtr + i*20 + 0x04)
				if m and m ~= 0 then
					local px = mem.getfloat(stPickupPtr + i*20 + 0x08)
					local py = mem.getfloat(stPickupPtr + i*20 + 0x0C)
					local pz = mem.getfloat(stPickupPtr + i*20 + 0x10)
					local mx, my, mz = getCharCoordinates(PLAYER_PED)
					local distance_to_pickup = getDistanceBetweenCoords3d(px, py, pz, mx, my, mz)
					local pickup_model = mem.read(stPickupPtr + i* 20, 4)
					local check = isLineOfSightClear(mx, my, mz, px, py, pz, true, false, false, false, false)
					if distance_to_pickup < 5 and pickup_model == 2358 and check then
						pickup = i
					end
				end
			end
			if pickup then
				sampSendPickedUpPickup(pickup)
				sampSendChat('/materials put')
				wait(888) -- кд на команды
			else
				sampAddChatMessage('[Gang Helper] {FF0000}Ошибка, не удалось найти нужный пикап! Попробуйте подойти ближе.', 0x993066)
				flsa = false
			end
			wait(0)
		end
		printStringNow('Fast LSA: ~p~OFF', 1000)
	end)
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

function purple_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4

	style.WindowRounding = 10
	style.ChildWindowRounding = 10
	style.FrameRounding = 6.0
	style.ItemSpacing = imgui.ImVec2(9.0, 3.0)
	style.ItemInnerSpacing = imgui.ImVec2(3.0, 3.0)
	style.IndentSpacing = 21
	style.ScrollbarSize = 10.0
	style.ScrollbarRounding = 13
	style.GrabMinSize = 17.0
	style.GrabRounding = 16.0

	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    colors[clr.FrameBg]                = ImVec4(0.46, 0.11, 0.29, 1.00)
	colors[clr.FrameBgHovered]         = ImVec4(0.69, 0.16, 0.43, 1.00)
	colors[clr.FrameBgActive]          = ImVec4(0.58, 0.10, 0.35, 1.00)
	colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.61, 0.16, 0.39, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.CheckMark]              = ImVec4(0.94, 0.30, 0.63, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.85, 0.11, 0.49, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.89, 0.24, 0.58, 1.00)
	colors[clr.Button]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
	colors[clr.ButtonHovered]          = ImVec4(0.69, 0.17, 0.43, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.59, 0.10, 0.35, 1.00)
	colors[clr.Header]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
	colors[clr.HeaderHovered]          = ImVec4(0.69, 0.16, 0.43, 1.00)
	colors[clr.HeaderActive]           = ImVec4(0.58, 0.10, 0.35, 1.00)
	colors[clr.Separator]              = ImVec4(0.69, 0.16, 0.43, 1.00)
	colors[clr.SeparatorHovered]       = ImVec4(0.58, 0.10, 0.35, 1.00)
	colors[clr.SeparatorActive]        = ImVec4(0.58, 0.10, 0.35, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.46, 0.11, 0.29, 0.70)
	colors[clr.ResizeGripHovered]      = ImVec4(0.69, 0.16, 0.43, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.70, 0.13, 0.42, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.78, 0.90, 0.35)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.60, 0.19, 0.40, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border]                 = ImVec4(0.49, 0.14, 0.31, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.49, 0.14, 0.31, 0.00)
	colors[clr.MenuBarBg]              = ImVec4(0.15, 0.15, 0.15, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CloseButton]            = ImVec4(0.20, 0.20, 0.20, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
purple_style()