procedure(myWriteRect(rect fp)
    fprintf(fp "CELL: %s LAYER: %s BBOX: %L\n" rect->cellView->cellName rect->layerName rect->bBox)
)

procedure(myWriteLabel(label fp)
    fprintf(fp "CELL: %s LAYER: %s TEXT: %s POS: %L\n" label->cellView->cellName label->layerName label->theLabel label->xy)
)

procedure(myGetCellView(libName cellName)
    let((cv retCv)
        ; 先从已经打开的cell-view中搜索
        retCv = prog(()
            foreach(cv dbGetOpenCellViews()
                if(cv->cellName == cellName
                    return(cv)
                )
            )
            ; 没查找到就打开
            return(dbOpenCellViewByType(libName cellName "layout"))
        )
        retCv
    )
)

procedure(myWriteCellView(cv instName fp)
    let(((libName cv->libName) (cellName cv->cellName) sp inst instCell)
        ; write shapes(rect)
        foreach(sp cv->shapes
            case(sp->objType
                ("rect" myWriteRect(sp fp))
                ("label" myWriteLabel(sp fp))
            )
        )
        foreach(inst cv->instances
            instCell = inst->cellName
            fprintf(fp "CELL: %s REF: %s INST: %s POS: %L\n" cellName instCell inst->name inst->bBox)
            myWriteCellView(myGetCellView(libName instCell) inst->name fp)
        )
    )
)

procedure(myWriteLayout(outFile)
    let(((fp outfile(outFile)))
        cv = geGetEditCellView(hiGetCurrentWindow())
        myWriteCellView(cv "NONE" fp)
        close(fp)
    )
)

;; usage
;; myWriteLayout("/tmp/a.tmp")
