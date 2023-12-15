# Pong
 - Author: Junyan Tang, Xiaoan Xu, Xueyi Fu
 - Date: 12/14/2023

### Design Description
We implement an interactive game called __PONG__ using processor and IO components (a VGA screen and a PS2 keyboard). 

**skeleton.v**
<br> This is a wrapper around the processor to provide certain control over VGA and PS2. 

**PS2_Interface.v**
<br> This is an interface over PS2 keyboard. It records the recieved data after a key being pressed.

**vga_controller.v**
<br> This is the core module in this design. We implement all the functions of the game in this module which includes basic rules, game reset and score display.

Other modules are derived from recitation_7 and recitation_8 in Duke ECE550.
