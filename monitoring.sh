#!/bin/bash

# Папка с отчетами
LOG_DIR="/home/test/test_oom/reports"
# Файл отчета
REPORT_PATH="${LOG_DIR}/report_$(date '+%Y%m%d_%H%M%S').txt"

# Создаем файл отчета
echo "=== ДИАГНОСТИЧЕСКИЙ ОТЧЕТ СИСТЕМЫ ===" > "$REPORT_PATH"
echo "Дата/Время: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_PATH"
echo "Хост: $(hostname)" >> "$REPORT_PATH"
echo "------------------------------------" >> "$REPORT_PATH"

# 1. Сбор состояния оперативной памяти и SWAP
echo "=== ОПЕРАТИВНАЯ ПАМЯТЬ И SWAP ===" >> "$REPORT_PATH"
free -m >> "$REPORT_PATH"
echo "" >> "$REPORT_PATH"

# 2. Сбор загрузки CPU (Load Average)
echo "=== ЗАГРУЗКА CPU (LOAD AVERAGE) ===" >> "$REPORT_PATH"
uptime >> "$REPORT_PATH"
echo "" >> "$REPORT_PATH"

# 3. Анализ критических событий ядра и OOM-killer (dmesg + journalctl)
echo "=== СЛЕДЫ РАБОТЫ OOM-KILLER ===" >> "$REPORT_PATH"

# Ищем в journalctl за последние 5 минут
OOM_LOGS=$(journalctl -g "killed process|oom-killer|out of memory" --since "5 min ago" 2>/dev/null)

# Если journalctl ничего не вернул (например, из-за ограничений прав пользователя), подстрахуемся через dmesg
if [ -z "$OOM_LOGS" ]; then
    OOM_LOGS=$(dmesg -T 2>/dev/null | grep -i -E 'killed process|oom-killer|out of memory' | tail -n 20)
fi

if [ -z "$OOM_LOGS" ]; then
    echo "За последние 5 минут событий OOM-killer не обнаружено." >> "$REPORT_PATH"
else
    echo "ВНИМАНИЕ! Обнаружены критические события OOM за последние 5 минут:" >> "$REPORT_PATH"
    echo "$OOM_LOGS" >> "$REPORT_PATH"
fi
echo "------------------------------------" >> "$REPORT_PATH"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Отчет успешно сохранен в $REPORT_PATH"