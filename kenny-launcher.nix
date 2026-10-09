{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper, makeDesktopItem
, libGL, libx11, libxext, libxrandr, libxcursor, libxi, libxinerama
, libxrender, libxfixes, libxxf86vm, libxcb, libxkbcommon, xcb-util-cursor
, fontconfig, freetype, dbus, libpulseaudio, alsa-lib, openal, udev
, openssl, zlib, glib, jdk8, jdk17, jdk21, jdk25, xdg-utils, cacert
, libpng, bzip2, expat, zstd, pcre2, libffi, systemd, krb5, brotli
, libproxy, wayland
}:
let
  version = "9.6.1-dev";
  runtimeLibraries = [
    stdenv.cc.cc.lib libGL libx11 libxext libxrandr libxcursor libxi
    libxinerama libxrender libxfixes libxxf86vm libxcb libxkbcommon
    xcb-util-cursor fontconfig freetype dbus libpulseaudio alsa-lib
    openal udev openssl zlib glib libpng bzip2 expat zstd pcre2 libffi
    systemd krb5 brotli libproxy wayland
  ];
  desktop = makeDesktopItem {
    name = "kenny-launcher";
    desktopName = "Kenny Launcher Dev";
    exec = "kenny-launcher %u";
    categories = [ "Game" ];
    mimeTypes = [ "x-scheme-handler/kenny" ];
    startupWMClass = "KennyLauncher";
  };
in stdenv.mkDerivation {
  pname = "kenny-launcher";
  inherit version;
  src = fetchurl {
    url = "https://github.com/Tuxeodoman/kenny-launcher-ubuntu/releases/download/v${version}-ubuntu-r1/kenny-launcher-${version}-ubuntu-x86_64.tar.xz";
    hash = "sha256-YmormL/GG1XuQmLK20rlwC0/eay6dQcHw/MoCkeqH0s=";
  };
  sourceRoot = "source";
  unpackPhase = ''
    runHook preUnpack
    mkdir source
    tar xf "$src" -C source
    runHook postUnpack
  '';
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = runtimeLibraries;

  installPhase = ''
    runHook preInstall
    app="$out/libexec/kenny-launcher"
    mkdir -p "$app" "$out/bin" "$out/share"
    for item in *; do
      case "$item" in java|KennyLauncher|kenny.install) continue ;; esac
      cp -a "$item" "$app/"
    done
    cp .KennyLauncher.bin "$app/KennyLauncher"
    chmod +x "$app/KennyLauncher"
    cp -r ${desktop}/share/applications "$out/share/"
    makeWrapper "$app/KennyLauncher" "$out/bin/kenny-launcher" \
      --set KENNY_EXTERNAL_UPDATES 1 \
      --set KENNY_JAVA_PATHS "${lib.makeSearchPath "bin/java" [ jdk8 jdk17 jdk21 jdk25 ]}" \
      --set QT_PLUGIN_PATH "$app/plugins" \
      --set QML_IMPORT_PATH "$app/qml" \
      --set QML2_IMPORT_PATH "$app/qml" \
      --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:$app/lib:${lib.makeLibraryPath runtimeLibraries}" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils jdk21 ]}" \
      --set-default SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt"
    runHook postInstall
  '';

  # Protected packs verify the complete JNI library hash. The wrapper supplies
  # its runtime dependencies; restore the original bytes after ELF fixups.
  preFixup = ''
    cp "$out/libexec/kenny-launcher/libnloader.so" "$TMPDIR/kenny-pinned-nloader.so"
  '';
  # autoPatchelfHook also runs from postFixupHooks, after the postFixup string.
  # A separate final phase is required to keep the pinned bytes intact.
  postPhases = [ "restorePinnedAgent" ];
  restorePinnedAgent = ''
    cp "$TMPDIR/kenny-pinned-nloader.so" "$out/libexec/kenny-launcher/libnloader.so"
    cmp "$TMPDIR/kenny-pinned-nloader.so" "$out/libexec/kenny-launcher/libnloader.so"
  '';
  meta = {
    description = "Kenny Minecraft launcher";
    homepage = "https://github.com/Tuxeodoman/kenny-launcher-nixos";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "kenny-launcher";
  };
}
