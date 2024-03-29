
# RVE

Result Viewing Environment: 查看 calibre 生成的 results database.

doc: Physical Verification -> **Calibre RVE User's Manual**

## 用法

```sh
# 打开界面后点击 RVE, 选择要查看的文件即可
calibre -gui
```

### 在 calibredrv / virtuoso 中高亮

搜索: **Connection to a Design Tool**

方式一

1. 在 virtuoso 中打开对应的 gds
2. 菜单栏 Calibre -> Start RVE
3. 打开要查看的 results database 文件
4. 选中要查看的点，右键点击高亮
5. 点击左上角 Clear All Highlights 清除所有高亮

方式二

1. 在 calibredrv 中打开对应 gds
2. 菜单栏 Verification -> Start RVE

方式三

1. 在 virtuoso 中打开对应的 gds
2. 打开要查看的 results database 文件
3. 检查 calibre 界面右下角是否显示为已连接，未连接可手动连接

修改高亮设置，使高亮结果看起来更明显，highlight layer 为 y0 - y10

1. virtuoso 中右键 layers 所在菜单栏
2. 点击 Edit Display Resource
3. 搜索 y0 - y10，line style 选择粗线条
4. 点击右下角 Modify Current Package 确认修改
