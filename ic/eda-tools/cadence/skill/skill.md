
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

```skill
a = 1
classOf(a)                  ; 获取对象对应class(funobj类型)
className(a)                ; 获取类名(string类型)

get(val 'name)              ; 根据名称获取对象属性(getattr)
setq(val "new-value")       ; 设置值

dbSetq, dbSet
```

##### 打印对象成员

```skill
foreach(attrname obj->?
    printf("%s: %A\n" attrname get(obj attrname))
)
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

#### if, for 等

[示例](./scripts/flow_control.il)

if, for, foreach, case, while, case, cond, return

#### 逻辑运算符

* 或: ||
* 与: &&
* 非: !

<a id='procedure-syntax'></a>

#### 函数(procedure)

##### 定义函数

```skill
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

##### 调用函数

```skill
; 按位置传参
fibonacci(10)

; 按形参名称传参
fibonacci(?n 10)
```

##### 实用函数

```sh
charToInt('B)   ; 66 ; 获取字符ascii码
int(1.2)        ; 1  ; 取整数部分
```

### 文件操作

[示例](./scripts/file.il)

## virtuoso 接口

### virtuoso 函数

#### 函数前缀含义

| 前缀 | 含义
|- |-
|hi     | human interface 大多是打开交互窗口(最顶层的函数，不会被其他内置函数调用)
|le     | layout editor
|ge     | graphics editor
|sch    | schematic
|schHi  | schematic editor human interface

#### 函数接口中标识符含义

文档: SKILL / Virtuoso Layout Suite SKILL Reference / Preface

Identifiers Used to Denote Data Types

常用的几个标识符含义:

|Prefix | Internal Name | Data Type
|- |- |-
|a      | array         | array
|e      | envobj        | environment
|f      | flonum        | floating-point number
|h      | hdbobject     | hierarchical database configuration object
|l      | list          | linked list
|n      | number        | integer or floating-point number
|s      | symbol        | symbol
|S      | stringSymbol  | symbol or character string
|t      | string        | character string (text)
|u      | function      | function object, either the name of a function (symbol) or a lambda function body (list)
|U      | funobj        | function object
|w      | wtype         | window type
|sw     | swtype        | subtype session window
|dw     | dwtype        | subtype dockable window
|x      | integer       | integer number
|y      | binary        | binary function
|&      | pointer       | pointer type

#### 查找函数

方式一: 界面查找 Tools -> SKILL API Finder

方式二: 通过函数查找，如查找 schematic 和 Property 相关函数

```skill
; 使用正则表达式
listFunctions("^sch.*Prop")
```

#### 查看函数信息

方式一: 在 Finder 中查找后双击或点击 More Info
方式二: 在 Help 界面直接搜索
方式三: CIW 中执行 help function_name

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

#### 常用函数

##### CellView

| function | description
|- | -
| dbOpenCellViewByType  | 在内存中打开cellView(重复调用为同一个对象)
| dbSave                | 保存 cellView
| dbClose               | 关闭 cellView
| deOpenCellView        | 打开 cellView 图形窗口
| dbGetOpenCellViews    | 获取所有内存中的 cellView
| geGetEditCellView     | 获取正在编辑的 cellView (相当于geGetEditRep)

```il
; 只读模式打开layout cell-view
dbOpenCellViewByType("lib_name" "cell_name" "layout")

; 只读模式打开layout窗口
deOpenCellView("lib_name" "cell_name" "layout" "maskLayout" list(0:0 500:600) "a")
```

##### Selection

文档: SKILL Reference / Graphics Editor Functions / **Selection Functions**

**figure**: 用于表示布局编辑器中的图形对象, 可以是布局中的任何元素，如 inst, label 等。

| function | description
|- | -
| geSelectAllFig        | 选中 cellView 中所有对象
| geGetSelectedSet      | 获取所有选中的图形对象(列表)
| geSelectFigs          | 选中 figure list
| geSelectObject        | 选中 dbObject (需要有 figGroup 属性?)

```c
; 选中第一个 instance
geSelectObject(car(cellView->instances))

; 选中第一个 pin
geSelectFigs(car(cellView->signals)->figs)
```

[创建形状](./scripts/create_shapes.il)

#### dbObject

不同dbObject对象有不同的属性，通过 -> 或 ~> 即可访问属性，通过下面的属性查看dbObject类型

* 通过函数获取/设置 dbObject 值: dbGet/dbGetq, dbSet/dbSetq

```c
obj->objType        // 字符串，dbObject类型
obj->bBox           // 矩形框((x1 y1) (x2 y2))
```

通过 obj->? 或 obj~>? 可以列出所有属性名称

[打印所有成员](#打印对象成员)

```sh
# 直接搜索 Attributes of Cellviews 即可
# 文档路径
$ICAD_DIR/SKILL/Virtuoso Design Environment SKILL Reference/Attribute Retrieval and Modification Database Access Functions/Attributes of Cellviews
```

##### cellView

```c
obj->cellName       // cell 名称
obj->cell           // cell 对象
obj->cellType       // cell 类型
obj->sigNames       // pin 名称
obj->signals        // pin 对象
obj->instances      // instance 对象
obj->nets           // instance 间连线对象
```

##### instance

```c
obj->xy             // instance坐标原点，需要注意的是在virtuoso和gdspy中这个值并不一致
                    // 在 gdspy 或 calibredrv 中top cell的bbox起点都是(0, 0)，而 virtuoso 不是
```

修改 instance 引用的 lib 和 cell

```skill
leReplaceAnyInstMaster(inst "libName" "cellName" "viewName")
```

##### rect

```c
obj->cellView       // 对象，所属CellView
obj->isShape        // 是否是图形
obj->layerName      // layer名称
```

### Schematic

schematic 中特有的函数以 **sch** 开头

| function | description
|-  |-
| schHiObjectProperty   | 打开选中的图形属性窗口，相当于快捷键 q，打开后界面对象会自动赋值到 schObjPropFrom 变量
| schReplaceProperty    | 修改 schematic 中对象值
