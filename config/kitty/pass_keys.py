# In applications like (Neo)vim, configured shortcuts like copy/paste do not work
#  because key combinations are captured and interpreted by the terminal.
# This script parses those key combinations and decides if they should be dealt
#  with by the terminal, or be passed to the running app.
#
# Taken from: https://blog.schroederspace.com/tumbleweed-technology/copy-paste-with-neovim-and-kitty-on-macos
# Developed from examples seen in: https://github.com/knubie/vim-kitty-navigator
import re

from kittens.tui.handler import result_handler
from kitty.key_encoding import KeyEvent, parse_shortcut

def is_app_window(window, app_id):
    fp = window.child.foreground_processes
    return any(re.search(app_id, p['cmdline'][0] if len(p['cmdline']) else '', re.I) for p in fp)

def encode_key_mapping(window, key_mapping):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32),
    ).as_window_system_event()

    return window.encoded_key(event)

def main():
    pass

@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    cmd = args[1]           # bottom, top, left, right, copy, paste
    key_mapping = args[2]   # ctrl+j, ctrl+k, ctrl+h, ctrl+l, ctrl+c, ctrl+v
    app_id = args[3] if len(args) > 3 else "n?vim"

    window = boss.window_id_map.get(target_window_id)

    if window is None:
        return
    if is_app_window(window, app_id):
        for keymap in key_mapping.split(">"):
            encoded = encode_key_mapping(window, keymap)
            window.write_to_child(encoded)
    elif cmd == "copy":
        window.copy_and_clear_or_interrupt()
    elif cmd == "paste":
        window.paste_selection_or_clipboard()
    else:
        boss.active_tab.neighboring_window(cmd)
