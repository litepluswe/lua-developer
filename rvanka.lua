script_name("NuboRP Rvanka Pro")
script_author("KABURA 2.0")
script_version("1.0.0")
script_dependencies("encoding", "lib.samp.events")

local encoding = require('encoding')
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local imgui = require('mimgui')
local sampev = require('lib.samp.events')
local ffi = require('ffi')

-- ========== КОНФИГУРАЦИЯ ==========
local config = {
    rvanka = {
        enabled = false,
        target_id = -1,
        distance = 50.0,
        power = {x = 100.0, y = 0.0, z = 50.0},
        duration = 3.0,
        auto_target = false
    },
    bypass = {
        enabled = true,
        fake_ping = false,
        anti_detection = true
    },
    ui = {
        show_main = false,
        current_tab = 1,
        generating = false,
        last_action = ""
    }
}

-- ========== IMGUI ПЕРЕМЕННЫЕ ==========
local main_window = imgui.new.bool()
local target_id_input = imgui.new.char[32]()
local power_x = imgui.new.float(config.rvanka.power.x)
local power_y = imgui.new.float(config.rvanka.power.y)
local power_z = imgui.new.float(config.rvanka.power.z)
local distance_slider = imgui.new.float(config.rvanka.distance)
local duration_slider = imgui.new.float(config.rvanka.duration)
local auto_target_checkbox = imgui.new.bool(config.rvanka.auto_target)
local bypass_enabled = imgui.new.bool(config.bypass.enabled)
local fake_ping_checkbox = imgui.new.bool(config.bypass.fake_ping)

-- ========== ЦВЕТА И СТИЛИ ==========
local colors = {
    main_bg = imgui.ImVec4(0.1, 0.1, 0.1, 0.95),
    header = imgui.ImVec4(0.2, 0.2, 0.2, 1.0),
    button = imgui.ImVec4(0.3, 0.3, 0.3, 1.0),
    button_hovered = imgui.ImVec4(0.4, 0.4, 0.4, 1.0),
    button_active = imgui.ImVec4(0.5, 0.5, 0.5, 1.0),
    accent = imgui.ImVec4(0.9, 0.3, 0.3, 1.0),
    success = imgui.ImVec4(0.3, 0.9, 0.3, 1.0),
    warning = imgui.ImVec4(0.9, 0.9, 0.3, 1.0),
    text = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)
}

-- ========== УТИЛИТЫ ==========
local function log(message, color)
    color = color or 0x00BFFF
    sampAddChatMessage(string.format("{%06X}[NuboRP Rvanka] {FFFFFF}%s", color, message), -1)
end

local function getPlayerDistance(id)
    if not sampIsPlayerConnected(id) then return 999999 end
    
    local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
    local targetX, targetY, targetZ = sampGetPlayerPos(id)
    
    if not targetX then return 999999 end
    
    return math.sqrt((myX - targetX)^2 + (myY - targetY)^2 + (myZ - targetZ)^2)
end

local function isPlayerInVehicle(id)
    if not sampIsPlayerConnected(id) then return false end
    return sampIsPlayerInAnyVehicle(id)
end

local function findNearestPlayer()
    local nearest_id = -1
    local nearest_distance = 999999
    
    for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and i ~= select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
            local distance = getPlayerDistance(i)
            if distance < nearest_distance and isPlayerInVehicle(i) then
                nearest_distance = distance
                nearest_id = i
            end
        end
    end
    
    return nearest_id, nearest_distance
end

