
# skill

[知乎](https://zhuanlan.zhihu.com/p/270644625)

[vim-skill 插件](https://github.com/AugustUnderground/vim-skill)

## cadence skill函数接口

```text
Help -> User Guide -> 搜索任意函数即可查看，如 hiGetCurrentWindow
ICADVM/SKILL/SKILL_Language/Cadence_User_Interface_SKILL_Reference

也可通过 tools -> SKILL API Finder查看
```

## 基础

SKILL中大部分操作都要通过 **函数** 完成，但是也有 **对象** 概念，可以通过 **->** 访问对象属性

### 名词解释

* CIW(Command Interpreter Window): 启动Virtuoso图形界面之后首先出现的窗口

### 关键词

* [procedure](#procedure-syntax): 定义函数
* [let](#let-syntax): 定义局部变量，变量默认为全局变量

### 数据类型

```sh
; 创建变量
a = 'abc
type("abc")         ; string
type(a)             ; symbol
type('abc)          ; symbol
type(123)           ; fixnum
type(1.23)          ; flonum

; 内置变量
t                   ; 表示真，等同于 't
nil                 ; 表示假，等同于 'nil
```

#### 对象(通过嵌套函数实现)

```sh
a = 1
classOf(a)                  ; 获取对象对应class(funobj类型)
className(a)                ; 获取类名(string类型)
```

#### 类型转换

```sh
; string -> int
atoi("1")           ; 1
atoi("1.23")        ; 1
; int -> string

; string -> float
atof("1.23")        ; 1.23
aelNumber("1.23")   ; 1.23

; int/float/symbol/list -> string
artMakeString(123)              ; "123"
artMakeString(1.23)             ; "1.23"
artMakeString(1e-9)             ; "1e-9"
artMakeString('123)             ; "123"
artMakeString('(1 2.0 3))       ; "(1 2.0 3)"
artMakeString(nil)              ; "nil"
artMakeString(t)                ; "t"
; 还可以借助sprintf
sprintf(nil "%d" 123)           ; "123"
```

#### 列表

```sh
a = '()                 ; 空列表
a = '(1 2 3)            ; 不能引用变量
var = 4
b = list(var 5 6)       ; 可以引用变量
c = append(a b)         ; 合并列表，原列表不变
d = cons(b c)           ; 将b头插到c，原列表不变
e = append(c '(7))      ; 尾插元素，原列表不变

length(c)               ; 列表长度
car(c)                  ; 第一个元素
last(c)                 ; 最后一个元素
nth(n c)                ; 第 n 个元素
cdr(c)                  ; 相当于切片 [1:]
member(x c)             ; 如果列表中有x，从 x 位置切片，否则返回 nil
reverse(c)              ; 翻转，原列表不变
setof(x c 条件表达式)    ; 相当于python有条件表达式的列表推导
```

#### 数组

```sh
declare(arr[10])    ; 创建长度为10的数组
length(arr)         ; 获取数组长度

; 赋值
arr[0] = 0
arr[1] = 1
for(i 2 9
    arr[i] = arr[i - 1] + arr[i - 2]
)

; 遍历
for(i 0 9
    println(arr[i])
)
```

<a id='let-syntax'></a>

#### 局部变量(let)

```sh
; 只能在 let 作用域内访问局部变量
let((v1 v2)
    v1 = 1
    v2 = 2
    println("in let:")
    printf("%d, %d\n" v1 v2)
)
println("out let:")
printf("%d, %d\n" v1 v2)    ; 报错，不能访问局部变量

; 创建局部变量时赋值(默认为 nil)
let(((v1 1) v2 (v3 3))
    printf("%d, %A, %d\n" v1 v2 v3)     ; 1, nil 3
)
```

### 输出

```sh
; 格式化字符串类似于c的printf
; 更多格式参考 fprintf 的帮助文档
; %d: fixnum(int)
; %f: flonum(float)
; %s: string/symbol
; %n: fixnum/flonum
; %L: list
; %A: any

; printf/println: 输出到CIW，
x = 123.4
printf("x is %10.2f.\n" x)
println("one line message, auto change line")

; sprintf: 创建字符串
sprintf(a "num: %d" 1)              ; 自动创建变量a
b = sprintf(nil "num: %d" 2)        ; 赋值给变量
println(a)
println(b)
```

### 注释

```sh
; 单行注释
/* 多行注释 
 * 注释
 */
```

### 流程控制

[示例](./scripts/flow_control.il)

if, for, foreach, case, while, case, cond, return

<a id='procedure-syntax'></a>

#### 函数(procedure)

```sh
; procedure(func_name([arg_list, ]) statements)
; skill 自动 return 函数最后一个值
procedure(fibonacci(n)
    if( (n == 1 || n == 2) then
        1
    else
        fibonacci(n-1) + fibonacci(n-2)
    )
)
```

##### 实用函数

```sh
charToInt('B)   ; 66 ; 获取字符ascii码
int(1.2)        ; 1  ; 取整数部分
```

### 文件操作

[示例](./scripts/file.il)

## virtuoso接口

### window

[窗口操作](https://mp.weixin.qq.com/s/FpnKOkoc4nF5wCsDGvemjQ)

window 类型:

* session windows (**swindow**)
* dockable window (**dwindow**)
* windows (**window**)

```sh
; 每个窗口对应一个 id
# window_type: 'all, 'session, 'dockable, 'window. default: 'window
hiGetWindowList(window_type)
hiGetCurrentWindow() => w_windowId / nil    ; 获取当前窗口 id

# 获取window对象
id = 1
wobj = window(id)
wobj = swindow(id)
wobj = dwindow(id)

# 获取window title
hiGetWindowName(wobj)
hiGetWindowName(wobj)
hiGetWindowName(wobj)

# 缩放窗口
# 使用list坐标定义的矩形框全部位于window内 且上下或左右边与window边缘重合(window矩形框较长边)
hiZoomIn(hiGetCurrentWindow() list(0.9:1.0 0.1:0.1))
```

### 鼠标

```sh
; 使用相对位置移动光标（不是鼠标指针）
leMoveCursor(0.5 0.6)   # 向右移动0.5，向上移动0.6

mouseAddPt              # 记录鼠标左击位置
```

### 弹出窗口

[图形界面](./scripts/graphics_window.il)
[表单](./scripts/form.il)

自定义表单组件位置及尺寸

```sh
# 设置field参数时指定位置信息
# fldObjVar: 子组件变量
# x,y,width,height: 坐标及尺寸，单位为像素
# promptWidth: ?prompt信息宽度
?filed list(
    list(fldObjVar1 x:y width:height promptWidth)
    list(fldObjVar2 x:y2 width:height promptWidth)
)
```

### Layout

* dbOpenCellViewByType: 在内存中打开cell-view(重复调用为同一个对象)
* deOpenCellView: 打开cell-view图形窗口
* dbGetOpenCellViews: 获取所有内存中的cell-view
* geGetEditCellView: 获取正在编辑的cell-view(相当于geGetEditRep)
* geGetSelectedSet: 获取所有选中的图形对象(列表)

```il
; 只读模式打开layout cell-view
dbOpenCellViewByType("lib_name" "cell_name" "layout")

; 只读模式打开layout窗口
deOpenCellView("lib_name" "cell_name" "layout" "maskLayout" list(0:0 500:600) "a")
```

[创建形状](./scripts/create_shapes.il)

#### dbObject

不同dbObject对象有不同的属性，通过 -> 或 ~> 即可访问属性，通过下面的属性查看dbObject类型

```c
obj->objType        // 字符串，dbObject类型
```

通过 obj->? 或 obj~>? 可以列出所有属性名称

```sh
# 直接搜索 Attributes of Cellviews 即可
# 文档路径
$ICAD_DIR/SKILL/Virtuoso Design Environment SKILL Reference/Attribute Retrieval and Modification Database Access Functions/Attributes of Cellviews
```

instance属性

```c
obj->xy             // instance坐标原点，需要注意的是在virtuoso和gdspy中这个值并不一致
                    // 在 gdspy 或 calibredrv 中top cell的bbox起点都是(0, 0)，而 virtuoso 不是
```

rect属性

```c
obj->cellView       // 对象，所属CellView
obj->isShape        // 是否是图形
obj->bBox           // 矩形框((x1 y1) (x2 y2))
obj->layerName      // layer名称
```
