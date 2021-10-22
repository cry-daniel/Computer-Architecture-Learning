cd /arm/armpl_21.0_gcc-10.2/test/source
m5 checkpoint
m5 resetstats
m5 readfile > /tmp/gem5.sh && sh /tmp/gem5.sh
m5 exit
