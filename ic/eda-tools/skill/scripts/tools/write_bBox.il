;; 输出当前cell_view的所有bBox到文件或CIW

procedure(myWriteBBoxForm()
    outFile = hiCreateStringField(
        ?name 'outFile
        ?prompt "output"
        ?defValue ""
        ?editable t
    )
    if(!boundp('gWriteBBoxForm) || (gWriteBBoxForm == nil) then
        gWriteBBoxForm = hiCreateAppForm(
            ?name 'gWriteBBoxForm
            ?fields list(outFile)
            ?formTitle "Write BBox"
            ?callback "myWriteBBoxFormCallback()"
            ?buttonLayout 'OKCancel
        )
    )
    hiDisplayForm('gWriteBBoxForm)
)

procedure(myWriteBBoxFormCallback()
    let(((form gWriteBBoxForm) w cv)
        w = hiGetCurrentWindow()
        cv = geGetEditCellView(w)
        foreach(obj geGetSelectedSet(cv)
            if(obj->isShape
                printf("%s %s %L\n" obj->cellView->cellName obj->layerName obj->bBox)
            )
        )
    )
)
