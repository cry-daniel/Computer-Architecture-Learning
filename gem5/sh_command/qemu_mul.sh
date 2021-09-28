qemu-system-aarch64 -m 2048 -cpu cortex-a57 \
-smp 4 -M virt -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd \
-nographic -device virtio-scsi-device \
-drive if=none,file=../gem5/full_system_images/disks/ubuntu-18.04.img,id=hd0 \
-device virtio-blk-device,drive=hd0 \
-drive \
if=none,file=../gem5/full_system_images/disks/ubuntu-18.04-arm64-docker.img,id=hd1 \
-device virtio-blk-device,drive=hd1

