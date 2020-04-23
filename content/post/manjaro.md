---
title: "Manjaro 桌面使用"
description: "Manjaro linux安装后配置"
tags: [ "Liunx基础"]
categories: [ "Liunx", "Liunx" ]
keywords: [ "Manjaro", "桌面" ]
date: 2018-04-06
lastmod: 2019-12-23
---

## manjaro 桌面使用

### 桌面安装

manjaro KDE ISO 镜像下载地址： [下载](https://manjaro.org/download/official/kde/)

U盘刻入工具：[下载](https://rufus.en.softonic.com/)

### 桌面配置

1. 安装搜狗输入法

   ``` shell
   # 安装软件包
   sudo pacman -S --noconfirm fcitx-im kcm-fcitx fcitx-sogoupinyin
   # 配置环境变亮
   vim ~/.xprofile
   export GTK_IM_MODULE=fcitx
   export QT_IM_MODULE=fcitx
   export XMODIFIERS="@im=fcitx"
   # 重启系统
   ```


2. 安装虚拟机环境vagrant + virtualbox

   ```shell
   sudo pacman -S vagrant virtualbox
   ```

3. 安装sublime3

   ```shell
   # 导入gpg密钥
   curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
   # 添加源到配置文件
   curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
   # 安装
   sudo pacman -Syu sublime-text
   ```

   