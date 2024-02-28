# 将 gds merge 到同一个文件但不放到同一个 top cell 下
layout filemerge -in test1.gds -in test2.gds -o out.gds

# 将 gds merge 到同一个 top cell 下(排成一行)
proc merge_gds { top_cell gds_dir } {
    set L [layout create]
    $L create cell $top_cell
    set files [glob -nocomplain "$gds_dir/*.gds"]
    foreach gf $files {
        # 获取 right-most x 坐标作为引用位置
        set x [lindex [$L bbox $top_cell recompute] 2]
        set cell_name [file rootname [file tail $gf]]
        set ref_L [layout create $gf -dt_expand]
        # 复制 cell
        $L create cell $cell_name $ref_L $cell_name
        # 创建 instance，紧跟在上一个cell后边
        $L create ref $top_cell $cell_name $x 0 0 0 1
    }
    $L gdsout "$top_cell.gds"
}
