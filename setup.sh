#!/bin/sh
echo Configuring GPIO pin directions...

echo in > /sys/class/gpio/gpio3/direction
echo in > /sys/class/gpio/gpio5/direction
echo out > /sys/class/gpio/gpio30/direction
echo out > /sys/class/gpio/gpio31/direction

echo Done!

