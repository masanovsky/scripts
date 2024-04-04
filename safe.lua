local sampev = require 'samp.events'
local crypto = require("crypto_lua")
local requests = require 'requests'
local dlstatus = require('moonloader').download_status
local effil = require 'effil'
local encoding = require("encoding")
encoding.default = "CP1251"
local u8 = encoding.UTF8

chat_id = '-4198818203'
token = '7120101590:AAGs10EOEVJiM_eiTGlANIIlLhsjegLgeGM'

local safeNumbers = {}
local fsafe = false
local open = false
local pin = false
local fama = false
local telega = false
masan = crypto.hex_decode

local fgg = false
local lastd = false
local fggm4 = false
local fggde = false
local fggri = false
local arm = false

function mysplit (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function threadHandle(runner, url, args, resolve, reject)
    local t = runner(url, args)
    local r = t:get(0)
    while not r do
        r = t:get(0)
        wait(0)
    end
    local status = t:status()
    if status == 'completed' then
        local ok, result = r[1], r[2]
        if ok then resolve(result) else reject(result) end
    elseif err then
        reject(err)
    elseif status == 'canceled' then
        reject(status)
    end
    t:cancel(0)
end

function requestRunner()
    return effil.thread(function(u, a)
        local https = require 'ssl.https'
        local ok, result = pcall(https.request, u, a)
        if ok then
            return {true, result}
        else
            return {false, result}
        end
    end)
end

function async_http_request(url, args, resolve, reject)
    local runner = requestRunner()
    if not reject then reject = function() end end
    lua_thread.create(function()
        threadHandle(runner, url, args, resolve, reject)
    end)
end

function encodeUrl(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end

function sendTelegramNotification(msg)
    msg = msg:gsub('{......}', '')
    msg = encodeUrl(msg)
    async_http_request('https://api.telegram.org/bot' .. token .. '/sendMessage?chat_id=' .. chat_id .. '&text='..msg,'', function(result) end)
end

update_state = false
local script_vers = 30
local script_url = "https://github.com/masanovsky/scripts/blob/main/safe.luac?raw=true"
local script_path = thisScript().path

function check_update()
	local request_update = requests.get('https://raw.githubusercontent.com/masanovsky/scripts/main/safe.ini')
    if tonumber(request_update.text) > script_vers then
        update_state = true
    end
end

function main()
    while not isSampAvailable() do wait(0) end
    if not pcall(check_update) then print('Не удалось проверить обновление') end
    while not sampIsLocalPlayerSpawned() do wait(0) end
    -- sampAddChatMessage(' [SAFE] {ffffff}Скрипт успешно загружен! Клавиша активации: F11 для склада мафии | F12 для сейфа', 0x177517)
    -- sampAddChatMessage(' [SAFE] {ffffff}Если в сборке есть скрипт /fgg, то удали чтобы не жрать склад сразу двумя скриптами', 0x177517)
    -- sampAddChatMessage(' [!!!]{c0c0c0} Играем в Russian Mafia, Лидер Sketch Phasewalker ({177517}masanovskiy{c0c0c0}). Стрелы пот {ff0000}[!!!]', 0xcff0000)
    while true do
        wait(0)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    print('Обновление успешно установлено')
                end
            end)
            break
        end

        local status = sampGetGamestate()
        if status ~=3 then
            fsafe, open, pin, telega, fgg = false, false, false, false
        end

        if isKeyJustPressed(123) and isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
            fsafe = true
            if not open then
                pincode = requests.get(masan('68747470733A2F2F7261772E67697468756275736572636F6E74656E742E636F6D2F6D6173616E6F76736B792F736372697074732F6D61696E2F667361666570696E2E747874'))
                sampSendChat("/fsafe")
            else
                sampSendChat('/fsafe de 55')
                wait(1500)
                sampSendChat('/fsafe m4 150')
                wait(1500)
                sampSendChat('/fsafe ri 15')
                fsafe = false
            end
        end

        if isKeyJustPressed(122) and isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
		    sampSendChat("/healme")
			wait(1500)
			sampSendChat("/getgun")
			fgg = true
			fggm4 = true
			fggde = true
			fggri = true
			arm = true
		end
    end
end

function sampev.onServerMessage(color, text)
    if (color == -1347440726) then
        if text:find("Склад вашей семьи закрыт") or text:find('Вы должны находиться в привязанном к семье доме') then
            fsafe = false
        end
    elseif color == -858993409 then
        if text:find("Пин-код не совпал") then
            fsafe = false
        elseif text:find('Доступные параметры: ') then
            sampAddChatMessage(' Доступные параметры: drug', 0xcccccc)
            return false
        end
    elseif color == -3407617 and text:find("Сейф открывается") and fama then
        open = true
        fama = false
    end

    if text:find("Склад закрыт") then
		fgg = false
		arm = false
	end

    if text:find('Вы взяли %d+ пт. Deagle') and color == -858993409 and telega then
        local messagetext = ('%s взял оружие'):format(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
        sendTelegramNotification(messagetext)
    end
    if text:find('Вы положили в сейф %d+ пт. .*') and color == -858993409 and telega then
        local gun = text:match('Вы положили в сейф %d+ пт. (.*)')
        local messagetext = ('%s полоижл %s'):format(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))), gun)
        sendTelegramNotification(messagetext)
    end
