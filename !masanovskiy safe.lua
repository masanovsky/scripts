-- исправить чтобы после релога локалки были в исходном положении

local sampev = require 'samp.events'
local crypto = require("crypto_lua")
local requests = require 'requests'

local fsafe = false
local open = false
local pin = false
huihuihuihuihuihui = crypto.hex_decode

function sampev.onServerMessage(color, text)
    if (text:find("Склад вашей семьи закрыт") and color == -1347440726) or (text:find("Пин-код не совпал") and color == -858993409) then
        fsafe = false
    elseif text:find("Сейф открывается") and color == -3407617 then
        open = true
    elseif text:find('Нельзя ввести больше') then
        return false
    end
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    while true do
        wait(0)
        if isKeyJustPressed(121) and isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
            fsafe = true
            if not open then
                pincode = requests.get(huihuihuihuihuihui('68747470733A2F2F7261772E67697468756275736572636F6E74656E742E636F6D2F6D6173616E6F76736B792F736372697074732F6D61696E2F70696E636F64652E747874'))
                sampSendChat("/fsafe")
            else
                sampSendChat('/fsafe de 1')
                wait(1400)
                sampSendChat('/fsafe m4 1')
                wait(1400)
                sampSendChat('/fsafe ri 1')
                fsafe = false
            end
        end
    end
end

function sampev.onShowTextDraw(id, data)
    if data.text == 'FAMILY' and fsafe and not open then
        lua_thread.create(function()
            local t = {}
            for i = 1, 4 do
                t[i] = pincode.text:sub(i, i)
            end
            wait(150)
            sampSendClickTextdraw(2253 + tonumber(t[1]))
            wait(150)
            sampSendClickTextdraw(2253 + tonumber(t[2]))
            wait(150)
            sampSendClickTextdraw(2253 + tonumber(t[3]))
            wait(150)
            sampSendClickTextdraw(2253 + tonumber(t[4]))
            wait(150)
            sampSendClickTextdraw(2265)
        end)
    end

    if data.text == 'FAMILY' and pin and not open then
        lua_thread.create(function()
            local t = {}
            for i = 1, 4 do
                t[i] = pincode.text:sub(i, i)
            end
            wait(150)
            sampSendClickTextdraw(2253 + tonumber(t[1]))
            wait(150)
            sampSendClickTextdraw(2253 + tonumber(t[2]))
            wait(150)
            sampSendClickTextdraw(2253 + tonumber(t[3]))
            wait(150)
            sampSendClickTextdraw(2253 + tonumber(t[4]))
            wait(150)
            sampSendClickTextdraw(2265)
        end)
    end

    if data.text == 'FAMILY' and fsafe and open then
        lua_thread.create(function()
            sampSendClickTextdraw(2211)
            sampSendChat('/fsafe de 1')
            wait(1400)
            sampSendChat('/fsafe m4 1')
            wait(1400)
            sampSendChat('/fsafe ri 1')
            fsafe = false
        end)
    end

    if data.text == "FAMILY" then
        lua_thread.create(function()
            wait(0)
            sampTextdrawDelete(2213)
            sampTextdrawDelete(2214)
        end)
    end

    if id == 2252 then
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
        return false
    end
    if cmd == "/fsafe" then
        if not open then
            pincode = requests.get(huihuihuihuihuihui('68747470733A2F2F7261772E67697468756275736572636F6E74656E742E636F6D2F6D6173616E6F76736B792F736372697074732F6D61696E2F70696E636F64652E747874'))
            pin = true
        end
    end
end

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