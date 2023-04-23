# How to use Xdummy?

To render `mujuco` environments in a headless server, you want to setup `Xdummy` headless display. This means doing these three things:

1. Add Xdummy, which is a bash script, to your bin folder (/usr/bin) so that you can do step 2
2. run `Xdummy` from your bash, as a standalone thread. Xdummy needs to be running when you execute 3.
3. run your python script with `DISPLAY` variable set to `DISPLAY=:0`. This is also what you do to point `Mujoco` to a VNC display if you want to inspect a remote training session.

## 0. Installation Requirements

```bash
sudo apt-get update && sudo apt-get install -y \
    ffmpeg \
    libav-tools \
    libpq-dev \
    libjpeg-dev \
    cmake \
    swig \
    python-opengl \
    libboost-all-dev \
    libsdl2-dev \
    xpra
```

## 1. Install Xdummy

Xdummy is just a script: download the script (also availabe inside [vendors](./) folder) Pull and make it executable.

```bash
curl-o/usr/bin/Xdummy https://gist.githubusercontent.com/nottombrown/ffa457f020f1c53a0105ce13e8c37303/raw/ff2bc2dcf1a69af141accd7b337434f074205b23/Xdummy
chmod+x/usr/bin/Xdummy
```

## 2. 开始Xdummy显示

because `Xdummy` is now in your bin folder, you can just run:
```bash
Xdummy
```

## 3. Run your python script with `DISPLAY` variable

Now run your script pointing to this fake display:
```bash
DISPLAY=:0 python rl_teacher/tests/video_render_test.py
```

Happy Xdummying!

-- Ge :heart:
