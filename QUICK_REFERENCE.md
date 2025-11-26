# QUICK REFERENCE - DUAL BOOT WIREGUARD SETUP

## БЫСТРЫЕ КОМАНДЫ

### Управление загрузкой (с .90 основной системы)

```cmd
# Загрузить клон при следующем перезапуске
C:\BootManager\boot-to-clone.bat

# Загрузить основную систему при следующем перезапуске
C:\BootManager\boot-to-main.bat

# Проверить что загрузится следующим
C:\BootManager\check-next-boot.bat

# Перезапустить через 30 секунд
shutdown /r /t 30
```

### Аварийный возврат (из клона)

```cmd
C:\EMERGENCY_RETURN.bat
```

### Проверка IP и туннеля (в клоне)

```cmd
# Проверить публичный IP (должен быть 194.31.72.192)
curl ifconfig.me

# Проверить туннель
ping 10.0.0.1

# Проверить трассировку
tracert 8.8.8.8

# Показать статус WireGuard
wg show
```

### Управление BCD

```cmd
# Показать все записи загрузки
bcdedit /enum

# Показать текущую конфигурацию по умолчанию
bcdedit /enum {default}

# Восстановить BCD из резервной копии
bcdedit /import C:\BCD_BACKUP
```

### Управление VHDX

```cmd
# Смонтировать VHDX
diskpart
select vdisk file="C:\VMClone\clon192-4.vhdx"
attach vdisk
list volume
exit

# Размонтировать VHDX
diskpart
select vdisk file="C:\VMClone\clon192-4.vhdx"
detach vdisk
exit
```

---

## КРИТИЧНЫЕ ПРОВЕРКИ

### ✅ Перед первой загрузкой клона:

```cmd
# 1. Проверить BCD
bcdedit /enum

# 2. Убедиться что VHDX размонтирован
diskpart
list volume
exit

# 3. Проверить скрипты существуют
dir C:\BootManager

# 4. Проверить что основная система по умолчанию
bcdedit /enum {default}
```

### ✅ После загрузки клона:

```cmd
# 1. Проверить IP (ДОЛЖЕН БЫТЬ 194.31.72.192!)
curl ifconfig.me

# 2. Проверить туннель работает
ping 10.0.0.1

# 3. Проверить WireGuard активен
wg show

# 4. Проверить нет утечек
tracert 8.8.8.8
```

---

## GUIDЫ (ЗАПОЛНИТЬ ПОСЛЕ bcdedit /enum)

```
GUID основной системы: {____________________________________}

GUID клона:           {____________________________________}
```

---

## КОНФИГУРАЦИЯ WIREGUARD

### Клон (10.0.0.2)
- Endpoint: 194.31.72.192:51820
- AllowedIPs: 0.0.0.0/0 (весь трафик через туннель)
- DNS: 8.8.8.8

### Эталон (10.0.0.1)
- ListenPort: 51820
- AllowedIPs для клона: 10.0.0.2/32

---

## IP АДРЕСА

| Система | Физический IP | Туннель IP | Назначение |
|---------|--------------|-----------|-----------|
| Основная система | 185.244.175.90 | - | Хост, основная работа |
| Клон | 185.244.175.90 (физ.) | 10.0.0.2 | Использует IP эталона через туннель |
| Эталон | 194.31.72.192 | 10.0.0.1 | WireGuard сервер, NAT |

**ВАЖНО:** Клон НИКОГДА не должен показывать IP 185.244.175.90 наружу!

---

## ФАЙЛЫ

### На хосте .90 (основная система)

```
C:\BCD_BACKUP                           - Резервная копия загрузчика
C:\VMClone\clon192-4.vhdx              - VHDX клона (297GB)
C:\VMClone\clon192-4.vhdx.backup       - Резервная копия VHDX
C:\BootManager\boot-to-clone.bat       - Загрузить клон
C:\BootManager\boot-to-main.bat        - Загрузить основную систему
C:\BootManager\check-next-boot.bat     - Проверить следующую загрузку
```

### В клоне (после монтирования как D:)

```
D:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\BLOCK_ALL_EXCEPT_WIREGUARD.bat
D:\EMERGENCY_RETURN.bat
D:\Install\wireguard-installer.exe
D:\Install\WireGuard\wg-clone.conf
```

### В клоне (после загрузки как C:)

```
C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\BLOCK_ALL_EXCEPT_WIREGUARD.bat
C:\EMERGENCY_RETURN.bat
C:\Program Files\WireGuard\Data\Configurations\wg-clone.conf
```

---

## ПОРЯДОК ДЕЙСТВИЙ (КРАТКИЙ)

1. **Настроить BCD** → `MASTER_INSTRUCTIONS.md` Фаза 1
2. **Создать скрипты управления** → Фаза 2
3. **Настроить клон** → `setup-clone-before-boot.bat`
4. **Настроить WireGuard** → Фаза 4
5. **Первая загрузка** → `boot-to-clone.bat` → Фаза 5
6. **Проверка** → `curl ifconfig.me` должен показать 194.31.72.192

---

## АВАРИЙНЫЕ ПРОЦЕДУРЫ

### 🚨 Клон показывает неправильный IP

```cmd
C:\EMERGENCY_RETURN.bat
```

### 🚨 Не могу подключиться к серверу после перезапуска

1. Подождать 3-5 минут
2. Жесткая перезагрузка (физически или через hosting panel)
3. Система загрузится в основную (default)

### 🚨 Загрузчик сломан

```cmd
# Загрузиться с установочного USB/ISO
# В Recovery Console:
bcdedit /import C:\BCD_BACKUP
```

---

## ПОДДЕРЖИВАЕМЫЕ ОПЕРАЦИИ

| Операция | Из основной системы | Из клона |
|----------|-------------------|----------|
| Загрузить клон | ✅ `boot-to-clone.bat` | ❌ |
| Вернуться в основную | ❌ | ✅ `EMERGENCY_RETURN.bat` |
| Проверить следующую загрузку | ✅ `check-next-boot.bat` | ✅ `check-next-boot.bat` |
| Редактировать BCD | ✅ | ✅ |
| Смонтировать VHDX | ✅ | ❌ (нельзя монтировать загруженный VHDX) |

---

## КЛЮЧИ WIREGUARD

```
Приватный ключ клона:   [ЗАПИСАТЬ ПОСЛЕ ГЕНЕРАЦИИ]

Публичный ключ клона:   [ЗАПИСАТЬ ПОСЛЕ ГЕНЕРАЦИИ]

Публичный ключ эталона: [ПОЛУЧИТЬ С .192: wg show]
```

---

**ПОЛНЫЕ ИНСТРУКЦИИ:** См. `MASTER_INSTRUCTIONS.md`
