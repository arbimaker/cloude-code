# НАЧНИТЕ ЗДЕСЬ - ИНСТРУКЦИИ ПО УСТАНОВКЕ

## ЧТО ЭТО?

Это набор скриптов и конфигураций для настройки dual boot Windows Server с WireGuard туннелем.

**ВАША КОНФИГУРАЦИЯ (обнаружена автоматически):**
- **Основная система:** `{current}` на C:\Windows
- **Клон:** `{830100c2-c752-11f0-88b8-d843ae6dfa0a}` → сейчас указывает на `clon192-3.vhdx`
- **Новый VHDX:** `C:\VMClone\clon192-4.vhdx` (уже скопирован)

## ШАГ 1: СКОПИРОВАТЬ ФАЙЛЫ НА СЕРВЕР .90

Все файлы из этой директории нужно скопировать на сервер 185.244.175.90.

**Рекомендуемый способ:**

1. Создайте на сервере .90 временную директорию:
   ```cmd
   mkdir C:\WireGuardSetup
   ```

2. Скопируйте ВСЕ .bat, .conf и .md файлы в `C:\WireGuardSetup\`

3. Или используйте RDP с общими папками для копирования файлов

## ШАГ 2: ОБНОВИТЬ BCD

Запустите на сервере .90:

```cmd
cd C:\WireGuardSetup
UPDATE_CLONE_VHDX.bat
```

Этот скрипт:
- ✅ Обновит запись клона для использования `clon192-4.vhdx` вместо `clon192-3.vhdx`
- ✅ Установит основную систему по умолчанию
- ✅ Настроит timeout = 0 и displaybootmenu = no
- ✅ Настроит безопасную загрузку с игнорированием ошибок

## ШАГ 3: СОЗДАТЬ СКРИПТЫ УПРАВЛЕНИЯ

```cmd
mkdir C:\BootManager

copy C:\WireGuardSetup\boot-to-clone-READY.bat C:\BootManager\boot-to-clone.bat
copy C:\WireGuardSetup\boot-to-main-READY.bat C:\BootManager\boot-to-main.bat
copy C:\WireGuardSetup\check-next-boot.bat C:\BootManager\check-next-boot.bat
```

**Проверка:**
```cmd
C:\BootManager\check-next-boot.bat
```

Должно показать что по умолчанию загружается основная система.

## ШАГ 4: НАСТРОИТЬ КЛОН ПЕРЕД ЗАГРУЗКОЙ

### 4.1. Смонтировать VHDX

```cmd
diskpart
select vdisk file="C:\VMClone\clon192-4.vhdx"
attach vdisk
list volume
```

Запомните букву диска (например, D:)

```cmd
exit
```

### 4.2. Запустить автоматическую настройку

```cmd
cd C:\WireGuardSetup
setup-clone-before-boot.bat
```

Этот скрипт автоматически:
- Создаст директории в клоне
- Скопирует скрипт блокировки файрвола `BLOCK_ALL_EXCEPT_WIREGUARD.bat`
- Настроит автозапуск блокировки
- Скопирует `EMERGENCY_RETURN-READY.bat` в клон как `D:\EMERGENCY_RETURN.bat`

### 4.3. Размонтировать VHDX

```cmd
diskpart
select vdisk file="C:\VMClone\clon192-4.vhdx"
detach vdisk
exit
```

## ШАГ 5: НАСТРОИТЬ WIREGUARD

### 5.1. Сгенерировать ключи (если WireGuard установлен на .90)

```cmd
cd C:\WireGuardSetup
generate-wireguard-keys.bat
```

Или вручную:
```cmd
wg genkey > clone-private.key
type clone-private.key | wg pubkey > clone-public.key
```

### 5.2. Обновить конфигурации

1. **Откройте `wg-clone.conf`** в блокноте:
   - Замените `CLONE_PRIVATE_KEY_HERE` на приватный ключ клона
   - Замените `ETALON_PUBLIC_KEY_HERE` на публичный ключ эталона

2. **На эталоне .192** добавьте в конфигурацию WireGuard:
   ```ini
   [Peer]
   PublicKey = <PUBLIC_KEY_КЛОНА>
   AllowedIPs = 10.0.0.2/32
   ```

3. Перезапустите WireGuard на эталоне

### 5.3. Скачать WireGuard installer

Скачайте установщик WireGuard для Windows:
https://download.wireguard.com/windows-client/wireguard-installer.exe

Переименуйте в `wireguard-installer.exe` и поместите в `C:\WireGuardSetup\`

### 5.4. Смонтировать VHDX снова и скопировать WireGuard

```cmd
diskpart
select vdisk file="C:\VMClone\clon192-4.vhdx"
attach vdisk
list volume
exit

