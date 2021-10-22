export object=spmv_1138bus

sudo rm ${object}.o
sudo rm ${object}_none.exe
echo "Compiling program ${object}.c:"
sudo aarch64-linux-gnu-gcc-10  -c -I/home/fugelin/Tools/arm/armpl_21.0_gcc-10.2/include -std=c11 -march=armv8-a+nosimd -I ~/gem5/include ${object}.c -o ${object}.o
echo "Compiling program ${object}.o done!"
echo "Linking program ${object}.exe:"
sudo aarch64-linux-gnu-gcc-10  -I/home/fugelin/Tools/arm/armpl_21.0_gcc-10.2/include -L ~/gem5/util/m5/build/aarch64/out ${object}.o -L ~/gem5/util/m5/build/aarch64/out -lm5 -L/home/fugelin/Tools/arm/armpl_21.0_gcc-10.2/lib -larmpl_lp64 -lgfortran -lm -static -o ${object}_none.exe
echo "Done making ${object}_none.exe!"

sudo rm ${object}.o
sudo rm ${object}_sve.exe
echo "Compiling program ${object}.c:"
sudo aarch64-linux-gnu-gcc-10  -c -I/home/fugelin/Tools/arm/armpl_21.0_gcc-10.2/include -std=c11 -march=armv8-a+sve -I ~/gem5/include ${object}.c -o ${object}.o
echo "Compiling program ${object}.o done!"
echo "Linking program ${object}.exe:"
sudo aarch64-linux-gnu-gcc-10  -I/home/fugelin/Tools/arm/armpl_21.0_gcc-10.2/include -L ~/gem5/util/m5/build/aarch64/out ${object}.o -L ~/gem5/util/m5/build/aarch64/out -lm5 -L/home/fugelin/Tools/arm/armpl_21.0_gcc-10.2/lib -larmpl_lp64 -lgfortran -lm -static -o ${object}_sve.exe
echo "Done making ${object}_sve.exe!"

sudo rm ${object}.o 
sudo rm ${object}_simd.exe
echo "Compiling program ${object}.c:"
sudo aarch64-linux-gnu-gcc-10  -c -I/home/fugelin/Tools/arm/armpl_21.0_gcc-10.2/include -std=c11 -march=armv8.3-a+simd -I ~/gem5/include ${object}.c -o ${object}.o
echo "Compiling program ${object}.o done!"
echo "Linking program ${object}.exe:"
sudo aarch64-linux-gnu-gcc-10  -I/home/fugelin/Tools/arm/armpl_21.0_gcc-10.2/include -L ~/gem5/util/m5/build/aarch64/out ${object}.o -L ~/gem5/util/m5/build/aarch64/out -lm5 -L/home/fugelin/Tools/arm/armpl_21.0_gcc-10.2/lib -larmpl_lp64 -lgfortran -lm -static -o ${object}_simd.exe
echo "Done making ${object}_simd.exe!"
