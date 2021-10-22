cd ../gem5
build/ARM/gem5.opt configs/example/fs.py \
--kernel ~/ChenRuiyang/gem5/full_system_images/binaries/vmlinux.arm64 \
--disk-image ~/ChenRuiyang/gem5/full_system_images/disks/ubuntu-18.04-arm64-docker.img \
--bootloader ~/ChenRuiyang/gem5/full_system_images/binaries/boot.arm64 --param "system.highest_el_is_64 = True" --cpu-type=DerivO3CPU \
--cpu-clock=3.1GHz --num-cpu 1 --caches --l2cache \
--l1i_size 64kB --l1d_size 64kB --l2_size 1MB --l1i_assoc 4 \
--l1d_assoc 4 --l2_assoc 4 --cacheline_size 128 \
--param 'system.sve_vl = 4' --script ~/ChenRuiyang/sh_command/run.sh
#--script ~/ChenRuiyang/sh_command/spmv.sh \
#build/ARM/gem5.opt configs/example/fs.py --kernel ~/ChenRuiyang/gem5/full_system_images/binaries/vmlinux.arm64 --disk-image ~/ChenRuiyang/gem5/full_system_images/disks/ubuntu-18.04-arm64-docker.img --bootloader ~/ChenRuiyang/gem5/full_system_images/binaries/boot.arm64 --param "system.highest_el_is_64 = True" --cpu-type AtomicSimpleCPU
