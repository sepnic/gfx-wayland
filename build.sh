#!/bin/bash

set -x
set -e

function gfx_wayland_setup() {
    export GFX_TOP=$HOME/workspace/gfx-wayland
    export GFX_SOURCE=$GFX_TOP/src
    export GFX_INSTALL=$GFX_TOP/out
    export EGL_PLATFORM=wayland
    export XDG_CONFIG_DIRS=$XDG_CONFIG_DIRS:$GFX_INSTALL/etc/xdg
    export LD_LIBRARY_PATH=$GFX_INSTALL/lib:$GFX_INSTALL/lib/$(uname -m)-linux-gnu:$GFX_INSTALL/lib/$(uname -m)-linux-gnu/dri
    export LIBRARY_PATH=$GFX_INSTALL/lib:$LIBRARY_PATH
    export PKG_CONFIG_PATH=$GFX_INSTALL/share/pkgconfig:$GFX_INSTALL/lib/pkgconfig:$GFX_INSTALL/lib64/pkgconfig:$GFX_INSTALL/lib/$(uname -m)-linux-gnu/pkgconfig
    export PATH=$GFX_INSTALL:$GFX_INSTALL/bin:$PATH
    export ACLOCAL_PATH=$GFX_INSTALL/share/aclocal
    export ACLOCAL="aclocal -I $ACLOCAL_PATH"
    export C_INCLUDE_PATH=$GFX_INSTALL/include
    export CPLUS_INCLUDE_PATH=$GFX_INSTALL/include
    export LC_ALL=en_US.UTF8
}

gfx_wayland_setup

### Wayland
cd $GFX_SOURCE/wayland/
meson $GFX_INSTALL/build/wayland --prefix=$GFX_INSTALL -Ddocumentation=false -Ddtd_validation=false
ninja -C $GFX_INSTALL/build/wayland install

### Wayland-protocols
cd $GFX_SOURCE/wayland-protocols/
meson $GFX_INSTALL/build/wayland-protocols --prefix=$GFX_INSTALL
ninja -C $GFX_INSTALL/build/wayland-protocols install

### Seatd
cd $GFX_SOURCE/seatd/
meson $GFX_INSTALL/build/seatd --prefix=$GFX_INSTALL -Dlibseat-builtin=enabled -Dman-pages=disabled
ninja -C $GFX_INSTALL/build/seatd install

### libxkbcommon
cd $GFX_SOURCE/libxkbcommon/
meson $GFX_INSTALL/build/libxkbcommon --prefix=$GFX_INSTALL \
    -Dbash-completion-path=$GFX_INSTALL/bin \
    -Denable-x11=false \
    -Dxkb-config-root=/usr/share/X11/xkb \
    -Dx-locale-root=/usr/share/X11/locale \
    -Denable-docs=false
ninja -C $GFX_INSTALL/build/libxkbcommon install

### libinput
cd $GFX_SOURCE/libinput/
meson $GFX_INSTALL/build/libinput --prefix=$GFX_INSTALL \
    -Dlibwacom=false -Ddebug-gui=false -Dtests=false -Dinstall-tests=false
ninja -C $GFX_INSTALL/build/libinput install

### libdrm
cd $GFX_SOURCE/libdrm/
meson $GFX_INSTALL/build/libdrm --prefix=$GFX_INSTALL \
    -Dintel=enabled -Dradeon=enabled -Damdgpu=enabled -Dnouveau=enabled \
    -Dvmwgfx=enabled -Domap=enabled -Dexynos=enabled -Dfreedreno=enabled \
    -Dtegra=enabled -Dvc4=enabled -Detnaviv=enabled \
    -Dcairo-tests=disabled -Dman-pages=disabled -Dvalgrind=disabled
ninja -C $GFX_INSTALL/build/libdrm install

### Pixman
cd $GFX_SOURCE/pixman/
meson $GFX_INSTALL/build/pixman --prefix=$GFX_INSTALL \
    -Dloongson-mmi=disabled -Dmmx=disabled -Dmips-dspr2=disabled \
    -Dvmx=disabled -Dgtk=disabled -Drvv=disabled -Dlibpng=disabled
ninja -C $GFX_INSTALL/build/pixman install

### Cairo
cd $GFX_SOURCE/cairo/
meson $GFX_INSTALL/build/cairo --prefix=$GFX_INSTALL \
    -Dtests=disabled -Dgtk2-utils=disabled -Dsymbol-lookup=disabled -Dgtk_doc=false
ninja -C $GFX_INSTALL/build/cairo install

### libdisplay-info
cd $GFX_SOURCE/libdisplay-info/
meson $GFX_INSTALL/build/libdisplay-info --prefix=$GFX_INSTALL
ninja -C $GFX_INSTALL/build/libdisplay-info install

### Weston
cd $GFX_SOURCE/weston/
meson $GFX_INSTALL/build/weston --prefix=$GFX_INSTALL \
    -Drenderer-gl=true -Drenderer-vulkan=true \
    -Dshell-desktop=true -Dshell-ivi=true -Dshell-lua=false \
    -Dbackend-drm=true -Dbackend-wayland=true -Dbackend-headless=true \
    -Dbackend-drm-screencast-vaapi=false -Dbackend-rdp=false \
    -Dbackend-x11=false -Dbackend-pipewire=false -Dbackend-vnc=false \
    -Dxwayland=false -Dremoting=false -Dpipewire=false \
    -Dcolor-management-lcms=false -Dimage-jpeg=false -Dimage-webp=false \
    -Ddemo-clients=false -Dtest-junit-xml=false
ninja -C $GFX_INSTALL/build/weston install

### apitrace
mkdir -p $GFX_INSTALL/build/apitrace
cd $GFX_INSTALL/build/apitrace
cmake $GFX_SOURCE/apitrace -DCMAKE_INSTALL_PREFIX=$GFX_INSTALL \
    -DENABLE_STATIC_LIBGCC=OFF -DENABLE_STATIC_LIBSTDCXX=OFF \
    -DENABLE_X11=OFF -DENABLE_EGL=ON \
    -DENABLE_WAFFLE=ON -DBUILD_TESTING=OFF
make
make install

### nvtop
mkdir -p $GFX_INSTALL/build/nvtop
cd $GFX_INSTALL/build/nvtop
cmake $GFX_SOURCE/nvtop -DCMAKE_INSTALL_PREFIX=$GFX_INSTALL
make
make install
