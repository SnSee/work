
# virtuoso

启动

```sh
# 需要在启动目录下有 cds.lib 文件定义库配置
bsub virtuoso

# 初始化执行自定义代码(skill)
echo 'cmd' >> ~/.cdsinit

# Tools -> Library Manager 打开库管理器
```

快捷键

```text
shift + S: 查找, search for选项选择查找类型
k        : 测量距离
f        : 自动缩放当前版图为合适大小
```

导入view

```text
gds: File -> Import -> Stream
    Stream File: 要导入的gds文件
    Library: 要导入到哪个库
    Technology->Attach Tech Library: 相关tech库，一般在cds.lib中会设置好

cdl: File -> Import -> Spice
    Input:
        Netlist File: 要导入的cdl网表
        Netlist Language: 网表类型
        Reference Library List: 引用了哪些库, 空格分割（cdl中可能引用了其他库中定义的网表）
    Output:
        Output Library: 要导入到哪个库
```

导出view

```text
gds: File -> Export -> Stream
    Stream File: 要导出的gds文件
```

> Layout 窗口

最下方状态栏显示三项：

* 鼠标
* 回调函数(skill)
* TODO

## SKILL
