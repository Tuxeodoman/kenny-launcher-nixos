# Kenny Launcher для NixOS

Пакет **9.6.1-dev**, **x86_64-linux**. Qt включён в пакет, Java 8/17/21/25 и системные библиотеки устанавливает Nix.

Запуск:

```bash
nix run github:Tuxeodoman/kenny-launcher-nixos
```

Для конфигурации с flakes добавьте вход:

```nix
inputs.kenny-launcher.url = "github:Tuxeodoman/kenny-launcher-nixos";
```

И пакет в модуль NixOS (передайте `inputs` через `specialArgs`):

```nix
environment.systemPackages = [
  inputs.kenny-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

В Home Manager используйте тот же пакет в `home.packages`.

Без flakes: сохраните `kenny-launcher.nix` рядом с конфигурацией и добавьте:

```nix
nixpkgs.config.allowUnfreePredicate = pkg: pkgs.lib.getName pkg == "kenny-launcher";
environment.systemPackages = [ (pkgs.callPackage ./kenny-launcher.nix { }) ];
```

Запускайте `kenny-launcher` или откройте **Kenny Launcher Dev** в меню приложений. Затем войдите в свой аккаунт и скачайте сборку.
Обновление выполняется через обновление flake/пакета и обычный `nixos-rebuild`; встроенное обновление лаунчера отключено.

Старый архив NAR и `install.sh` остаются в релизе для переноса уже собранного окружения.

Проверено на NixOS 26.05, X11: `nix build`, `nix flake check`, запуск защищённой Avaloria, мир и карта. Для VMware отключите «Постоянный буфер памяти» в настройках Sodium, если не видны блоки.
