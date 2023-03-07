#!/bin/sh
#----------------------------------------------------------------
# Shell Name：axinstall
# Description：Plug-in install script
# Author：axins
# Version: 1.0.1
# Setup Address: axinsinstall.sh
#----------------------------------------------------------------*/
clear

echo ""

echo "-------------------"
echo '     ___  ___   _  '
echo '    /   |/   | | | '
echo '   / /|   /| | | | '
echo '  / / |__/ | | | | '
echo ' / /       | | | | '
echo '/_/        |_| |_| '
echo "-------------------"

version="1.0.1"

echo "★欢迎使用小米路由器工具箱 AX9000版★"
echo "当前版本："$version
echo "此版本无人制作，来源网络"
echo "问题反馈&交流QQ群：134374534"

## Check The Router Hardware Model
model=$(cat /proc/xiaoqiang/model)

if [ "$model" == "AX3000" -o "$model" == "AX6000" -o "$model" == "RA70" ];then
	echo "本工具箱仅为交流学习使用，请勿用于非法用途！"
else
	echo "对不起，本工具箱暂时不支持您的路由器型号。"
	exit
fi

echo -n "[请根据提示输入，按Ctrl+C 退出]:"
while :
do
	echo "1，安装asins      2，卸载asins"
	read location
	if [ "$location" == '1' ] ;then
        #
	 	break
	 elif [ "$location" == '2' ] ; then
        exit
	 	break
	fi
done
read continue

mount -o remount,rw /

if [ "$model" == "AX3000" -o "$model" == "AX6000" ];then
        MIWIFIPATH="/etc"
elif [ "$model" == "RA70" ];then
        if [ $(df|grep -Ec '\/extdisks\/sd[a-z][0-9]?$') -eq 0 ];
        then
                MIWIFIPATH="/etc"
        else
        		echo "检测到外部存储，请选择安装位置："
        		while :
        		do
        			echo "1，内置存储(推荐)      2，U盘/移动硬盘（如果内置存储满，请选择这个）"
        			read location
        			if [ "$location" == '1' ] ;then
               		 	MIWIFIPATH="/etc"
               		 	break
               		 elif [ "$location" == '2' ] ; then
               		 	MIWIFIPATH=$(df|awk '/\/extdisks\/sd[a-z][0-9]?$/{print $6;exit}')
               		 	break
                	fi
                done
        fi
else
        echo "暂不支持您的路由器。"
        return 1
fi

rm -rf $MIWIFIPATH/axins
mkdir $MIWIFIPATH/axins
rm -rf /tmp/axinstmp
mkdir /tmp/axinstmp

if [ "$MIWIFIPATH" != "/etc" ]; then
	rm -rf /etc/axins
	ln -s $MIWIFIPATH/axins /etc/
fi

echo "检查磁盘空间。.."

result=$(df -h | grep -E 'etc' | grep '100%' | wc -l)
if [ "$result" == '0' ];then
	echo "完成"
else
	df -h | grep -E 'etc'
	echo "磁盘空间不足，请清理后安装。"
	exit
fi

mount -o remount,rw /

if [ $? -eq 0 ];then
    echo "挂载文件系统成功。"
else
    echo "挂载文件系统失败，正在退出..."
    exit
fi

if [ ! -f "ax9000.ax" ];then
	echo "安装包文件不存在。"
	exit
	else
	cp -rf ax9000.ax /tmp/axinstmp/ax9000.ax
fi

#echo "开始下载安装包..."
#url="下载链接"
#wget ${url}/ax9000.ax -O /tmp/axinstmp/ax9000.ax
#
#if [ $? -eq 0 ];then
#    echo "安装包下载完成！"
#else
#    echo "下载安装包失败，正在退出..."
#    exit
#fi

echo "开始解压程序..."

tar -xvf /tmp/axinstmp/ax9000.ax -C / >/dev/null 2>&1

if [ $? -eq 0 ];then
    echo "解压完成，开始安装："
else
    echo "解压失败，正在退出..."
    exit
fi

chmod +x /etc/axins/scripts/*

/etc/axins/scripts/axinsinstall

if [ $? -eq 0 ];then
    snmd5=$(echo `nvram get wl1_maclist` `nvram get SN`  | md5sum | awk '{print $1}')
    uci set axins.axins.counter=$snmd5
    uci commit axins
    echo -e "MD5:"$snmd5""
    echo -e "安装完成，请刷新网页。"
else
    echo "安装失败。"
    exit
fi

rm -rf /tmp/axinstmp
