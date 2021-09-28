cd ../gem5
build/ARM/gem5.opt configs/example/fs.py --kernel ~/ChenRuiyang/gem5/full_system_images/binaries/vmlinux.arm64 --disk-image ~/ChenRuiyang/gem5/full_system_images/disks/ubuntu-18.04-arm64-docker.img --bootloader ~/ChenRuiyang/gem5/full_system_images/binaries/boot.arm64 --param "system.highest_el_is_64 = True" --cpu-type AtomicSimpleCPU
