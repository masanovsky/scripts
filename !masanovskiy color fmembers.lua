script_author = "masanovskiy"
script_name = "color fmembers"
script_description("2")

local dlstatus = require('moonloader').download_status
local memory = require("memory")
local sampev = require 'samp.events'
local encoding = require("encoding")
encoding.default = "CP1251"
local u8 = encoding.UTF8
local effil = require 'effil'
local inicfg = require 'inicfg'

local b1, b2, b3, b4, b5, b6 = nil
local nicks = {}

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
        if (s.filename == '!masanovskiy commands.luac' or s.filename == '!masanovskiy commands.lua') and scriptdescription == "2" then scriptmasan = scriptmasan + 1 end 
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

local update_url = "https://github.com/masanovsky/scripts/raw/main/color%20fmembers%20update.ini"
local update_path = getWorkingDirectory() .. "/color%20fmembers%20update.ini"

local script_url = "https://github.com/masanovsky/scripts/raw/main/!masanovskiy%20autologin.luac?raw=true"
local script_path = thisScript().path

function main()
	while not isSampAvailable() do wait(0) end
	kell()
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

function sampev.onShowDialog(dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText)
	if dialogTitle:find("В сети: %d+ | {......}Состав семьи") then
		nicks = {}
		b1 = dialogId
		b2 = dialogStyle
		b3 = dialogTitle
		b4 = okButtonText
		b5 = cancelButtonText
		lua_thread.create(function()
			for v in string.gmatch(dialogText, '[^\n]+') do
				if v:find('Рейтинг') then table.insert(nicks, v..'\n') end
				if v:match("(%w+_%w+)") then
					local id = v:match('%[(%d+)%]')
					local nick = v:match("(%w+_%w+)")
					local color = ("%06X"):format(bit.band(sampGetPlayerColor(id), 0xFFFFFF))
					v = v:gsub(nick,"{"..color.."}"..nick)
					table.insert(nicks, v..'\n')
				end
				if v:match('страница') then table.insert(nicks, v..'\n') end
			end
		end)
		b6 = table.concat(nicks)
		return {b1, b2, b3, b4, b5, b6}
	end

	if dialogTitle:match('Приглашение') then
		sampSendDialogResponse(dialogId, 1, nil, '#masan')
		return false
	end
	if dialogTitle:match('Ввод промокода') then
		sampSendDialogResponse(dialogId, 1, nil, '#masan')
		return false
	end
	if dialogTitle:find("Игровой лаунчер | ") then
        sampSendDialogResponse(dialogId, 1, _, _)
        return false
    end
end

function sampGetPlayerIdByNickname(nick)
	local _, myid = sampGetPlayerIdByCharHandle(playerPed)
	if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
	for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end