
# 对layer做剪切
# lay: 通过layout create打开的layout
# layer_main: int值，要被cut的layer
# layer_cut : int值，用来cut的layer
# layer_out : int值，存储cut结果的layer
# return    : 剪切后的 layer
proc cut_layer {lay layer_main layer_cut} {
    set layer_out [get_new_layer $lay]
    $lay NOT $layer_main $layer_cut $layer_out
    return $layer_out
}

# 导出连接的 layer
# 调用前需要通过 $lay connect $layer1 $layer2 by $layer3 命令建立连接关系
# lay         : 通过layout create打开的layout
# target_layer: 需要追溯的layer
# return      : 导出的多个layer list，每个layer为 1 个 polygon 的追溯结果
proc extract_connectted_layers {lay cellName target_layer} {
    set all_layers_out [list]
    foreach polygons [$L iterator poly $cellName $target_layer range 0 end] {
        set x0 [lindex $polygons 0]
        set y0 [lindex $polygons 1]
        set layer_out [get_new_layer $lay]
        $L extractNet $cellName -geom $layer1 $x0 $y0 -hier 0 -export $layer_out
        lappend all_layers_out $layer_out
    }
    return $all_layers_out
}

# 移除layer中的datatype
proc f2i {num} {
    if {[regexp {(^[0-9]+)} $num match intPart]} {
        return $intPart
    }
    error "Invalid number: $num"
}
proc fs2is {nums} {
    set ret [list]
    foreach num $nums {
        lappend ret [f2i $num]
    }
    return $ret
}

# 获取未使用的layer编号
proc get_new_layer {lay} {
    set i 1
    set layers [lsort -integer [fs2is [$lay layers]]]
    while {$i in $layers} {
        set i [incr i]
    }
    $lay create layer $i
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
#set unit [$lay units user]
#set old_list {100 200 300 400}
#set new_list [trans_unit $old_list $unit]


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

# gds转oasis，或者直接使用 $MGC_HOME/bin/gds2oasis
proc gdsToOasis {gdsFile outFile} {
    set L [layout create $gdsFile -dt_expand]
    $L oasisout $outFile
}
