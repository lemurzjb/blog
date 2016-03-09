---
title: 安装试用Docker DataCenter(DDC)
toc: true
date: 2016-03-09 20:56:01
tags:
  - Docker
  - Docker Datacenter
category: 配置管理
---
Docker Datacenter(DDC)正式推出已经有段时间，趁现在她还提供30天的免费试用，所以申请了一个把玩把玩。听名字一直因为是个公有云服务平台，类似阿里云那样的，其实她是提供一套软件帮助客户搭建各自的似有云平台，好似OpenStack。她包括三个收费的模块：1）Docker Universal Control Plane(Docker UCP)，这是套图形化管理界面；2)Docker Trusted Registry（DTR），授信的Docker镜像仓库；3)收费版的Docker Engine，提供技术支持的Docker引擎。
### 安装
我们会新建3个virtualbox的虚拟机，一个作为DTR，一个UCP的controller，另一个是UCP的replica，其中DTR的虚拟机我们分配了512M内存，而UCP的虚拟机给1.5G的内存。
![虚拟机分配](/content/images/2016/03/dist.jpg)
我们通过vagrant来管理这些虚拟机，喜欢docker的同学也会喜欢vagrant，他们的初衷是类似的。
#### 申请30天免费试用
首先需要一个Docker Hub的帐号，可以免费申请。申请好账户，可以自动获得一个免费的似有镜像仓库。然后就可以去https://hub.docker.com/enterprise/trial 申请免费试用。填写你的相关信息后提交就可以了。接下来就是安装三大件Docker引擎，DTR，UCP。为了安装多个引擎的节点而我又没这么多的电脑，只好安装在virtualbox的虚拟机中了。
#### 安装收费版的引擎
在提交免费试用申请表单之后，出现的页面提供两组命令（分别适用于红帽系或DEB系的系统）用户安装收费版本的引擎，如下图所示。
![安装收费版本Doker引擎](/content/images/2016/03/Install-CS-Engine.png)
不用担心这两组命令会消失，他们最终会出现在你的账户设置（settings）页面，包括30天试用的证书文件。我们需要在3台虚拟机中都安装引擎。
#### 安装DTR
安装DTR比较简单，她已经为你提供一个命令，直接运行就可以。别看命令就一个，她可干了好多事情，光光docker镜像文件就下载了7,8个。其实DTR和UCP就是几个封装好的镜像文件。
![安装DTR和UCP](/content/images/2016/03/Install-DTR-UCP.png)
安装完就可以通过http://xxx.xxx.xxx.xxx 来访问DTR的管理界面，如下图所示。
![DTR-仪表盘](/content/images/2016/03/DTR-dashboard.png)
由于我们还没有导入试用的证书文件，页面右下角会提示当前拷贝未授权，接下来我们要导入刚申请的试用证书。先登陆Docker Hub，个人设置->license菜单项下面，可以看到下面的内容，点击其中圈中的位置就可以下载证书文件，之后导入到DTR中就完成授权。
![下载证书文件](/content/images/2016/03/download-license.png)
#### 安装UCP
首先安装UCP Controller，虚拟机VM2中输入下面命令：
``` bash
sudo docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock --name ucp docker/ucp install --host-address xxx.xxx.xxx.xxx
```
安装程序先检查系统是否兼容UCP，之后就是等待，大概几分钟后（根据网络情况可能会有差异）提示安装成功。现在可以通过浏览器访问VM2的ip地址（需要https）登陆UCP的控制界面，输入用户admin/orca登入。马上又会提示当前系统是未授权的需要上传许可证书文件。把之前下载的许可文件上传之后就可以快乐的玩耍了。
![UCP仪表盘](/content/images/2016/03/ucp-dashboard.png)
然后安装UCP的replica，并加入UCP的集群，在VM3中执行下面指令：
``` bash
sudo docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock --name ucp docker/ucp join -i --host-address xxx.xxx.xxx.xxx
```
程序提示输入UCP controller的URL，输入https://xxx.xxx.xxx.xxx (UCP controller的ip地址)，后面询问是否相信这个服务器并且继续加入UCP的集群时，输入y然后回车。后面接着需要输入UCP的管理员用户和密码，即我们之前登陆UCP的用户密码（admin/orca），同样等待几分钟后就提示输入"Additional aliases"，我们直接敲回车即可。回头我们在来看UCP的仪表盘，这时候Nodes数量已经变为2了。
![UCP仪表盘2](/content/images/2016/03/ucp-dashboard2.png)
到此为止，安装过程就结束了。注意到我们的DTR节点并没有自动出现在UCP的仪表盘，接下来我们要研究下如何将其他的Docker引擎节点也加入到UCP的管理之下。
### 玩转Docker Datacenter（DDC）
