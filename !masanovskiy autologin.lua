script_author = "masanovskiy"
script_name = "autologin"

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
        
local window = imgui.ImBool(false)
local dontshow = true

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

function main()
    while not isSampAvailable() do wait(200) end
    sampRegisterChatCommand('al', cmd_imgui)
    imgui.Process = false
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
        imgui.Begin(u8'Автологин [masanovskiy]', window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        if imadd.ToggleButton("##enabled",  enabled) then
			ini.main.enabled = enabled.v
			saveIniFile()
		end
        imgui.SameLine()
        imgui.Text(u8'Выкл / Вкл')
		if enabled.v then
			imgui.PushItemWidth(130)
			if imgui.InputText(u8"##1", password, dontshow and imgui.InputTextFlags.Password or 0) then
				ini.main.password = tostring(u8:decode(password.v))
				saveIniFile()
			end
			imgui.SameLine()
			imgui.Text(u8'Пароль')
			imgui.SameLine()
			imgui.Text(fa.ICON_EYE)
			if imgui.IsItemClicked(0) then
				dontshow = not dontshow
			end
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8'Посмотреть пароль')
				imgui.EndTooltip()
			end
			if #password.v == 0 then
				imgui.SameLine(5)
				imgui.TextDisabled(u8'Введите пароль')
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
            if imgui.Combo(u8'Спавн', selected_item, {u8'Спавн', u8'Личный дом', u8'Дом на колесах', u8'Яхта', u8'Семейный дом'}, 5) then
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
	if title:find("Авторизация | {......}Ввод пароля") and text:find("Добро пожаловать на сервер ") and enabled.v and #password.v >= 6 then
		sampSendDialogResponse(dialogId, 1, nil, ini.main.password)
		click = true
		return false
	end
end

function sampev.onServerMessage(color, text)
	if enabled.v and text:find('Вы ввели неверный пароль! ') then
        enabled.v = false
        click = false
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