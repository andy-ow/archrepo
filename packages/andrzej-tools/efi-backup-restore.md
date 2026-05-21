# Restoring EFI partition from efi-backup

This package creates compressed images of the whole EFI System Partition.

Default backup location:

    /home/andrzej/Backup/efi-images

Typical files:

    efi-dom6-2026-05-21_120000.img.zst
    efi-dom6-2026-05-21_120000.img.zst.sha256

## 1. Check which EFI partition should be restored

Check current EFI mount:

    findmnt /efi

Check block devices:

    lsblk -f

Expected source from `/etc/andrzej-tools.conf` may look like:

    EFI_BACKUP_SRC="/dev/disk/by-uuid/6ABC-85A1"

For restoring, you need the target partition, for example:

    /dev/disk/by-uuid/6ABC-85A1

Be very careful. The restore command overwrites the target partition.

## 2. Verify backup checksum

    cd /home/andrzej/Backup/efi-images
    sha256sum -c efi-dom6-YYYY-MM-DD_HHMMSS.img.zst.sha256

## 3. Unmount EFI before restoring

    sudo umount /efi

If it is busy:

    sudo fuser -vm /efi

## 4. Restore image

Replace the filename and target device carefully:

    zstdcat /home/andrzej/Backup/efi-images/efi-dom6-YYYY-MM-DD_HHMMSS.img.zst \
      | sudo dd of=/dev/disk/by-uuid/6ABC-85A1 bs=4M status=progress conv=fsync

WARNING: `dd of=...` overwrites the target immediately.

## 5. Mount EFI again

    sudo mount /efi
    findmnt /efi
    ls -la /efi

## 6. Optional sanity checks

    sudo efibootmgr -v

If boot entries are missing, recreate them using your bootloader instructions.