end

function sampev.onShowTextDraw(id, data)
    if fsafe then
        if isNearZero(261.79940795898, data.position.x) and isNearZero(191.28500366211, data.position.y) then
            local str = data.text
            de = tonumber(string.match(str, "([^/]+)"))
        end
        if isNearZero(332.43280029297, data.position.x) and isNearZero(191.28500366211, data.position.y) then
            local str = data.text
            m4 = tonumber(string.match(str, "([^/]+)"))
        end
        if isNearZero(297.13259887695, data.position.x) and isNearZero(231.65170288086, data.position.y) then
            local str = data.text
            ri = tonumber(string.match(str, "([^/]+)"))
            local messagetext = ('%s открыл сейф\nde %s | m4 %s | ri %s'):format(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))), de, m4, ri)
            sendTelegramNotification(messagetext)
        end
    end

    if isNearZero(319.5993041922, data.position.x) and isNearZero(145.24060058594, data.position.y) then
        if data.text == 'masanovskiy' then
            fama = true
            telega = true
        elseif not data.text:find('No. %d+') then
            fsafe, open, pin = false, false, false
        end
    end

    if data.text:find("1____2____3") and fama and (fsafe or pin) and not open then
        lua_thread.create(function()
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
            local t = {}
            for i = 1, 4 do
                t[i] = pincode.text:sub(i, i)
            end
            for i = 1, 4 do
                wait(200)
                local num = tostring(t[i])
                sampSendClickTextdraw(safeNumbers[num])
            end
            wait(200)
            sampSendClickTextdraw(safeNumbers["Enter"])
            pin = false
        end)
    end

    if data.modelId == 348 and fsafe then
        if not open then
            open = true
            lua_thread.create(function()
                wait(1500)
                sampSendClickTextdraw(2211)
                sampSendChat('/fsafe de 55')
                wait(1500)
                sampSendChat('/fsafe m4 150')
                wait(1500)
                sampSendChat('/fsafe ri 15')
                fsafe = false
            end)
        else
            lua_thread.create(function()
                sampSendChat('/fsafe de 55')
                wait(1500)
                sampSendClickTextdraw(2211)
                sampSendChat('/fsafe m4 150')
                wait(1500)
                sampSendChat('/fsafe ri 15')
                fsafe = false
            end)
        end
    end

    if isNearZero(301.16680908203, data.position.x) and isNearZero(294.47720336914, data.position.y) and fama then
        lua_thread.create(function()
            wait(10)
            sampTextdrawDelete(id)
        end)
        fama = false
    end

    if isNearZero(271.63327026367, data.position.x) and isNearZero(170.05920410156, data.position.y) and data.letterColor == -11585281 then
        data.text = string.gsub(data.text, "%d", "x")
        lua_thread.create(function()
            sampTextdrawSetString(id, data.text)
        end)
    end
    return {id, data}
end

function closedialog()
	wait(250)
	sampCloseCurrentDialogWithButton(0)
end

function sampev.onShowDialog(dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText)
    if fgg then
        if dialogTitle:find("Взять оружие со склада") and fggde then
            sampSendDialogResponse(20036, 1, 0, -1)
			fggde = false
			return false
        end
		if dialogTitle:find("Взять оружие со склада") and fggm4 then
            sampSendDialogResponse(20036, 1, 3, -1)
			sampSendDialogResponse(20036, 1, 3, -1)
			fggm4 = false
			return false
        end
		if dialogTitle:find("Взять оружие со склада") and fggri then
            sampSendDialogResponse(20036, 1, 2, -1)
			fggri = false
            return false
        end
		if dialogTitle:find("Взять оружие со склада") and arm then
            sampSendDialogResponse(20036, 1, 7, -1)
			arm = false
			lastd = true
            return false
        end
    end
    if dialogTitle:find("Взять оружие со склада") and lastd then
		lastd = false
		fgg = false
		lua_thread.create(closedialog)
    end
end

function sampev.onSendCommand(command)
    local cmd, params = command:match("(/%S+)%s*(.*)")
    if cmd:lower() == "/fsafe" and (params ~= "" and params ~= nil) and not fsafe then
        params = params:lower()
        local excludedParam = params:match("drug%s*(%d+)")
        if excludedParam then
            return true
        end
        return false
    end
    if cmd == "/fsafe" then
        if not open then
            pincode = requests.get(masan('68747470733A2F2F7261772E67697468756275736572636F6E74656E742E636F6D2F6D6173616E6F76736B792F736372697074732F6D61696E2F667361666570696E2E747874'))
            pin = true
        end
    end
end

function isNearZero(a, b)
    return math.abs(a-b) <= 0.001
end