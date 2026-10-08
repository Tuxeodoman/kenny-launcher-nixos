#!/usr/bin/env bash
set -euo pipefail

readonly version='9.6.1-dev'
readonly package='/nix/store/jf9ji9j5vgb2gjhf244sgjy82jarxrln-kenny-launcher-dev-9.6.1-dev'
readonly asset="kenny-launcher-${version}-nixos-x86_64.nar.xz"
readonly base='https://github.com/Tuxeodoman/kenny-launcher-nixos/releases/download/v9.6.1-dev-nixos'
readonly expected='1a65c44e45c8a7f2bd199ac2603d561f4bccc1fd83dce45e21e844e36877cd09'

die() { printf '%s\n' "$*" >&2; exit 1; }
[[ $(uname -s) == Linux && $(uname -m) == x86_64 ]] || die 'Нужен NixOS x86_64.'
[[ -f /etc/NIXOS ]] || die 'Этот пакет предназначен для NixOS.'
[[ $EUID -ne 0 ]] || die 'Запустите bash install.sh без sudo; пароль будет запрошен при импорте.'
[[ $# -le 1 ]] || die 'Использование: bash install.sh [путь-к-архиву.nar.xz]'
for tool in nix-store nix-env xz sha256sum sudo; do
    command -v "$tool" >/dev/null || die "Не найдена программа: $tool"
done

if [[ $# == 1 ]]; then
    archive=$(realpath -- "$1")
    [[ -f "$archive" ]] || die "Нет архива: $archive"
else
    command -v curl >/dev/null || die 'Нужен curl: nix-shell -p curl'
    cache="${XDG_CACHE_HOME:-$HOME/.cache}/kenny-launcher-nixos/$version"
    mkdir -p -- "$cache"
    archive="$cache/$asset"
    if [[ ! -f "$archive" ]]; then
        printf 'Скачивание лаунчера, Java и библиотек…\n'
        curl --fail --location --retry 4 --connect-timeout 30 --continue-at - \
            --output "$archive.partial" "$base/$asset"
        mv -- "$archive.partial" "$archive"
    fi
fi

printf 'Проверка архива…\n'
actual=$(sha256sum -- "$archive")
[[ ${actual%% *} == "$expected" ]] || die "Контрольная сумма не совпала. Скачайте архив заново: $archive"
xz --test -- "$archive"
sudo -v
printf 'Установка…\n'
xz --decompress --stdout -- "$archive" | sudo nix-store --import >/dev/null

profile="${XDG_STATE_HOME:-$HOME/.local/state}/kenny-launcher-nixos/profile"
mkdir -p -- "$(dirname "$profile")" "$HOME/.local/bin"
nix-env --profile "$profile" --install "$package"
ln -sfn -- "$profile/bin/KennyLauncher" "$HOME/.local/bin/kenny-launcher-nixos"
applications="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p -- "$applications"
cp -- "$package/share/applications/kenny-launcher-dev.desktop" "$applications/kenny-launcher-nixos.desktop"
printf 'Готово. Откройте Kenny Launcher Dev в меню или выполните:\n%s\n' "$HOME/.local/bin/kenny-launcher-nixos"
