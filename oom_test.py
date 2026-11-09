#!/usr/bin/env python3
import time
import os

print(f"[*] Скрипт запущен. PID процесса: {os.getpid()}")
print("[*] Начинается выделение памяти...")

# Список для удержания ссылок на объекты в памяти
memory_sink = []

try:
    while True:
        # Выделяем ~100 МБ за одну итерацию (строка из 100 млн символов)
        # Умножение на 1 заставляет Python физически выделить память
        large_chunk = b"x" * (100 * 1024 * 1024)
        memory_sink.append(large_chunk)
        
        print(f"[+] Выделено еще 100 МБ. Всего блоков: {len(memory_sink)}")
        time.sleep(0.5)  # Небольшая пауза, чтобы крон успел зафиксировать падение ресурсов
except MemoryError:
    print("[-] Python поймал MemoryError (маловероятно при жестком OOM от ядра)")
