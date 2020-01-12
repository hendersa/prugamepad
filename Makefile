CC=gcc
CFLAGS=-I. -g
PASM=pasm
OBJS=prugamepad.o pru.o prussdrv/prussdrv.o
TARGET=prugamepad
FIRMWARE=gamepad.bin

all: $(TARGET) gamepad.bin

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

$(FIRMWARE): gamepad.p
	$(PASM) -b gamepad.p

$(TARGET): $(OBJS)
	$(CC) -o $(TARGET) $(OBJS) 

clean:
	rm -f $(OBJS) $(TARGET) $(FIRMWARE)
