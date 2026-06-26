local imgui = require 'mimgui'


local M = {
    version = 1
}


local AI_TOGGLE = {}
local AI_HEADERBUT = {}
local AI_PAGE = {}


local ToU32 = imgui.ColorConvertFloat4ToU32

local function limit(v, min, max)
    min = min or 0.0
    max = max or 1.0
    return v < min and min or (v > max and max or v)
end

local function bringVec4To(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec4(
            from.x + (count * (to.x - from.x) / 100),
            from.y + (count * (to.y - from.y) / 100),
            from.z + (count * (to.z - from.z) / 100),
            from.w + (count * (to.w - from.w) / 100)
        ), true
    end
    return (timer > duration) and to or from, false
end

local function bringVec2To(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec2(
            from.x + (count * (to.x - from.x) / 100),
            from.y + (count * (to.y - from.y) / 100)
        ), true
    end
    return (timer > duration) and to or from, false
end

local function bringFloatTo(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return from + (count * (to - from) / 100), true
    end
    return (timer > duration) and to or from, false
end

local function isPlaceHovered(a, b)
    local m = imgui.GetMousePos()
    if m.x >= a.x and m.y >= a.y then
        if m.x <= b.x and m.y <= b.y then
            return true
        end
    end
    return false
end

local function set_alpha(color, alpha)
    alpha = alpha and limit(alpha, 0.0, 1.0) or 1.0
    return imgui.ImVec4(color.x, color.y, color.z, alpha)
end


M.ToggleButton = function(str_id, value)
    local duration = 0.3
    local p = imgui.GetCursorScreenPos()
    local DL = imgui.GetWindowDrawList()
    local size = imgui.ImVec2(40, 20)

    local title = str_id:gsub('##.*$', '')
    local ts = imgui.CalcTextSize(title)

    local style = imgui.GetStyle()
    local function mixColor(a, b, t)
    return imgui.ImVec4(
            a.x + (b.x - a.x) * t,
            a.y + (b.y - a.y) * t,
            a.z + (b.z - a.z) * t,
            a.w + (b.w - a.w) * t
        )
    end

    local cols = {
        enable  = mixColor(style.Colors[imgui.Col.SliderGrabActive], style.Colors[imgui.Col.FrameBg], 0.10),
        disable = mixColor(style.Colors[imgui.Col.ButtonActive], style.Colors[imgui.Col.FrameBg], 0.45),

        bg      = style.Colors[imgui.Col.FrameBg],
        border  = style.Colors[imgui.Col.Border],

        bg_on     = style.Colors[imgui.Col.FrameBg],
        border_on = mixColor(style.Colors[imgui.Col.Border], style.Colors[imgui.Col.SliderGrabActive], 0.18),
    }

    local radius = 6
    local o = { x = 4, y = p.y + (size.y / 2) }
    local A = imgui.ImVec2(p.x + radius + o.x, o.y)
    local B = imgui.ImVec2(p.x + size.x - radius - o.x, o.y)

    if AI_TOGGLE[str_id] == nil then
        AI_TOGGLE[str_id] = {
            clock = nil,
            color = value[0] and cols.enable or cols.disable,
            pos   = value[0] and B or A
        }
    end
    local pool = AI_TOGGLE[str_id]

    imgui.BeginGroup()
        local pos = imgui.GetCursorPos()
        local result = imgui.InvisibleButton(str_id, imgui.ImVec2(size.x, size.y))
        if result then
            value[0] = not value[0]
            pool.clock = os.clock()
        end
        if #title > 0 then
            local spc = style.ItemSpacing
            imgui.SetCursorPos(imgui.ImVec2(pos.x + size.x + spc.x, pos.y + ((size.y - ts.y) / 2)))
            imgui.Text(title)
        end
    imgui.EndGroup()

    if pool.clock and os.clock() - pool.clock <= duration then
        pool.color = bringVec4To(imgui.ImVec4(pool.color), value[0] and cols.enable or cols.disable, pool.clock, duration)
        pool.pos   = bringVec2To(imgui.ImVec2(pool.pos),   value[0] and B or A,                   pool.clock, duration)
    else
        pool.color = value[0] and cols.enable or cols.disable
        pool.pos   = value[0] and B or A
    end

    local rounding = 5

    local bg_col = value[0] and cols.bg_on or cols.bg
    local border_col = value[0] and cols.border_on or cols.border

    DL:AddRectFilled(p, imgui.ImVec2(p.x + size.x, p.y + size.y), ToU32(bg_col), rounding)
    DL:AddRect(p, imgui.ImVec2(p.x + size.x, p.y + size.y), ToU32(border_col), rounding, 15, 1)

    local knob_min = imgui.ImVec2(pool.pos.x - radius, pool.pos.y - radius)
    local knob_max = imgui.ImVec2(pool.pos.x + radius, pool.pos.y + radius)
    DL:AddRectFilled(knob_min, knob_max, ToU32(pool.color), 3)

    return result
end

M.PageButton = function(bool, icon, name, but_wide)
    but_wide = but_wide or 170
    local duration = 0.25
    local DL = imgui.GetWindowDrawList()


    local tab_col = imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]



    local ACTIVE_GRADIENT_ALPHA = 0.36
    local HOVER_GRADIENT_ALPHA  = 0.15


    local ACTIVE_TEXT_COL   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    local HOVER_TEXT_COL    = imgui.ImVec4(0.78, 0.78, 0.78, 1.00)
    local INACTIVE_TEXT_COL = imgui.ImVec4(0.42, 0.42, 0.42, 1.00)

    local pageShiftX = 8
    local oldCursorX = imgui.GetCursorPosX()
    imgui.SetCursorPosX(oldCursorX - pageShiftX)

    local p1 = imgui.GetCursorScreenPos()
    local p2 = imgui.GetCursorPos()

    if not AI_PAGE[name] then
        AI_PAGE[name] = {
            clock = nil,
            hover_t = 0.0,
            last = os.clock()
        }
    end

    local pool = AI_PAGE[name]

    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0, 0, 0))

    local result = imgui.InvisibleButton(name, imgui.ImVec2(but_wide, 40))
    local hovered = imgui.IsItemHovered()

    imgui.PopStyleColor(3)

    if result and not bool then
        pool.clock = os.clock()
    end

    do
        local now = os.clock()
        local dt = now - (pool.last or now)
        pool.last = now

        local speed = dt / duration

        if hovered and not bool then
            pool.hover_t = math.min(1.0, (pool.hover_t or 0.0) + speed)
        else
            pool.hover_t = math.max(0.0, (pool.hover_t or 0.0) - speed)
        end
    end

    DL:PushClipRectFullScreen()

    if bool then
        if pool.clock and (os.clock() - pool.clock) < duration then
            local t = (os.clock() - pool.clock) / duration
            if t > 1.0 then t = 1.0 end

            local w = but_wide * t


            DL:AddRectFilled(
                imgui.ImVec2(p1.x, p1.y),
                imgui.ImVec2(p1.x + 3, p1.y + 40),
                ToU32(tab_col)
            )



            DL:PushClipRect(
                imgui.ImVec2(p1.x, p1.y),
                imgui.ImVec2(p1.x + w, p1.y + 40),
                true
            )

            local left_col = ToU32(imgui.ImVec4(
                tab_col.x,
                tab_col.y,
                tab_col.z,
                ACTIVE_GRADIENT_ALPHA * t
            ))

            local right_col = ToU32(imgui.ImVec4(
                tab_col.x,
                tab_col.y,
                tab_col.z,
                0.00
            ))

            DL:AddRectFilledMultiColor(
                imgui.ImVec2(p1.x, p1.y),
                imgui.ImVec2(p1.x + but_wide * 0.8, p1.y + 40),
                left_col,
                right_col,
                right_col,
                left_col
            )

            DL:PopClipRect()
        else

            DL:AddRectFilled(
                imgui.ImVec2(p1.x, p1.y),
                imgui.ImVec2(p1.x + 3, p1.y + 40),
                ToU32(tab_col)
            )



            local left_col = ToU32(imgui.ImVec4(
                tab_col.x,
                tab_col.y,
                tab_col.z,
                ACTIVE_GRADIENT_ALPHA
            ))

            local right_col = ToU32(imgui.ImVec4(
                tab_col.x,
                tab_col.y,
                tab_col.z,
                0.00
            ))

            DL:AddRectFilledMultiColor(
                imgui.ImVec2(p1.x, p1.y),
                imgui.ImVec2(p1.x + but_wide * 0.8, p1.y + 40),
                left_col,
                right_col,
                right_col,
                left_col
            )
        end
    else
        local t = pool.hover_t or 0.0

        if t > 0.001 then
            DL:PushClipRect(
                imgui.ImVec2(p1.x, p1.y),
                imgui.ImVec2(p1.x + but_wide * 0.8, p1.y + 40),
                true
            )



            local left_col = ToU32(imgui.ImVec4(
                tab_col.x,
                tab_col.y,
                tab_col.z,
                HOVER_GRADIENT_ALPHA * t
            ))

            local right_col = ToU32(imgui.ImVec4(
                tab_col.x,
                tab_col.y,
                tab_col.z,
                0.00
            ))

            DL:AddRectFilledMultiColor(
                imgui.ImVec2(p1.x, p1.y),
                imgui.ImVec2(p1.x + but_wide * 0.8, p1.y + 40),
                left_col,
                right_col,
                right_col,
                left_col
            )

            DL:PopClipRect()
        end
    end

    DL:PopClipRect()

    imgui.SameLine(10)
    imgui.SetCursorPosY(p2.y + 12)

    local t = pool.hover_t or 0.0
    local text_col

    if bool then
        text_col = ACTIVE_TEXT_COL
    elseif t > 0.05 then
        text_col = HOVER_TEXT_COL
    else
        text_col = INACTIVE_TEXT_COL
    end

    imgui.TextColored(text_col, (' '):rep(3) .. icon)
    imgui.SameLine(50)

    imgui.PushFont(grayTitle)
    imgui.TextColored(text_col, name)
    imgui.PopFont()

    imgui.SetCursorPosY(p2.y + 40)

    return result
