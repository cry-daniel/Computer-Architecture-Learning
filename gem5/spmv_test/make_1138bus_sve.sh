sudo rm spmv_c_example.o
echo "Compiling program spmv_c_example.c:"
sudo aarch64-linux-gnu-gcc-10  -c -I/home/fugelin/Tools/arm/armpl_21.0_gcc-10.2/include -std=c11 -march=armv8-a+sve -I ~/gem5/include spmv_c_example.c -o spmv_c_example.o
echo "Compiling program spmv_c_example.o done!"
sudo rm spmv_1138bus_sve.exe
echo "Linking program spmv_c_example.exe:"
sudo aarch64-linux-gnu-gcc-10  -I/home/fugelin/Tools/arm/armpl_21.0_gcc-10.2/include -L ~/gem5/util/m5/build/aarch64/out spmv_c_example.o -L ~/gem5/util/m5/build/aarch64/out -lm5 -L/home/fugelin/Tools/arm/armpl_21.0_gcc-10.2/lib -larmpl_lp64 -lgfortran -lm -static -o spmv_1138bus_sve.exe
echo "Done making spmv_1138bus_sve.exe!"