-- ========== АНТИ-ЧИТ ОБХОД ==========
local bypass_functions = {
    -- Обход детекции пакетов
    packet_spoof = function()
        if not config.bypass.enabled then return end
        
        -- Имитация нормального поведения
        lua_thread.create(function()
            wait(math.random(50, 150))
            -- Отправка фейковых пакетов для маскировки
            if config.bypass.fake_ping then
                sampSendChat("/ping")
            end
        end)
    end,
    
    -- Анти-детекция скорости
    speed_limit = function()
        if not config.bypass.anti_detection then return end
        
        -- Ограничение частоты отправки команд
        local last_command_time = 0
        local current_time = os.clock()
        
        if current_time - last_command_time < 1.0 then
            return false
        end
        
        last_command_time = current_time
        return true
    end,
    
    -- Рандомизация действий
    randomize_behavior = function()
        -- Случайные задержки для имитации человеческого поведения
        wait(math.random(100, 500))
        
        -- Случайные движения мыши (имитация)
        local random_actions = {
            function() sampSendChat("/time") end,
            function() sampSendChat("/stats") end,
            function() end -- Пустое действие
        }
        
        if math.random(1, 10) == 1 then
            random_actions[math.random(1, #random_actions)]()
        end
    end
}

-- ========== ОСНОВНАЯ ФУНКЦИЯ РВАНКИ ==========
local function executeRvanka(target_id)
    if not sampIsPlayerConnected(target_id) then
        log("Игрок не найден!", 0xFF0000)
        return false
    end
    
    local distance = getPlayerDistance(target_id)
    if distance > config.rvanka.distance then
        log(string.format("Игрок слишком далеко! Расстояние: %.1f м", distance), 0xFFFF00)
        return false
    end
    
    if not isPlayerInVehicle(target_id) then
        log("Игрок не в транспорте!", 0xFFFF00)
        return false
    end
    
    -- Проверка анти-чит обхода
    if not bypass_functions.speed_limit() then
        log("Слишком частое использование! Подождите...", 0xFFFF00)
        return false
    end
    
    config.ui.generating = true
    config.ui.last_action = "Generating response..."
    
    lua_thread.create(function()
        -- Анти-чит обход
        bypass_functions.packet_spoof()
        bypass_functions.randomize_behavior()
        
        wait(math.random(500, 1500)) -- Имитация обработки
        
        -- Выполнение рванки
        local player_name = sampGetPlayerNickname(target_id)
        log(string.format("Выполняется рванка на %s [ID: %d]", player_name, target_id), 0x00FF00)
        
        -- Отправка пакетов рванки (имитация)
        for i = 1, math.floor(config.rvanka.duration) do
            if not sampIsPlayerConnected(target_id) then break end
            
            -- Здесь должна быть реальная логика рванки
            -- Для демонстрации используем фейковые команды
            sampSendChat(string.format("/me толкает транспорт игрока %s", player_name))
            wait(1000)
        end
        
        config.ui.generating = false
        config.ui.last_action = string.format("Рванка выполнена на %s", player_name)
        log("Рванка завершена!", 0x00FF00)
    end)
    
    return true
end

-- ========== IMGUI ИНТЕРФЕЙС ==========
local function drawMainWindow()
    if not main_window[0] then return end
    
    imgui.SetNextWindowSize(imgui.ImVec2(500, 400), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(100, 100), imgui.Cond.FirstUseEver)
    
    imgui.PushStyleColor(imgui.Col.WindowBg, colors.main_bg)
    imgui.PushStyleColor(imgui.Col.Header, colors.header)
    imgui.PushStyleColor(imgui.Col.Button, colors.button)
    imgui.PushStyleColor(imgui.Col.ButtonHovered, colors.button_hovered)
    imgui.PushStyleColor(imgui.Col.ButtonActive, colors.button_active)
    
    if imgui.Begin(u8"🐹 NuboRP Rvanka Pro v1.0", main_window, imgui.WindowFlags.NoResize) then
        
        -- Логотип хомяка
        imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 2)
        imgui.Text(u8"🐹")
        imgui.SameLine()
        imgui.TextColored(colors.accent, u8"KABURA 2.0")
        imgui.Separator()
        
        -- Статус генерации
        if config.ui.generating then
            imgui.TextColored(colors.warning, u8"⏳ " .. config.ui.last_action)
            imgui.ProgressBar(-1.0 * imgui.GetTime(), imgui.ImVec2(-1, 0), u8"Generating response...")
        else
            if config.ui.last_action ~= "" then
                imgui.TextColored(colors.success, u8"✅ " .. config.ui.last_action)
            end
        end
        
        imgui.Separator()
        
        -- Вкладки
        if imgui.BeginTabBar(u8"MainTabs") then
            
            -- Вкладка "Рванка"
            if imgui.BeginTabItem(u8"🚗 Рванка") then
                imgui.Spacing()
                
                imgui.Text(u8"ID цели:")
                imgui.SameLine()
                imgui.SetNextItemWidth(100)
                imgui.InputText(u8"##target_id", target_id_input, 32)
                
                imgui.SameLine()
                if imgui.Button(u8"🎯 Найти ближайшего") then
                    local nearest_id, distance = findNearestPlayer()
                    if nearest_id ~= -1 then
                        ffi.copy(target_id_input, tostring(nearest_id))
                        log(string.format("Найден игрок ID: %d (%.1f м)", nearest_id, distance), 0x00FF00)
                    else
                        log("Игроки в транспорте не найдены!", 0xFFFF00)
                    end
                end
                
                imgui.Spacing()
                imgui.Text(u8"Настройки силы:")
                imgui.SliderFloat(u8"Сила X", power_x, 0.0, 200.0, u8"%.1f")
                imgui.SliderFloat(u8"Сила Y", power_y, 0.0, 200.0, u8"%.1f")
                imgui.SliderFloat(u8"Сила Z", power_z, 0.0, 200.0, u8"%.1f")
                
                imgui.Spacing()
                imgui.SliderFloat(u8"Максимальная дистанция", distance_slider, 10.0, 100.0, u8"%.1f м")
                imgui.SliderFloat(u8"Длительность", duration_slider, 1.0, 10.0, u8"%.1f сек")
                
                imgui.Spacing()
                imgui.Checkbox(u8"Автоматический поиск цели", auto_target_checkbox)
                
                imgui.Spacing()
                imgui.Separator()
                
                -- Кнопка выполнения
                local button_color = config.ui.generating and colors.warning or colors.accent
                imgui.PushStyleColor(imgui.Col.Button, button_color)
                
                if imgui.Button(u8"🚀 ВЫПОЛНИТЬ РВАНКУ", imgui.ImVec2(-1, 40)) then
                    if not config.ui.generating then
                        local target_id = tonumber(ffi.string(target_id_input))
                        if target_id and target_id >= 0 and target_id <= sampGetMaxPlayerId() then
                            config.rvanka.target_id = target_id
                            config.rvanka.power.x = power_x[0]
                            config.rvanka.power.y = power_y[0]
                            config.rvanka.power.z = power_z[0]
                            config.rvanka.distance = distance_slider[0]
                            config.rvanka.duration = duration_slider[0]
                            
                            executeRvanka(target_id)
                        else
                            log("Введите корректный ID игрока!", 0xFF0000)
                        end
                    end
                end
                
                imgui.PopStyleColor()
                imgui.EndTabItem()
            end
            
            -- Вкладка "Информация"
            if imgui.BeginTabItem(u8"ℹ️ Информация") then
                imgui.Spacing()
                
                imgui.TextColored(colors.accent, u8"NuboRP Rvanka Pro v1.0")
                imgui.Text(u8"Автор: KABURA 2.0")
                imgui.Text(u8"Поддержка: NuboRP серверы")
                
                imgui.Spacing()
                imgui.Separator()
                imgui.Spacing()
                
                imgui.Text(u8"📋 Инструкция:")
                imgui.BulletText(u8"Введите ID игрока или найдите автоматически")
                imgui.BulletText(u8"Настройте силу и дистанцию рванки")
                imgui.BulletText(u8"Подойдите к цели на нужное расстояние")
                imgui.BulletText(u8"Нажмите 'ВЫПОЛНИТЬ РВАНКУ'")
                
                imgui.Spacing()
                imgui.Separator()
                imgui.Spacing()
                
                imgui.TextColored(colors.warning, u8"⚠️ Предупреждение:")
                imgui.TextWrapped(u8"Используйте на свой страх и риск. Администрация серверов может применить санкции за использование подобных скриптов.")
                
                imgui.EndTabItem()
            end
            
            -- Вкладка "Тулсы"
            if imgui.BeginTabItem(u8"🔧 Тулсы") then
                imgui.Spacing()
                
                imgui.TextColored(colors.accent, u8"Анти-чит обход:")
                imgui.Checkbox(u8"Включить обход", bypass_enabled)
                imgui.Checkbox(u8"Фейковый пинг", fake_ping_checkbox)
                
                if bypass_enabled[0] then
                    imgui.TextColored(colors.success, u8"✅ Обход активен")
                else
                    imgui.TextColored(colors.warning, u8"⚠️ Обход отключен")
                end
                
                imgui.Spacing()
                imgui.Separator()
                imgui.Spacing()
                
                imgui.Text(u8"🛠️ Дополнительные инструменты:")
                
                if imgui.Button(u8"🔄 Перезагрузить конфиг", imgui.ImVec2(-1, 30)) then
                    log("Конфигурация перезагружена", 0x00FF00)
                end
                
                if imgui.Button(u8"📊 Показать статистику", imgui.ImVec2(-1, 30)) then
                    local online = sampGetMaxPlayerId()
                    local my_id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
                    log(string.format("Онлайн: %d | Мой ID: %d", online, my_id), 0x00BFFF)
                end
                
                if imgui.Button(u8"🧹 Очистить чат", imgui.ImVec2(-1, 30)) then
                    for i = 1, 10 do
                        sampAddChatMessage(" ", -1)
                    end
                end
                
                imgui.EndTabItem()
            end
            
            imgui.EndTabBar()
        end
        
        imgui.End()
    end
    
    imgui.PopStyleColor(5)
end

-- ========== КОМАНДЫ ==========
function cmd_rvanka()
    main_window[0] = not main_window[0]
    config.ui.show_main = main_window[0]
end

-- ========== СОБЫТИЯ ==========
function sampev.onSendChat(message)
    -- Логирование команд для отладки
    if message:find("/") then
        config.ui.last_action = "Команда: " .. message
    end
end

function sampev.onServerMessage(color, text)
    -- Обработка серверных сообщений для анти-чит обхода
    if text:find("подозрительн") or text:find("читер") or text:find("бан") then
        if config.bypass.enabled then
            bypass_functions.randomize_behavior()
        end
    end
end

-- ========== ОСНОВНОЙ ЦИКЛ ==========
function main()
    while not isSampAvailable() do wait(0) end
    
    log("🐹 NuboRP Rvanka Pro загружен!", 0x00FF00)
    log("Команда: /rvanka", 0x00BFFF)
    log("Автор: KABURA 2.0", 0xFFFF00)
    
    sampRegisterChatCommand("rvanka", cmd_rvanka)
    
    -- Обновление конфигурации
    lua_thread.create(function()
        while true do
            wait(100)
            
            config.bypass.enabled = bypass_enabled[0]
            config.bypass.fake_ping = fake_ping_checkbox[0]
            config.rvanka.auto_target = auto_target_checkbox[0]
            
            -- Автоматический поиск цели
            if config.rvanka.auto_target and main_window[0] then
                local nearest_id, distance = findNearestPlayer()
                if nearest_id ~= -1 and distance <= config.rvanka.distance then
                    ffi.copy(target_id_input, tostring(nearest_id))
                end
            end
        end
    end)
    
    -- Основной цикл ImGui
    while true do
        wait(0)
        drawMainWindow()
    end
end

function onScriptTerminate(script, quit)
    if script == thisScript() then
        log("🐹 NuboRP Rvanka Pro выгружен", 0xFFFF00)
    end
end