#!/bin/bash
echo 磁盘情况查看
fdisk -l

# 从用户获取磁盘分区设备名称
read -p "请输入要挂载的磁盘分区设备名称（例如 /dev/vdb1）: " disk_device

# 检查设备是否存在
if [ ! -e "$disk_device" ]; then
    echo "错误：指定的磁盘分区设备 $disk_device 不存在。"
    exit 1
fi

# 从用户获取挂载点目录
read -p "请输入要挂载到的目录（默认为 /data）: " mount_point

# 如果用户没有输入挂载点目录，则使用默认值
if [ -z "$mount_point" ]; then
    mount_point="/data"
fi

# 检查挂载点是否已存在，如果不存在则创建
if [ ! -d "$mount_point" ]; then
    sudo mkdir -p "$mount_point"
fi

# 检查设备是否已经挂载
if grep -qs "$disk_device" /proc/mounts; then
    echo "磁盘分区 $disk_device 已经挂载。"
    exit 1
fi

#磁盘分配
fdisk $disk_device \n \p \1 \w
mkfs.ext4 $disk_device

# 挂载磁盘分区
sudo mount "$disk_device" "$mount_point"

# 检查挂载是否成功
if [ $? -eq 0 ]; then
    echo "磁盘分区 $disk_device 成功挂载到 $mount_point。"
else
    echo "挂载磁盘分区 $disk_device 到 $mount_point 失败。"
fi

#持久化
echo $disk_device $mount_point ext4 defaults 0 0 >> /etc/fstab

echo "磁盘挂载情况"
df -h
