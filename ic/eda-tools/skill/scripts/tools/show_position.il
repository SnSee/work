;; 弹出窗口设置坐标点，显示指定坐标位置并自动缩放到合适尺寸

procedure(myShowPositionForm()
    xPos = hiCreateStringField(
        ?name 'xPos
        ?prompt "x"
        ?defValue "0.01"
        ?editable t
    )
    yPos = hiCreateStringField(
        ?name 'yPos
        ?prompt "y"
        ?defValue "0.01"
        ?editable t
    )
    rulerSize = hiCreateStringField(
        ?name 'rulerSize
        ?prompt "ruler Size"
        ?defValue "0.01"
        ?editable t
    )

    if(!boundp('gShowPosForm) || (gShowPosForm == nil) then
        gShowPosForm = hiCreateAppForm(
            ?name 'gShowPosForm
            ?fields list(
                list(xPos 10:10 100:20 10)
                list(yPos 120:10 100:20 10)
                list(rulerSize 240:10 120:20 50)
            )
            ?formTitle "Show Position"
            ?callback "myShowPositionFormCallback()"
            ?buttonLayout 'OKCancel
        )
    )
    hiDisplayForm('gShowPosForm)
)

procedure(myShowPositionFormCallback()
    let(((form gShowPosForm) x1 y1 x2 y2 rulerSize w cv xm ym)
        x1 = atof(form->xPos->value)
        y1 = atof(form->yPos->value)
        rulerSize = atof(form->rulerSize->value)
        x2 = x1 + rulerSize
        y2 = y1 + rulerSize
        w = hiGetCurrentWindow()
        cv = geGetEditCellView(w)
        dbCreateRuler(cv list(x1:y1 x1:y2))
        dbCreateRuler(cv list(x1:y1 x2:y1))
        xm = x1 - 2 * rulerSize
        ym = y1 - 2 * rulerSize
        hiZoomIn(w list(xm:ym xm+5*rulerSize:ym+5*rulerSize))
    )
)
