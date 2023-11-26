# Build wayland/weston and mesa on Ubuntu-22.04

Verified on WSL2, VMware Machine.

## Downloading the code

``` bash
mkdir -p $HOME/workspace
cd $HOME/workspace
git clone --recurse-submodules https://github.com/sepnic/gfx-wayland.git
```

## Installing system dependencies

``` bash
sudo apt-get install cmake build-essential bison flex autoconf meson hwdata \
    python3-pip python3-mako pkg-config

sudo apt-get install libxml2-dev libffi-dev libudev-dev libevdev-dev libmtdev-dev \
    libpciaccess-dev libpng-dev libfontconfig1-dev libglib2.0-dev libelf-dev \
    libsystemd-dev liblcms2-dev libpam0g-dev

## Update meson if "ERROR: Meson version is 0.61.2 but project requires >= 0.63.0"
pip3 install meson==0.63
```

## Setting up the environment

Setup custom installation path to not disturb the default linux installation.
Setup needed environment settings without impacting your overall system settings.
You can add this in your .bashrc file.
Note that `gfx_wayland_setup` need to be run in any terminal you want to launch these costom build components.

``` bash
function gfx_wayland_setup() {
    export GFX_SOURCE=$HOME/workspace/gfx-wayland
    export GFX_INSTALL=$GFX_SOURCE/out
    export EGL_PLATFORM=wayland
    export XDG_CONFIG_DIRS=$XDG_CONFIG_DIRS:$GFX_INSTALL/etc/xdg
    export LD_LIBRARY_PATH=$GFX_INSTALL/lib:$GFX_INSTALL/lib/x86_64-linux-gnu:$GFX_INSTALL/lib/x86_64-linux-gnu/dri
    export LIBRARY_PATH=$GFX_INSTALL/lib:$LIBRARY_PATH
    export PKG_CONFIG_PATH=$GFX_INSTALL/share/pkgconfig:$GFX_INSTALL/lib/pkgconfig:$GFX_INSTALL/lib64/pkgconfig:$GFX_INSTALL/lib/x86_64-linux-gnu/pkgconfig
    export PATH=$GFX_INSTALL:$GFX_INSTALL/bin:$PATH
    export ACLOCAL_PATH=$GFX_INSTALL/share/aclocal
    export ACLOCAL="aclocal -I $ACLOCAL_PATH"
    export C_INCLUDE_PATH=$GFX_INSTALL/include
    export CPLUS_INCLUDE_PATH=$GFX_INSTALL/include
    export LC_ALL=en_US.UTF8
}
```

## Building wayland/weston and mesa

### Wayland

``` bash
cd $GFX_SOURCE/wayland/
meson $GFX_INSTALL/build/wayland --prefix=$GFX_INSTALL -Ddocumentation=false
ninja -C $GFX_INSTALL/build/wayland install
```

### Wayland-protocols

``` bash
cd $GFX_SOURCE/wayland-protocols/
meson $GFX_INSTALL/build/wayland-protocols --prefix=$GFX_INSTALL
ninja -C $GFX_INSTALL/build/wayland-protocols install
```

### Seatd

``` bash
cd $GFX_SOURCE/seatd/
meson $GFX_INSTALL/build/seatd --prefix=$GFX_INSTALL -Dlibseat-builtin=enabled -Dman-pages=disabled
ninja -C $GFX_INSTALL/build/seatd install
```

### libxkbcommon

``` bash
cd $GFX_SOURCE/libxkbcommon/
meson $GFX_INSTALL/build/libxkbcommon --prefix=$GFX_INSTALL \
    -Dbash-completion-path=$GFX_INSTALL/bin \
    -Denable-x11=false \
    -Dxkb-config-root=/usr/share/X11/xkb \
    -Dx-locale-root=/usr/share/X11/locale \
    -Denable-docs=false
ninja -C $GFX_INSTALL/build/libxkbcommon install
```

### libinput

``` bash
cd $GFX_SOURCE/libinput/
meson $GFX_INSTALL/build/libinput --prefix=$GFX_INSTALL \
    -Dlibwacom=false -Ddebug-gui=false -Dtests=false -Dinstall-tests=false
ninja -C $GFX_INSTALL/build/libinput install
```

### libdrm

``` bash
cd $GFX_SOURCE/libdrm/
meson $GFX_INSTALL/build/libdrm --prefix=$GFX_INSTALL \
    -Dintel=enabled -Dradeon=enabled -Damdgpu=enabled -Dnouveau=enabled \
    -Dvmwgfx=enabled -Domap=enabled -Dexynos=enabled -Dfreedreno=enabled \
    -Dtegra=enabled -Dvc4=enabled -Detnaviv=enabled \
    -Dcairo-tests=disabled -Dman-pages=disabled -Dvalgrind=disabled
ninja -C $GFX_INSTALL/build/libdrm install
```

