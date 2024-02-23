#!/bin/env calibredrv
# 运行方式: calibredrv print_gds_oasis.tcl test.gds 或 ./print_gds_oasis.tcl test.gds

proc round {num {ndigits 0}} {
    set level [expr 10 ** $ndigits]
    return [expr double(round($num * $level)) / $level]
}

# 单位转换
proc trans_unit {values ratio} {
    if {[llength $values] == 1} {
        return [round [expr $values * $ratio] 10]
    }
    set new_list {}
    foreach value $values {
        lappend new_list [trans_unit $value $ratio]
    }
    return $new_list
}

# 取最左侧(多个点的)最下方的点作为起始点
proc sort_points {points} {
    set minX [lindex $points 0]
    set minY [lindex $points 1]
    set minXPos 0
    for {set i 0} {$i < [llength $points]} {incr i 2} {
        set x [lindex $points $i]
        set y [lindex $points [expr $i + 1]]
        if {$x < $minX} {
            set minX $x
            set minY $y
            set minXPos $i
        }
        if {$x == $minX && $y < $minY} {
            set minY $y
            set minXPos $i
        }
    }
    if {$minXPos == 0} {
        return $points
    }
    set newPoints1 [list]
    set newPoints2 [list]
    for {set i 0} {$i < [llength $points]} {incr i 2} {
        set x [lindex $points $i]
        set y [lindex $points [expr $i + 1]]
        if {$i >= $minXPos} {
            lappend newPoints1 $x
            lappend newPoints1 $y
        } else {
            lappend newPoints2 $x
            lappend newPoints2 $y
        }
    }
    return [concat $newPoints1 $newPoints2]
}

proc print_texts {L cell_name layer} {
    set unit [$L units user]
    set texts [list]
    foreach text [$L iterator text $cell_name $layer range 0 end] {
        lset text 1 [trans_unit [lindex $text 1] $unit]
        lset text 2 [trans_unit [lindex $text 2] $unit]
        lappend texts "CELL: $cell_name LAYER: $layer TEXT: $text"
    }
    foreach text [lsort $texts] {
        puts $text
    }
}

proc print_polys {ori_polys cell_name layer unit} {
    set polys [list]
    foreach poly $ori_polys {
        lappend polys "CELL: $cell_name LAYER: $layer POLY: [sort_points [trans_unit $poly $unit]]"
    }
    foreach poly [lsort $polys] {
        puts $poly
    }
}

proc print_layer_polys {L cell_name layer} {
    set unit [$L units user]
    set polys [$L iterator poly $cell_name $layer range 0 end]
    if {[string first "LAYER" $polys] < 0} {
        # 所有 polygon 都在同一层
        print_polys $polys $cell_name $layer $unit
    } else {
        # polygon 在不同层
        foreach sub_polys $polys {
            set layer_desc [lindex $sub_polys 0]
            if {[regexp {LAYER ([0-9.]+)} $layer_desc match layer_num]} {
                set _layer "$layer\($layer_num\)"
            } else {
                set _layer "$layer\(-1\)"
            }
            set _polys [list [lrange $sub_polys 1 [llength $sub_polys]]]
            print_polys $_polys $cell_name $_layer $unit
        }
    }
}

proc print_wires {L cell_name layer} {
    set wires [list]
    foreach wire [$L iterator wire $cell_name $layer range 0 end] {
        lappend wires "CELL: $cell_name LAYER: $layer WIRE: $wire"
    }
    foreach wire [lsort $wires] {
        puts $wire
    }
}

# recursive: 是否遍历引用的cell(instance)
proc print_cell {L cell_name {recursive false}} {
    set unit [$L units user]
    foreach layer [lsort [$L layers]] {
        print_texts $L $cell_name $layer
        print_layer_polys $L $cell_name $layer
        print_wires $L $cell_name $layer
    }
    if {$recursive} {
        set ref_cells [list]
        foreach ref_cell [$L iterator ref $cell_name range 0 end] {
            # 修改 x, y 值
            lset ref_cell 1 [trans_unit [lindex $ref_cell 1] $unit]
            lset ref_cell 2 [trans_unit [lindex $ref_cell 2] $unit]
            lappend ref_cells $ref_cell
        }
        set sorted_cells [lsort $ref_cells]
        foreach ref_cell $sorted_cells {
            puts "CELL $cell_name REF: $ref_cell"
        }
        foreach ref_cell $sorted_cells {
            set ref_name [lindex $ref_cell 0]
            print_cell $L $ref_name $recursive
        }
    }
}

proc print_file {file top_cell} {
    set L [layout create $file -dt_expand]
    # 如果保留properties需要适配iterator输出结果
    # set L [layout create $file -dt_expand -preserveProperties]
    if {[string length $top_cell] != 0} {
        print_cell $L $top_cell true
    } else {
        foreach cell_name [lsort [$L cells]] {
            print_cell $L $cell_name
        }
    }
}

proc main {argv} {
    if {[llength $argv] == 0 || [lindex $argv 0] == "-h"} {
        puts "Usage: print_gds_oasis.tcl test.gds"
        exit
    }
    set file [lindex $argv 0]
    set top_cell [lindex $argv 1]
    if {![file exists $file]} {
        puts "File does not exists: $file"
        exit -1
    }
    print_file $file $top_cell
}

main $argv
