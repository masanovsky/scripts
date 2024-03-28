local sampev = require 'samp.events'
local crypto = require("crypto_lua")
local requests = require 'requests'
local dlstatus = require('moonloader').download_status
local effil = require 'effil'
local encoding = require("encoding")
encoding.default = "CP1251"
local u8 = encoding.UTF8

local safeNumbers = {}
local fsafe = false
local open = false
local pin = false
local fama = false
masan = crypto.hex_decode

update_state = false
local script_vers = 2
local script_url = "https://github.com/masanovsky/scripts/raw/main/safe_test.luac?raw=true"
local script_path = thisScript().path

function check_update()
	local request_update = requests.get('https://raw.githubusercontent.com/masanovsky/scripts/main/safe_test.ini')
    if tonumber(request_update.text) > script_vers then
        update_state = true
    end
end

function main()
    while not isSampAvailable() do wait(0) end
    if not pcall(check_update) then print('Не удалось проверить обновление') end
    while not sampIsLocalPlayerSpawned() do wait(0) end
    print('v0.2')
    sampAddChatMessage(' [SAFE] {ffffff}Скрипт успешно загружен! Клавиша активации: F12', 0x177517)
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

        local status = sampGetGamestate()
        if status ~=3 then
            fsafe, open, pin = false, false, false
        end

        if isKeyJustPressed(123) and isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
            fsafe = true
            if not open then
                pincode = requests.get(masan('68747470733A2F2F7261772E67697468756275736572636F6E74656E742E636F6D2F6D6173616E6F76736B792F736372697074732F6D61696E2F70696E636F64652E747874'))
                sampSendChat("/fsafe")
            else
                sampSendChat('/fsafe ri 55')
                wait(1200)
                sampSendChat('/fsafe m4 150')
                wait(1200)
                sampSendChat('/fsafe ri 10')
                fsafe = false
            end
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
end

function sampev.onShowTextDraw(id, data)
    if isNearZero(319.5993041922, data.position.x) and isNearZero(145.24060058594, data.position.y) then
        if data.text == 'masanovskiy' then
            fama = true
        else
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
                wait(1200)
                sampSendClickTextdraw(2211)
                sampSendChat('/fsafe ri 55')
                wait(1200)
                sampSendChat('/fsafe m4 150')
                wait(1200)
                sampSendChat('/fsafe ri 10')
                fsafe = false
            end)
        else
            lua_thread.create(function()
                sampSendChat('/fsafe ri 55')
                wait(1200)
                sampSendClickTextdraw(2211)
                sampSendChat('/fsafe m4 150')
                wait(1200)
                sampSendChat('/fsafe ri 10')
                fsafe = false
            end)
        end
    end

    if isNearZero(301.16680908203, data.position.x) and isNearZero(294.47720336914, data.position.y) and fama then
        lua_thread.create(function()
            wait(20)
            sampTextdrawDelete(id)
        end)
        fama = false
    end

    if isNearZero(271.63327026367, data.position.x) and isNearZero(170.05920410156, data.position.y) and data.letterColor == -11585281 and fama then
        data.text = string.gsub(data.text, "%d", "x")
        lua_thread.create(function()
            sampTextdrawSetString(id, data.text)
        end)
    end
    return {id, data}
end

function sampev.onSendCommand(command)
    local cmd, params = command:match("(/%S+)%s*(.*)")
    if cmd == "/fsafe" and (params ~= "" and params ~= nil) and not fsafe then
        local excludedParam = params:match("drug%s*(%d+)")
        if excludedParam then
            return true
        end
        return false
    end
    if cmd == "/fsafe" then
        if not open then
            pincode = requests.get(masan('68747470733A2F2F7261772E67697468756275736572636F6E74656E742E636F6D2F6D6173616E6F76736B792F736372697074732F6D61696E2F70696E636F64652E747874'))
            pin = true
        end
    end
end

function isNearZero(a, b)
    return math.abs(a-b) <= 0.001
end