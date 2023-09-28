
# 对layer做剪切
# lay: 通过layout create打开的layout
# main_layer: int值，要被cut的layer
# cut_layer: int值，用来cut的layer
# out_layer: int值，存储cut结果的layer
proc cut_layer {lay main_layer cut_layer out_layer} {
    $lay NOT $main_layer $cut_layer $out_layer
}

# 获取未使用的layer编号
proc get_new_layer {lay} {
    set i 1
    set layers [lsort -integer [$lay layers]]
    while {$i in $layers} {
        set i [incr i]
    }
    return $i
}

# 单位转换
proc trans_unit {values ratio} {
    if {[llength $values] == 1} {
        return [expr $values * $ratio]
    }
    set new_list {}
    foreach value $values {
        lappend new_list [trans_unit $value $ratio]
    }
    return $new_list
}
set unit [$lay units user]
set old_list {100 200 300 400}
set new_list [trans_unit $old_list $unit]


# 获取polygon顶点坐标信息
# ret: 若干 {{x1 y1} {x2 y2} ... {xn yn}}
proc get_polygons {lay cell_name layer_num} {
    set polygons [$lay iterator poly $cell_name $layer_num range 0 end]
    set ret_ps {}
    foreach poly $polygons {
        set size [llength $poly]
        set cur_p {}
        for {set i 0} {$i < $size} {incr i 2} {
            set j [expr {$i + 1}]
            set x [lindex $poly $i]
            set y [lindex $poly $j]
            lappend cur_p [list $x $y]
        }
        lappend ret_ps $cur_p
    }
    return $ret_ps
}

# 根据给定坐标获取指定layer的polygon
proc get_polygons_at_pos {lay cell_name layer_num x y} {
    set polyInfos [$lay query polygon $cell_name 0 100 $x $y]
    foreach pi $polyInfos {
        puts $pi
    }
}
