# Kenny Launcher для NixOS

Готовая тестовая версия **9.6.1-dev**, NixOS **x86_64**. Java и библиотеки включены; собирать исходники не нужно. Нужны рабочий графический интерфейс, интернет и около 6 ГБ свободного места без учёта Minecraft.

Установка из терминала обычного пользователя:

```bash
curl -fLO https://github.com/Tuxeodoman/kenny-launcher-nixos/releases/download/v9.6.1-dev-nixos/install.sh
bash install.sh
```

Запускайте **Kenny Launcher Dev** из меню приложений или:

```bash
~/.local/bin/kenny-launcher-nixos
```

Войдите в свой аккаунт и скачайте нужную сборку. Проверены Vanilla 1.21.1 и защищённая Avaloria с Connector на NixOS 26.05/X11.

Если в VMware не видны блоки: закройте игру и в `minecraft/config/sodium-options.json` установите `advanced.use_advanced_staging_buffers` в `false`, предварительно сохранив копию файла.

Для Ubuntu/Mint предназначен отдельный пакет; этот установщик рассчитан только на NixOS.
