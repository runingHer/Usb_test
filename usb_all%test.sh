#!/usr/bin/bash
#usb功能性能测试

read -p "请输入U盘盘符名称(例：/dev/sdb)" usb_name
#检测U盘状态
mount_path=$(df -h | grep $usb_name | awk '{print $NF}')
if [ -n "$mount_path" ]; then
  umount $usb_name
fi
#创建挂载目录
if [ ! -d usb_mount_test ]; then
  mkdir usb_mount_test
fi

#挂载测试
mount_test() {
  mount $usb_name usb_mount_test
  if [ $? = 0 ]; then
    echo -e "\033[\e[1;32m 挂载U盘成功! \033[0m"
    dd if=/dev/zero of=usb_mount_test/3G.txt bs=1M count=3000
    if [ $? = 0 ]; then
      echo -e "\033[\e[1;32m U盘中写入10G文件成功! \033[0m"
      sleep 2
      cp usb_mount_test/10G.txt /home
      if [ $? = 0 ]; then
        echo -e "\033[\e[1;32m U盘文件已拷贝至/home成功! \033[0m"
        sleep 2
        rm -rf usb_mount_test/10G.txt
        echo -e "\033[\e[1;32m U盘文件删除成功! \033[0m"
        if [ $? = 0 ]; then
          sleep 2
          cp /home/10G.txt usb_mount_test/
          if [ $? = 0 ]; then
            echo -e "\033[\e[1;32m 拷贝系统文件到U盘成功! \033[0m"
            rm -rf usb_mount_test/10G.txt
          fi
        fi
      fi
    else
      echo -e "\033[31m 写入文件失败，请校验! \033[0m"
      exit 0
    fi
  else
    echo "挂载失败！"
    echo "U盘文件系统格式可能错误，你可以使用mkfs.xfs -f ${usb_name}来格式化它"
    exit 0
  fi
}
#读写性能测试
performance_test() {
  dd if=$usb_name of=/dev/null bs=1M count=3000
  if [ $? = 0 ]; then
    echo -e "\033[\e[1;32m U盘读取性能测试完成! \033[0m"
    dd if=/dev/zero of=usb_mount_test/3G.txt bs=1M count=3000
    if [ $? = 0 ]; then
      echo -e "\033[\e[1;32m U盘写入性能测试完成! \033[0m"
    fi
  fi
}
mount_test
performance_test
if [ $? = 0 ]; then
  echo -e "\033[\e[1;32m U盘测试已完成，请记录测试数据! \033[0m"
fi