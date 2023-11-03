
win = hiGetCurrentWindow()
cv = geGetEditCellView(win)
layer = list("M2" "drawing")

; 创建矩形
rect = dbCreateRect(cv layer list(x1:y1 x2:y2))
; 选中对象
geSelectObject(rect)

; 标尺
dbCreateRuler(cv list(x1:y1 x2:y2))

; blockage object
; "M1"是layer名称，也可以是对应的数字
dbCreateLayerBlockage(cv "M1" "routing" list(x1:y1 x2:y1 x2:y2 x1:y2))