mkdir D:\Install
copy C:\WireGuardSetup\wireguard-installer.exe D:\Install\
mkdir D:\Install\WireGuard
copy C:\WireGuardSetup\wg-clone.conf D:\Install\WireGuard\

diskpart
select vdisk file="C:\VMClone\clon192-4.vhdx"
detach vdisk
exit
```

## ШАГ 6: ПЕРВАЯ ЗАГРУЗКА КЛОНА

### 6.1. Запланировать загрузку клона

```cmd
C:\BootManager\boot-to-clone.bat
```

### 6.2. Перезапуск

```cmd
shutdown /r /t 30
```

### 6.3. После загрузки клона

1. **Подключитесь по RDP к 185.244.175.90**

2. **Установите WireGuard:**
   ```cmd
   D:\Install\wireguard-installer.exe
   ```

3. **Импортируйте конфигурацию:**
   - Откройте WireGuard GUI
   - Import tunnel from file
   - Выберите `D:\Install\WireGuard\wg-clone.conf`
   - Activate туннель

4. **ПРОВЕРЬТЕ IP:**
   ```cmd
   curl ifconfig.me
   ```

   **ДОЛЖНО ПОКАЗАТЬ: 194.31.72.192**

   ⚠️ **Если показывает 185.244.175.90 - немедленно выполните:**
   ```cmd
   C:\EMERGENCY_RETURN.bat
   ```

5. **Проверьте туннель:**
   ```cmd
   ping 10.0.0.1
   wg show
   ```

## ГОТОВО!

Теперь вы можете:

- **Загрузить клон:** `C:\BootManager\boot-to-clone.bat` → `shutdown /r /t 30`
- **Вернуться к основной:** Из клона запустите `C:\EMERGENCY_RETURN.bat`
- **Проверить следующую загрузку:** `C:\BootManager\check-next-boot.bat`

---

## ФАЙЛЫ В ЭТОМ КОМПЛЕКТЕ

### Готовые к использованию (с вашими GUID):
- `UPDATE_CLONE_VHDX.bat` - Обновить BCD для clon192-4.vhdx
- `boot-to-clone-READY.bat` - Загрузить клон (с правильным GUID)
- `boot-to-main-READY.bat` - Загрузить основную систему
- `EMERGENCY_RETURN-READY.bat` - Аварийный возврат (для размещения в клоне)

### Шаблоны (требуют замены GUID вручную):
- `boot-to-clone.bat` - Шаблон с плейсхолдером {GUID_КЛОНА}
- `boot-to-main.bat` - Шаблон с плейсхолдером {GUID_ОСНОВНОЙ}
- `EMERGENCY_RETURN.bat` - Шаблон с плейсхолдером

### Скрипты настройки:
- `setup-clone-before-boot.bat` - Автоматическая настройка клона
- `BLOCK_ALL_EXCEPT_WIREGUARD.bat` - Блокировка файрвола (копируется в клон)
- `check-next-boot.bat` - Проверка следующей загрузки
- `generate-wireguard-keys.bat` - Генерация ключей WireGuard

### Конфигурации:
- `wg-clone.conf` - WireGuard конфиг для клона
- `wg-etalon-update.conf` - Дополнение для конфига эталона

### Документация:
- `MASTER_INSTRUCTIONS.md` - Полные подробные инструкции
- `QUICK_REFERENCE.md` - Быстрая справка
- `README_START_HERE.md` - Этот файл

---

## ВАЖНЫЕ GUID ДЛЯ ВАШЕЙ СИСТЕМЫ

```
GUID основной системы: {current}
GUID клона:           {830100c2-c752-11f0-88b8-d843ae6dfa0a}
```

Эти GUID уже используются в файлах `*-READY.bat`!

---

## ПОДДЕРЖКА

Если возникли проблемы:
1. Выполните `C:\EMERGENCY_RETURN.bat` для безопасного возврата
2. Проверьте BCD: `bcdedit /enum`
3. См. `MASTER_INSTRUCTIONS.md` раздел TROUBLESHOOTING

---

**СЛЕДУЮЩИЙ ШАГ:** Выполните ШАГ 1 выше (скопируйте файлы на сервер .90)
