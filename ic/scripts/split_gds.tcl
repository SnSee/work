# 运行方式: calibredrv split_gds.tcl test.gds output_dir

proc split_gds {gds_file out_dir} {
    set L [layout create $gds_file -dt_expand]
    foreach cell_name [lsort [$L cells]] {
        $L gdsout "$out_dir/$cell_name.gds" $cell_name
    }
}

proc main {argv} {
    if {[llength $argv] != 2 || [lindex $argv 0] == "-h"} {
        puts "Usage: calibredrv split_gds.tcl test.gds output_dir"
        exit
    }
    set file [lindex $argv 0]
    if {![file exists $file]} {
        puts "File does not exists: $file"
        exit -1
    }
    set out_dir [lindex $argv 1]
    if {![file exists $out_dir]} {
        file mkdir $out_dir
    }
    split_gds $file $out_dir
}

main $argv
