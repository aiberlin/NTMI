// Useful Things you might need to do when installing:


// On Windows, when you cannot install quarks, \
// you may need to install the git software from here:
"https://git-scm.com".openOS;
// and reboot before you can use it!


// Install NTMI if you havent yet
Quarks.install("NTMI");

// if you have an older version installed, update it:
Quark("NTMI").update;

// these are the other quarks NTMI needs to have installed:
Quark("NTMI").dependencies.collect(_.name).postln;

// make sure you have them all
Quark("NTMI").do(_.install);

// make sure you have the latest versions
Quark("NTMI").do(_.update);


// if you want to use networked xflux,
// make sure you have latest HyperDisCo installed
Quark("HyperDisCo").install;
Quark("HyperDisCo").update;


// For using HID devices, such as gamepads,
// on linux, including raspberry Pi,
// you need to give HID devices the proper rights.

### In the Terminal, create a file with rules that enable HID gamepads
### with the nano text editor:
sudo nano /etc/udev/rules.d/99-hid.rules

### put this line in the file:
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", OWNER="root", GROUP="plugdev", MODE="0660"

### and save with control-o, cntrol-x

### to make it work immediately, do
sudo udevadm trigger