end

M.HeaderButton = function(bool, str_id)
    local DL = imgui.GetWindowDrawList()
    local result = false
    local label = string.gsub(str_id, "##.*$", "")
    local duration = { 0.5, 0.3 }
    local cols = {
        idle = imgui.ImVec4(0.42, 0.42, 0.42, 1.00),
        hovr = imgui.ImVec4(0.78, 0.78, 0.78, 1.00),
        slct = imgui.ImVec4(20 / 255, 140 / 255, 77 / 255, 1.00)
    }

     if not AI_HEADERBUT[str_id] then
        AI_HEADERBUT[str_id] = {
            color = bool and cols.slct or cols.idle,
            clock = os.clock() + duration[1],
            h = {
                state = bool,
                alpha = bool and 1.00 or 0.00,
                clock = os.clock() + duration[2],
            }
        }
    end
    local pool = AI_HEADERBUT[str_id]

    imgui.BeginGroup()
        local pos = imgui.GetCursorPos()
        local p = imgui.GetCursorScreenPos()
        

        imgui.TextColored(pool.color, label)
        local s = imgui.GetItemRectSize()
        local hovered = isPlaceHovered(p, imgui.ImVec2(p.x + s.x, p.y + s.y))
        local clicked = imgui.IsItemClicked()
        
        local h_state = bool or hovered

        if pool.h.state ~= h_state then
            pool.h.state = h_state
            pool.h.clock = os.clock()
        end
        
        if clicked then
            pool.clock = os.clock()
            result = true
        end

        if os.clock() - pool.clock <= duration[1] then
            pool.color = bringVec4To(
                imgui.ImVec4(pool.color),
                bool and cols.slct or (hovered and cols.hovr or cols.idle),
                pool.clock,
                duration[1]
            )
        else
            pool.color = bool and cols.slct or (hovered and cols.hovr or cols.idle)
        end

        if pool.h.clock ~= nil then
            if os.clock() - pool.h.clock <= duration[2] then
                pool.h.alpha = bringFloatTo(
                    pool.h.alpha,
                    pool.h.state and 1.00 or 0.00,
                    pool.h.clock,
                    duration[2]
                )
            else
                pool.h.alpha = pool.h.state and 1.00 or 0.00
                if not pool.h.state then
                    pool.h.clock = nil
                end
            end

            local max = s.x / 2
            local Y = p.y + s.y + 3
            local mid = p.x + max

            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid + (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid - (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
        end

    imgui.EndGroup()
    return result
end

local active_slider_id, alt_active_slider_id = nil, nil

M.CustomSlider = function(str_id, value, min, max, sformat, width)
    width = width or 100

    local DL = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    local io = imgui.GetIO()
    local style = imgui.GetStyle()

    UI_CUSTOM_SLIDER = UI_CUSTOM_SLIDER or {}
    UI_CUSTOM_SLIDER[str_id] = UI_CUSTOM_SLIDER[str_id] or {
        active = false,
        hovered = false,
        start = 0,
        smooth_value = value[0]
    }

    local function clamp(v, a, b)
        if v < a then return a end
        if v > b then return b end
        return v
    end

    imgui.InvisibleButton(str_id, imgui.ImVec2(width, 20))

    local isActive = imgui.IsItemActive()
    local isHovered = imgui.IsItemHovered()

    UI_CUSTOM_SLIDER[str_id].active = isActive
    UI_CUSTOM_SLIDER[str_id].hovered = isHovered

    if isActive then
        if io.KeyAlt then
            alt_active_slider_id = str_id
        else
            active_slider_id = str_id
        end
    else
        if active_slider_id == str_id then
            active_slider_id = nil
        end
        if alt_active_slider_id == str_id and not io.KeyAlt then
            alt_active_slider_id = nil
        end
    end

    local isInteger = (math.floor(min) == min) and (math.floor(max) == max)
    local range = max - min
    local step = 0

    if range ~= 0 then
        step = range / (width * (isInteger and 10 or 80))
    end

    local isAltPressed = io.KeyAlt
    local mouseDown = imgui.IsMouseDown(0)

    if ((str_id == active_slider_id and not isAltPressed) or
        (str_id == alt_active_slider_id and isAltPressed)) and mouseDown then

        local mousePos = imgui.GetMousePos()
        local delta = io.MouseDelta.x

        if isAltPressed then
            UI_CUSTOM_SLIDER[str_id].smooth_value = UI_CUSTOM_SLIDER[str_id].smooth_value + delta * step
            UI_CUSTOM_SLIDER[str_id].smooth_value = clamp(UI_CUSTOM_SLIDER[str_id].smooth_value, min, max)

            if isInteger then
                value[0] = math.floor(UI_CUSTOM_SLIDER[str_id].smooth_value + 0.5)
            else
                value[0] = UI_CUSTOM_SLIDER[str_id].smooth_value
            end
        else
            local mouseX = clamp(mousePos.x - p.x, 0, width)

            if range ~= 0 then
                UI_CUSTOM_SLIDER[str_id].smooth_value = min + range * mouseX / width
                UI_CUSTOM_SLIDER[str_id].smooth_value = clamp(UI_CUSTOM_SLIDER[str_id].smooth_value, min, max)

                if isInteger then
                    value[0] = math.floor(UI_CUSTOM_SLIDER[str_id].smooth_value + 0.5)
                else
                    value[0] = UI_CUSTOM_SLIDER[str_id].smooth_value
                end
            end
        end
    else
        if math.abs(UI_CUSTOM_SLIDER[str_id].smooth_value - value[0]) > 0.001 then
            UI_CUSTOM_SLIDER[str_id].smooth_value =
                UI_CUSTOM_SLIDER[str_id].smooth_value + (value[0] - UI_CUSTOM_SLIDER[str_id].smooth_value) * 0.3
        else
            UI_CUSTOM_SLIDER[str_id].smooth_value = value[0]
        end
    end

    local circleRadius = 8
    local trackY1 = p.y + 7
    local trackY2 = p.y + 14
    local centerY = p.y + 10

    local normalized = 0
    if range ~= 0 then
        normalized = clamp((UI_CUSTOM_SLIDER[str_id].smooth_value - min) / range, 0, 1)
    end

    local posCircleX = p.x + circleRadius + (width - circleRadius * 2) * normalized

    local knobColor = style.Colors[imgui.Col.SliderGrab]
    if isHovered or isActive then
        knobColor = style.Colors[imgui.Col.SliderGrabActive]
    end

    local knobColorU32 = imgui.GetColorU32Vec4(knobColor)
    local bgColorU32 = imgui.GetColorU32Vec4(style.Colors[imgui.Col.FrameBg])
    local textColorU32 = imgui.GetColorU32Vec4(style.Colors[imgui.Col.Text])

    if (str_id == active_slider_id and isAltPressed) or (str_id == alt_active_slider_id and isAltPressed) then
        DL:AddRectFilled(
            imgui.ImVec2(p.x, trackY1),
            imgui.ImVec2(p.x + width, trackY2),
            bgColorU32
        )

        DL:AddRectFilled(
            imgui.ImVec2(p.x, trackY1),
            imgui.ImVec2(posCircleX, trackY2),
            knobColorU32
        )

        local arrowSize = 10
        local halfArrowSize = 5

        DL:AddTriangleFilled(
            imgui.ImVec2(p.x, centerY - halfArrowSize),
            imgui.ImVec2(p.x + arrowSize, centerY),
            imgui.ImVec2(p.x, centerY + halfArrowSize),
            knobColorU32
        )

        DL:AddTriangleFilled(
            imgui.ImVec2(p.x + width, centerY - halfArrowSize),
            imgui.ImVec2(p.x + width - arrowSize, centerY),
            imgui.ImVec2(p.x + width, centerY + halfArrowSize),
            knobColorU32
        )
    else
        DL:AddRectFilled(
            imgui.ImVec2(p.x, trackY1),
            imgui.ImVec2(posCircleX, trackY2),
            knobColorU32
        )

        DL:AddRectFilled(
            imgui.ImVec2(posCircleX, trackY1),
            imgui.ImVec2(p.x + width, trackY2),
            bgColorU32
        )

        DL:AddCircleFilled(
            imgui.ImVec2(posCircleX, centerY),
            circleRadius,
            knobColorU32,
            32
        )
    end

    DL:AddText(
        imgui.ImVec2(p.x + width + 10, p.y),
        textColorU32,
        string.format(sformat, value[0])
    )

    return isActive
end

local function ExplodeArgb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

M.TextColoredRGB = function(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4
    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = ExplodeArgb(color)
        return imgui.ImVec4(r / 255, g / 255, b / 255, a / 255)
    end
    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(text)
end

M.GrayTitle = function(title)
    local titleX = imgui.GetCursorPosX()
    local offsetX = tonumber(renderSectionTitleOffsetX) or 0

    if offsetX ~= 0 then
        imgui.SetCursorPosX(titleX + offsetX)
    end

    imgui.PushFont(grayTitle)
    M.TextColoredRGB("{929091}" .. title)
    imgui.PopFont()

    if offsetX ~= 0 then
        imgui.SetCursorPosX(titleX)
    end

    imgui.Dummy(imgui.ImVec2(0, 1))
end

M.NiceSeparator = function(offset, color, thickness, spacingY)
    offset = offset or 10
    color = color or imgui.ImVec4(0.34, 0.42, 0.36, 0.38)
    thickness = thickness or 1.0
    spacingY = spacingY or 6

    imgui.Dummy(imgui.ImVec2(0, 1))

    local draw = imgui.GetWindowDrawList()
    local winPos = imgui.GetWindowPos()
    local regionMin = imgui.GetWindowContentRegionMin()
    local regionMax = imgui.GetWindowContentRegionMax()
    local cursorPos = imgui.GetCursorScreenPos()

    local x1 = winPos.x + regionMin.x + offset
    local x2 = winPos.x + regionMax.x - offset
    local y = cursorPos.y

    draw:AddLine(imgui.ImVec2(x1, y), imgui.ImVec2(x2, y), imgui.ColorConvertFloat4ToU32(color),thickness)

    imgui.Dummy(imgui.ImVec2(0, spacingY))

    imgui.Dummy(imgui.ImVec2(0, 1))
end

M.TextQuestion = function(text)
    imgui.TextDisabled("(?)")
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

return M
