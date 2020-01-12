** SUMMARY ** 
This repository contains code that interfaces a BeagleBone Black (BBB) SBC 
with a pair of Super Nintendo Entertainment System (SNES) gamepads. It uses a
Programmable Realtime Unit (PRU) of the BBB with userspace I/O (UIO) to 
bitbang the gamepad serial interface. 

** AUTHOR **
Andrew Henderson (hendersa@icculus.org): https://icculus.org/~hendersa

** DESCRIPTION **
Four BBB GPIOs are used:

OUTPUTS
Gamepad Clock:  P9.11 (GPIO0[30])
Gamepad Latch:  P9.13 (GPIO0[31])

INPUTS
Gamepad 1 Data: P9.17 (GPIO0[03])
Gamepad 2 Data: P9.21 (GPIO0[05])

The details of the protocol are described here:
https://gamefaqs.gamespot.com/snes/916396-super-nintendo/faqs/5395

The key files in this repository are:

prussdrv/*   : The Texas Instruments prussdrv driver library
pru.c        : Convenience wrapper functions around the prussdrv interface
prugamepad.c : Starts execution of PRU firmware and parses gamepad data
gamepad.p    : PRU firmware code (PRU assembly)
setup.sh     : Convenience shell script to set directions on the GPIO pins
wiring.png   : Suggested wiring diagram for the interface circuit

** BUILDING **
To build the gamepad.p file, you'll need the PASM tool:

$ git clone https://github.com/beagleboard/am335x_pru_package
$ cd am335x_pru_package/pru_sw/utils/pasm_source
$ ./linuxbuild
$ sudo cp ../pasm /usr/local/bin

Once PASM is installed, you can build the software (on your BBB) via make:

$ make

Then, set the pin directions using the setup script:

$ sudo ./setup.sh

Finally, run the test program:

$ sudo ./prugamepad