### Pixman

``` bash
cd $GFX_SOURCE/pixman/
meson $GFX_INSTALL/build/pixman --prefix=$GFX_INSTALL \
    -Dloongson-mmi=disabled -Diwmmxt=disabled -Dmips-dspr2=disabled \
    -Dvmx=disabled -Dgtk=disabled -Dlibpng=disabled
ninja -C $GFX_INSTALL/build/pixman install
```

### Cairo

``` bash
cd $GFX_SOURCE/cairo/
meson $GFX_INSTALL/build/cairo --prefix=$GFX_INSTALL \
    -Dtests=disabled -Dgtk2-utils=disabled -Dsymbol-lookup=disabled -Dgtk_doc=false
ninja -C $GFX_INSTALL/build/cairo install
```

### DirectX-Headers

``` bash
cd $GFX_SOURCE/DirectX-Headers/
meson $GFX_INSTALL/build/DirectX-Headers --prefix=$GFX_INSTALL -Dbuild-test=false
ninja -C $GFX_INSTALL/build/DirectX-Headers install
```

### Mesa

``` bash
cd $GFX_SOURCE/mesa/
meson $GFX_INSTALL/build/mesa --prefix=$GFX_INSTALL \
    -Dgallium-drivers=swrast,nouveau,radeonsi,i915,svga,iris,d3d12 \
    -Dvulkan-drivers= \
    -Dplatforms=wayland -Degl=enabled -Dgles2=enabled \
    -Dopengl=false -Dgles1=disabled -Dglx=disabled \
    -Dllvm=disabled -Dshared-llvm=disabled -Dandroid-libbacktrace=disabled
ninja -C $GFX_INSTALL/build/mesa install
```

### libdisplay-info

``` bash
cd $GFX_SOURCE/libdisplay-info/
meson $GFX_INSTALL/build/libdisplay-info --prefix=$GFX_INSTALL
ninja -C $GFX_INSTALL/build/libdisplay-info install
```

### Weston

``` bash
cd $GFX_SOURCE/weston/
meson $GFX_INSTALL/build/weston --prefix=$GFX_INSTALL \
    -Dbackend-drm-screencast-vaapi=false -Dbackend-rdp=false \
    -Dbackend-x11=false -Dbackend-pipewire=false -Dbackend-vnc=false \
    -Dxwayland=false -Dremoting=false -Dpipewire=false \
    -Dimage-jpeg=false -Dimage-webp=false -Ddemo-clients=false
ninja -C $GFX_INSTALL/build/weston install
```

### apitrace

``` bash
mkdir -p $GFX_INSTALL/build/apitrace
cd $GFX_INSTALL/build/apitrace
cmake $GFX_SOURCE/apitrace -DCMAKE_INSTALL_PREFIX=$GFX_INSTALL \
    -DENABLE_STATIC_LIBGCC=OFF -DENABLE_STATIC_LIBSTDCXX=OFF -DENABLE_X11=OFF \
    -DENABLE_STATIC_SNAPPY=ON
make
make install
```

## Running weston and wayland-client

Opening Terminal A to launch wayland-server:

``` bash
gfx_wayland_setup
$GFX_INSTALL/bin/weston --debug --shell=desktop-shell.so
```

Opening Terminal B to launch wayland-client:

``` bash
gfx_wayland_setup
export WAYLAND_DISPLAY=wayland-1
$GFX_INSTALL/bin/weston-simple-egl
```

## Using apitrace to trace egl/gl API calls

Opening Terminal A to launch wayland-server:

``` bash
gfx_wayland_setup
$GFX_INSTALL/bin/weston --debug --shell=desktop-shell.so
```

Opening Terminal B to trace egl/gl api calls of wayland-client application:

``` bash
gfx_wayland_setup
export WAYLAND_DISPLAY=wayland-1
$GFX_INSTALL/bin/apitrace trace --api=egl $GFX_INSTALL/bin/weston-simple-egl
$GFX_INSTALL/bin/apitrace dump weston-simple-egl.trace > weston-simple-egl.txt
cat weston-simple-egl.txt
```

## Reference

- https://docs.mesa3d.org/install.html
- https://wayland.freedesktop.org/building.html
- https://devblogs.microsoft.com/commandline/d3d12-gpu-video-acceleration-in-the-windows-subsystem-for-linux-now-available/
- https://gitlab.freedesktop.org/mesa/mesa
- https://gitlab.freedesktop.org/wayland/weston
