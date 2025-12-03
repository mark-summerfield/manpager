# Copyright © 2025 Mark Summerfield. All rights reserved.

package require util

proc man_link_for_filename filename {
    regexp {^(.*)\.(\d).*?(?:\.gz)?(:?#\d+)?$} [file tail $filename] \
        _ name sect
    if {[info exists name] && [info exists sect]} {
        return "$name\($sect\)"
    }
}

proc man_dirs path {
    set dirs [list]
    foreach dir [glob -directory $path -types d *] {
        if {[string match *man/man* $dir]} {
            lappend dirs $dir
        }
    }
    lsort -nocase $dirs
}


proc man_filenames path {
    set filenames [list]
    foreach dir [man_dirs $path] {
        set iter [fileutil::traverse %AUTO% $dir -filter man_filter]
        lappend filenames {*}[$iter files]
    }
    lsort -command [lambda {a b} {
        set a [file tail $a]
        regexp {^.*\.(\d+).*?$} $a _ sa
        set b [file tail $b]
        regexp {^.*\.(\d+).*?$} $b _ sb
        if {$sa == $sb} { return [string compare -nocase $a $b] }
        expr {$sa < $sb ? -1 : 1}
    }] $filenames
}

proc man_filter filename {
    expr {[regexp {^.*[.][1-9].*$} $filename] && [file isfile $filename] \
          && ![util::islink $filename]}
}
