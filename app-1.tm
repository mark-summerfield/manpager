# Copyright © 2025 Mark Summerfield. All rights reserved.

package require config
package require lambda 1
package require man
package require ui
package require util
package require fileutil::traverse 

oo::class create App {
    variable Cfg
    variable TreeLabel
    variable Tree
    variable View
    variable SearchEntry
    variable SearchCombobox
    variable SearchFound
    variable FindEntry
    variable FindIndex
    variable LinoLabel
}

oo::define App constructor {} {
    ui::wishinit
    tk appname Manpager
    set Cfg [Config load]
    my make_ui
    my populate_tree
}

oo::define App method show {} {
    wm deiconify .
    wm geometry . [$Cfg geometry]
    raise .
    update
    my on_startup
}

oo::define App method on_startup {} {
    set FindIndex 1.0
    if {$::argc > 0} {
        $SearchEntry delete 0 end
        $SearchEntry insert 0 [lindex $::argv 0]
        my on_find
    } else {
        set page [$Cfg page]  
        if {$page eq "" || [$Cfg randomstartpage]} {
            my show_random_page
        } else {
            my view_page $page
        }
    }
    focus $SearchEntry
}

oo::define App method populate_tree {} {
    tk busy .
    update
    try {
        set page_count 0
        $Tree delete [$Tree children {}]
        set sections [my populate_sections]
        set parents [dict create]
        foreach filename [man_filenames [$Cfg path]] {
            regexp {^.*\.(\d+).*?$} $filename _ section
            set name [regsub {.gz$} [file tail $filename] ""]
            set i [string last . $name]
            if {$i > -1} { set name [string range $name 0 [incr i -1]] }
            set grand_parent [lindex $sections $section]
            set first [string toupper [string index $name 0]]
            if {![string is alpha $first]} { set first * }
            set parent [dict getdef $parents $grand_parent $first ""]
            if {$parent eq ""} {
                set parent [$Tree insert $grand_parent end -text $first]
                dict set parents $grand_parent $first $parent
            }
            if {$name ne "\["} {
                $Tree insert $parent end -id $filename \
                    -text $name\($section\)
                incr page_count
            }
        }
        $TreeLabel configure -text "Man Pages \[[commas $page_count]\]"
    } finally {
        tk busy forget .
        update
    }
}

oo::define App method populate_sections {} {
    list {} [$Tree insert {} end -id S1 -text "1 Programs/commands"] \
            [$Tree insert {} end -id S2 -text "2 System calls"] \
            [$Tree insert {} end -id S3 -text "3 Library calls"] \
            [$Tree insert {} end -id S4 -text "4 Files in /dev"] \
            [$Tree insert {} end -id S5 -text "5 File formats"] \
            [$Tree insert {} end -id S6 -text "6 Games"] \
            [$Tree insert {} end -id S7 -text "7 Miscellaneous"] \
            [$Tree insert {} end -id S8 -text "8 Sysadmin (root)"] \
            [$Tree insert {} end -id S9 -text "9 Kernel routines"] \
            [$Tree insert {} end -id History -text History -open true]
}

oo::define App method show_random_page {} {
    set sections [linsert [lrange [$Tree children {}] 0 end-1] end S1 S1]
    foreach _ [lseq 9] {
        set section [lrandom $sections]
        set letters [$Tree children $section]
        if {[llength $letters] < 3} { continue }
        set letter [lrandom $letters]
        set pages [$Tree children $letter]
        if {[llength $pages] < 3} { continue }
        set sel [lrandom $pages]
        if {[string match /* $sel]} {
            $Tree see $sel
            $Tree selection set $sel
            $Tree focus $sel
            break
        }
    }
}
