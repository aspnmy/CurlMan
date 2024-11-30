# CurlMan
Curl 批量拨测工具,能过正确返回被测域名的网站首页代码,如果约定了监控关键词,就可以正确识别所有权

## 使用说明

### 1、简单批量拨测：
- 首先将需要拨测的网站域名保存成urls.txt,结构如下
```
www.baidu.com
www.google.com
www.example.com
```

- 然后在你的服务器下运行下面这个代码,记得使用root权限,运行前确保已经安装了curl组件

```
curl -sSL https://raw.githubusercontent.com/aspnmy/CurlMan/refs/heads/master/CurlMan.sh -o CurlMan.sh  && bash CurlMan.sh
```

- 运行脚本后会保存一个logs文件,文件中能正确显示网站代码的为正确拨测

### 2、关键词批量拨测：
- 首先你先在自己的网站首页中插入一个约定的关键词

- 使用下面的脚本运行拨测脚本主体,生成一个CurlMan.logs的文件
```
curl -sSL https://raw.githubusercontent.com/aspnmy/CurlMan/refs/heads/master/CurlManMaster.sh -o CurlManMaster.sh  && bash CurlManMaster.sh
```
- 然后按下面的命令运行日志验证脚本(Verify_CurlManlogs.sh),会自动对日志中的关键词进行提取,生成一个url 一个关键词的列表,代表是正确测通的域名
```
curl -sSL https://raw.githubusercontent.com/aspnmy/CurlMan/refs/heads/master/Verify_CurlManlogs.sh -o Verify_CurlManlogs.sh  && bash Verify_CurlManlogs.sh
```