{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, python3
, gobject-introspection
, gtk3
, libusb1
, systemd
, libnotify
, wrapGAppsHook
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gx52";
  version = "0.7.6";
  format = "other";

  src = fetchFromGitHub {
    owner = "leinardi";
    repo = "gx52";
    rev = version;
    sha256 = "sha256-hj1nqtcSirCaeLxayF3OhiWbzt1Ic3R16pKdsEcY28g=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    libusb1
    systemd
    libnotify
  ];

  propagatedBuildInputs = with python3.pkgs; [
    evdev
    injector
    packaging
    peewee
    pygobject3
    pyudev
    pyusb
    pyxdg
    reactivex
    requests
    xlib
  ];

  postPatch = ''
    chmod +x scripts/meson_post_install.py
    patchShebangs scripts/meson_post_install.py
    
    # Disable problematic post-install script calls
    substituteInPlace scripts/meson_post_install.py \
      --replace "subprocess.call(['glib-compile-schemas'" "# subprocess.call(['glib-compile-schemas'" \
      --replace "subprocess.call(['gtk-update-icon-cache'" "# subprocess.call(['gtk-update-icon-cache'" \
      --replace "subprocess.call(['update-desktop-database'" "# subprocess.call(['update-desktop-database'"
    
    # Fix distutils import (removed in Python 3.12+)
    substituteInPlace gx52/interactor/check_new_version_interactor.py \
      --replace "from distutils.version import LooseVersion" "from packaging.version import Version as LooseVersion"
  '';

  meta = with lib; {
    description = "GTK application to control Logitech X52 and X52 Pro H.O.T.A.S. devices";
    longDescription = ''
      GX52 is a GTK application designed to control the LEDs and Multi-Function 
      Display (MFD) of Logitech X52 and X52 Pro H.O.T.A.S. devices. It allows
      users to set LED colors and brightness, control individual LED states,
      adjust MFD brightness, update MFD date and time, and save/restore profiles.
    '';
    homepage = "https://github.com/leinardi/gx52";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ ];
    mainProgram = "gx52";
  };
}