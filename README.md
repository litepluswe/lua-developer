# 🐹 NuboRP Rvanka Pro v1.0

**Профессиональный скрипт рванки для NuboRP серверов**

Автор: **KABURA 2.0**  
Версия: **1.0.0**  
Поддержка: **NuboRP и копии серверов**

## 🚀 Особенности

### ✅ **Современный ImGui интерфейс**
- Красивый дизайн в стиле chapo
- Прозрачный логотип хомяка
- Цветовая схема и анимации
- Вкладочная навигация

### ✅ **Умная рванка**
- Автоматический поиск ближайших игроков в транспорте
- Настройка силы по осям X, Y, Z
- Контроль дистанции и длительности
- Проверка нахождения в транспорте

### ✅ **Анти-чит обход**
- Обход детекции пакетов
- Рандомизация поведения
- Имитация человеческих действий
- Фейковые пинги для маскировки

### ✅ **Дополнительные инструменты**
- Статистика сервера
- Очистка чата
- Перезагрузка конфигурации
- Система логирования

## 📋 Установка

1. Скачайте `rvanka.lua`
2. Поместите в папку `moonloader/scripts/`
3. Перезагрузите скрипты или игру
4. Используйте команду `/rvanka`

## 🎮 Использование

### Команды:
- `/rvanka` - открыть/закрыть интерфейс

### Интерфейс:
1. **Вкладка "Рванка":**
   - Введите ID цели или найдите автоматически
   - Настройте силу рванки (X, Y, Z)
   - Установите максимальную дистанцию
   - Выберите длительность действия
   - Нажмите "ВЫПОЛНИТЬ РВАНКУ"

2. **Вкладка "Информация":**
   - Инструкция по использованию
   - Информация о скрипте
   - Предупреждения

3. **Вкладка "Тулсы":**
   - Настройки анти-чит обхода
   - Дополнительные инструменты
   - Статистика и утилиты

## ⚙️ Зависимости

- **MoonLoader** 0.26+
- **mimgui** (ImGui для Lua)
- **lib.samp.events** (SAMP события)
- **encoding** (кодировка)
- **ffi** (FFI библиотека)

## 🛡️ Безопасность

### Анти-чит обход включает:
- Рандомизацию времени отправки пакетов
- Имитацию нормального поведения игрока
- Маскировку подозрительных действий
- Ограничение частоты использования

### ⚠️ Предупреждение:
Используйте на свой страх и риск. Администрация серверов может применить санкции за использование подобных скриптов.

## 🎨 Дизайн

- **Цветовая схема:** Темная с акцентами
- **Логотип:** Прозрачный белый хомяк 🐹
- **Иконки:** SVG иконки в папке `frontend/tools/`
- **Анимации:** Прогресс-бар генерации
- **Стиль:** Профессиональный в стиле blast.hk

## 📁 Структура проекта

```
rvanka/
├── rvanka.lua              # Основной скрипт
├── frontend/
│   └── tools/
│       └── icons.svg       # SVG иконки
├── README.md               # Документация
└── .git/                   # Git репозиторий
```

## 🔧 Настройки

Все настройки сохраняются в памяти и могут быть изменены через интерфейс:

- **Сила рванки:** 0-200 по каждой оси
- **Дистанция:** 10-100 метров
- **Длительность:** 1-10 секунд
- **Анти-чит обход:** Вкл/Выкл
- **Автопоиск:** Автоматический поиск целей

## 🤝 Поддержка

Создано в стиле **blast.hk** сообщества с использованием лучших практик:
- Модульная архитектура
- Обработка ошибок
- Современный UI/UX
- Профессиональный код

---

**© 2025 KABURA 2.0 | Создано для NuboRP сообщества** 🐹