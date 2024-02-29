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
    let(((form gWriteBBoxForm) outFile w cv fp line)
        w = hiGetCurrentWindow()
        cv = geGetEditCellView(w)
        outFile = form->outFile->value
        if(length(outFile) != 0 then fp = outfile(outFile) else fp = nil)
        foreach(obj geGetSelectedSet(cv)
            ; bBox: ((left_bottom_x left_bottom_y) (top_right_x top_right_y))
            if(obj->bBox then
                line = lsprintf("%s %L %L %L\n" obj->objType obj->cellView->cellName obj->layerName obj->bBox)
                if(fp then
                    fprintf(fp "%s" line)
                else
                    printf(line)
                )
            )
        )
        if(fp then close(fp) println("bBox written"))
    )
)
