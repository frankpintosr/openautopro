#!/usr/bin/python3
"""Volume bar indicator for rotary switch with push-button"""
import subprocess
import threading
from collections import deque

import tkinter as tk
from tkinter import ttk

class VolIndicator:
    """Volume Indicator"""
    def __init__(self, root, mixer_name, cmds=None):
        if cmds is None:
            cmds = {
                'vol_down_cmd': 'xdotool key F7',
                'vol_up_cmd': 'xdotool key F8',
                'vol_mute_cmd': 'amixer -q -D pulse sset Master toggle'}
        self.root = root
        self.mixer_name = mixer_name
        self.vol_timer = None
        self.vol_lvl_var = tk.IntVar()
        self._create_window()
        self._run()

    def _create_window(self):
        self.root.attributes('-alpha', 0.0) #For icon
        self.root.overrideredirect(1)
        scr_w = self.root.winfo_screenwidth()
        scr_h = self.root.winfo_screenheight()
        win_w = int(scr_w / 2)
        win_h = 20
        win_x = int((scr_w - win_w) / 2)
        win_y = int((scr_h - win_h) / 2)
        self.root.geometry(
            str(win_w) + 'x' + str(win_h) + '+' + str(win_x) + '+' + str(win_y))  #Whatever size
        self.vol_lvl_var.set(self.get_vol_lvl())
        style = ttk.Style()
        style.configure('Horizontal.TProgressbar', background='#F5B42A')
        style.configure('Horizontal.TProgressbar', troughcolor='#000000')
        style.configure('Horizontal.TProgressbar', borderwidth=1)
        style.configure('Horizontal.TProgressbar', troughrelief='flat')
        style.configure('Horizontal.TProgressbar', pbarrelief='flat')
        self.vol_vol_bar = ttk.Progressbar(
            self.root, orient=tk.HORIZONTAL, length=400,
            mode='determinate', variable=self.vol_lvl_var)
        self.vol_vol_bar.pack(fill=tk.BOTH, expand=1)
        #close = tk.Button(root, text="Close Window", command=root.destroy)
        #close.pack(fill=tk.BOTH, expand=1)
        self.root.withdraw()

    def _run(self):
        rs_dev_ev = subprocess.check_output(
            'rs_dev_ev='
            + '$(readlink -f /dev/input/by-path/$(ls /dev/input/by-path | grep rotary))'
            + ';echo -n $rs_dev_ev',
            shell=True)
        pb_dev_ev = subprocess.check_output(
            'pb_dev_ev='
            + '$(readlink -f /dev/input/by-path/$(ls /dev/input/by-path | grep button))'
            + ';echo -n $pb_dev_ev',
            shell=True)

        self.rs_deque = deque(maxlen=10)
        rs_proc = subprocess.Popen(
            ['evtest', rs_dev_ev], stdout=subprocess.PIPE)
        rs_thrd = threading.Thread(
            target=self._read_rs, args=(rs_proc, self.rs_deque.append))
        rs_thrd.daemon = True
        rs_thrd.start()

        self.pb_deque = deque(maxlen=10)
        pb_proc = subprocess.Popen(
            ['evtest', pb_dev_ev], stdout=subprocess.PIPE)
        pb_thrd = threading.Thread(
            target=self._read_pb, args=(pb_proc, self.pb_deque.append))
        pb_thrd.daemon = True
        pb_thrd.start()

    def get_vol_lvl(self):
        """Returns volume level (0-100) from amixer"""
        output = subprocess.check_output(['amixer', 'sget', self.mixer_name]).decode('utf-8')
        return int(output[(output.find('[') + 1):output.find('%]', (output.find('[') + 1))])

    def _show_vol_bar(self):
        """Show volume bar window"""
        self.root.deiconify()

    def _hide_vol_bar(self):
        """Hide volume bar window"""
        self.root.withdraw()

    def _start_vol_timer(self):
        """Set volume timer"""
        self.vol_timer = threading.Timer(2, self._hide_vol_bar)
        self.vol_timer.start()

    def vol_down(self):
        """Turn up volume"""
        if self.vol_timer is not None:
            self.vol_timer.cancel()
        subprocess.run(['xdotool', 'key', 'F7'])
        self._show_vol_bar()
        self.vol_lvl_var.set(self.get_vol_lvl())
        self._start_vol_timer()

    def vol_up(self):
        """Turn up volume"""
        if self.vol_timer is not None:
            self.vol_timer.cancel()
        subprocess.run(['xdotool', 'key', 'F8'])
        self._show_vol_bar()
        self.vol_lvl_var.set(self.get_vol_lvl())
        self._start_vol_timer()

    def vol_mute(self):
        """Toggle mute"""
        subprocess.run(['amixer', '-q', '-D', 'pulse', 'sset', self.mixer_name, 'toggle'])

    def _read_rs(self, process, append):
        """Read stdout of rotary switch process"""
        print('read_rs thread started')
        for line in iter(process.stdout.readline, ""):
            if 'value 1' in line.decode('utf-8'):
                self.vol_up()
            if 'value -1' in line.decode('utf-8'):
                self.vol_down()
        print('read_rs thread stopped')

    def _read_pb(self, process, append):
        """Read stdout of pushbutton process"""
        print('read_pb thread started')
        for line in iter(process.stdout.readline, ""):
            if 'value 1' in line.decode('utf-8'):
                self.vol_mute()
        print('read_pb thread stopped')


def main():
    """Main application"""
    root = tk.Tk()
    mixer_name = 'Master'
    cmds = {
        'vol_down_cmd': 'xdotool key F7',
        'vol_up_cmd': 'xdotool key F8',
        'vol_mute_cmd': 'amixer -q -D pulse sset' + mixer_name + 'toggle'
    }
    VolIndicator(root, mixer_name, cmds)
    root.mainloop()

if __name__ == "__main__":
    main()
    
