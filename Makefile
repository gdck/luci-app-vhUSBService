#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

# PAK NAME 必须和包所在文件夹一样.
PKG_NAME:=luci-app-vhUSBService

# 下面三个参数随便填写.
LUCI_PKGARCH:=all
PKG_VERSION:=2.0.2
PKG_RELEASE:=20210917

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
include $(INCLUDE_DIR)/package.mk

# 下面是显示在menuconfig中的菜单路径
# SUBMENU后面跟着的是我自己diy的一个菜单选项,
# 这个菜单里面全是自己的包,比较好找.
define Package/$(PKG_NAME)
 	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=VirtualHere USB Service for LuCI
	DEPENDS:=@(i386||x86_64||arm||mipsel)
	PKGARCH:=all
endef

# 包介绍说明,不要用中文.
define Package/$(PKG_NAME)/description
    This package contains LuCI configuration pages for VH USB Service.
endef

define Build/Prepare
endef

define Build/Compile
endef

ifeq ($(ARCH),x86_64)
	EXE_FILE:=vhusbdx86
endif
ifeq ($(ARCH),i386)
	EXE_FILE:=vhusbdx86
endif
ifeq ($(ARCH),mipsel)
	EXE_FILE:=vhusbdmipsel
endif
ifeq ($(ARCH),arm)
	EXE_FILE:=vhusbdarm
endif

# 安装作业
# 这里一般就是复制文件
# 如果有更多文件直接参考修改,非常简单.
define Package/$(PKG_NAME)/install

	# 两条命令一组
	# 第一条是指定复制到的目录
	# 第二条是拷贝文件.
 
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci
	#$(INSTALL_BIN) ./luasrc/* $(1)/usr/lib/lua/luci
   
	$(INSTALL_DIR) $(1)/
	cp -pR ./root/* $(1)/
	chmod 755 $(1)/etc/init.d/vhusbd
	#$(INSTALL_BIN) ./root/* $(1)/ 
  
	$(INSTALL_DIR) $(1)/usr/bin
	cp -pR ./bin/$(EXE_FILE) $(1)/usr/bin/vhusbd
	chmod 755 $(1)/usr/bin/vhusbd
	#$(INSTALL_BIN) ./bin/$(EXE_FILE) $(1)/usr/bin/vhusbd
 
endef

# preinst : 安装前执行 , 一般可以用来新建目录 ,
# 如果文件拷贝到一个不存在的目录会出错,所以有些需要安装前新建目录.或者处理一些文件冲突,将原来的文件备份
define Package/$(PKG_NAME)/preinst
	#!/bin/bash
	echo 'installing $(PKG_NAME)'
endef

# postinst : 安装完成执行 ,一般就是安装后给权限,或者直接启动.
# 安装后执行的脚本
# 这里大概作用就是安装后给./usr/bin/vhusbd添加执行权限.
define Package/$(PKG_NAME)/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Enabling rc.d symlink for $(PKG_NAME)"
    		chmod 755 /usr/bin/vhusbd >/dev/null 2>&1
     		chmod 755 /etc/init.d/vhusbd >/dev/null 2>&1
		/etc/init.d/vhusbd enable
	fi
	echo '$(PKG_NAME) installed successed !'
	exit 0
endef

# prerm : 卸载前执行
define Package/$(PKG_NAME)/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Removing rc.d symlink for $(PKG_NAME)"
		/etc/init.d/vhusbd disable
	fi
	echo 'removeing $(PKG_NAME)'
	exit 0
endef

#postrm : 卸载完成执行
define Package/$(PKG_NAME)/postrm
	#!/bin/bash
	echo '$(PKG_NAME) remove successed !'
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

# call BuildPackage - OpenWrt buildroot signature
