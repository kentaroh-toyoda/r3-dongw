xubuntos@xubuntos-tinyos:/mnt/hgfs/D/code/r2/Blink-base$ make telosb
mkdir -p build/telosb
    compiling BlinkAppC to a telosb binary
ncc -o build/telosb/main.exe  -Os -O -fnesc-separator=__ -mdisable-hwmul -Wall -Wshadow -Wnesc-all -target=telosb -fnesc-cfile=build/telosb/app.c -board= -DDEFINED_TOS_AM_GROUP=0x22 -DIDENT_APPNAME=\"BlinkAppC\" -DIDENT_USERNAME=\"xubuntos\" -DIDENT_HOSTNAME=\"xubuntos-tinyos\" -DIDENT_USERHASH=0x00f95284L -DIDENT_TIMESTAMP=0x4dbd49d3L -DIDENT_UIDHASH=0x18aba031L  BlinkAppC.nc -lm 
    compiled BlinkAppC to build/telosb/main.exe
            2650 bytes in ROM
              54 bytes in RAM
msp430-objcopy --output-target=ihex build/telosb/main.exe build/telosb/main.ihex
    writing TOS image
xubuntos@xubuntos-tinyos:/mnt/hgfs/D/code/r2/Blink-base$ msp430-size build/telosb/main.exe 
   text    data     bss     dec     hex filename
   2680       2      52    2734     aae build/telosb/main.exe
xubuntos@xubuntos-tinyos:/mnt/hgfs/D/code/r2/Blink-base$ msp430-size build/telosb/main.ihex 
   text    data     bss     dec     hex filename
      0    2682       0    2682     a7a build/telosb/main.ihex


From ELF (readelf)
data=2
bss=52
vectors=32
text=2648

tinyos make系统report的数据
ROM=text + data
RAM=data + bss

msp430-size main.exe的text包含了text和vectors

msp430-size main.ihex为text+vectors+data，即不包含bss

raw格式:
一个section为
address (4 bytes), size (4 bytes), data

最后加8个0.
0x4000, 2650, data
0xffe0, 32, data
8个0
