# Copyright © 2025 Mark Summerfield. All rights reserved.

package require about_form
package require config_form
package require fileutil 1
package require ref
package require util

oo::define App method on_find {} {
    tk busy .
    update
    try {
        catch {$Tree delete Found}
        $Tree insert {} end -id Found -text Found
        switch [$FindCombobox get] {
            Apropos {set found [my on_find_apropos]}
            Text {set found [my on_find_freetext]}
            Name {set found [my on_find_name]}
        }
        lassign [util::n_s [llength $found]] n s
        set Found [list "Found $n man page$s\n"]
        lappend Found {*}[lsort -dictionary -unique $found]
        lappend Found "_\n"
        $Tree see Found
        $Tree selection set Found
        $Tree focus Found
        my view_page Found
    } finally {
        tk busy forget .
        update
    }
}

oo::define App method on_find_apropos {} {
    set found [list]
    try {
        set what [$FindEntry get]
        set lines [exec -encoding utf-8 -- man -k {*}$what]
        foreach line [split $lines \n] {
            set parts [split $line]
            if {[llength $parts] > 2} {
                set manpage [lindex $parts 0][lindex $parts 1]
                set desc [string trimleft [string trim \
                    [join [lrange $parts 2 end] " "]] " -"]
                lappend found "• $manpage\t$desc\n"
            }
        }
    } on error err {
        puts "error running 'man -k $what': $err"
    }
    return $found
}

oo::define App method on_find_freetext {} {
    set found [list]
    try {
        set what [$FindEntry get]
        set filenames [exec -encoding utf-8 -- man -Kw {*}$what]
        foreach filename [split $filenames \n] {
            set manlink [man_link_for_filename $filename]
            if {$manlink ne ""} {
                lappend found "• $manlink\n"
            }
        }
    } on error err {
        puts "error running 'man -Kw $what': $err"
    }
    return $found
}

oo::define App method on_find_name {} {
    set what [$FindEntry get]
    set found [list]
    foreach n [lseq 1 to 9] {
        foreach letter [$Tree children S$n] {
            foreach filename [$Tree children $letter] {
                if {[string match -nocase *$what* $filename]} {
                    set manlink [man_link_for_filename $filename]
                    if {$manlink ne ""} {
                        lappend found "• $manlink\n"
                    }
                }
            }
        }
    }
    return $found
}

oo::define App method on_tree_select {} {
    set sel [$Tree selection]
    if {$sel eq "Found" || [string match /* $sel]} {
        set sel [regsub {#.*} $sel ""]
        my view_page $sel
    }
}

oo::define App method on_focus_tree {} {
    focus $Tree
    set sel [$Tree selection]
    if {$sel eq ""} {
        set sel S1
    }
    $Tree see $sel
    $Tree selection set $sel
    $Tree focus $sel
}

oo::define App method on_text_select {} {
    set index [lindex [$View tag ranges sel] 0]
    if {$index ne ""} {
        foreach {first last} [$View tag ranges manlink] {
            if {[$View compare $first <= $index] && \
                    [$View compare $index <= $last]} {
                my view_manlink_page [$View get $first $last]
                return
            }
        }
        foreach {first last} [$View tag ranges url] {
            if {[$View compare $first <= $index] && \
                    [$View compare $index <= $last]} {
                set url [$View get $first $last]
                util::open_webpage $url
                return
            }
        }
    }
}

oo::define App method on_config {} {
    set ok [Ref new false]
    set fontfamily [$Cfg fontfamily]
    set fontsize [$Cfg fontsize]
    set path [$Cfg path]
    ConfigForm new $ok $Cfg
    tkwait window .config
    if {[$ok get]} {
        if {$fontfamily ne [$Cfg fontfamily] || \
                $fontsize != [$Cfg fontsize]} {
            make_fonts [$Cfg fontfamily] [$Cfg fontsize]
        }
        if {$path ne [$Cfg path]} {
            my populate_tree
        }
    }
}

oo::define App method on_about {} { AboutForm new }

oo::define App method on_quit {} { $Cfg save ; exit }

oo::define App method view_manlink_page manlink {
    regexp {(.*)\((\d).*} [string tolower $manlink] _ page section
    if {![info exists page] || ![info exists section]} { return }
    set section S$section
    set letter [string index $page 0]
    if {[string is alpha $letter]} {
        set letter [string toupper $letter]
    } else {
        set letter *
    }
    foreach subsect [$Tree children $section] {
        if {[$Tree item $subsect -text] eq $letter} {
            foreach filename [$Tree children $subsect] {
                if {[string match -nocase */$page.* $filename]} {
                    my view_page $filename
                    return
                }
            }
        }
    }
}

oo::define App method view_page filename {
    set man [my get_text $filename]
    $View delete 1.0 end
    $View insert end [string trimright $man]
    if {$filename eq "Found"} {
        if {[$FindCombobox get] eq "Apropos"} { text_stripe $View }
    } elseif {$filename ne "History"} {
        my update_history $filename
        text_replace_ctrl_h $View
    }
    text_apply_styles $View
    if {$filename eq "Found"} {
        $View tag add special "end -1 line" end
    }
}

oo::define App method get_text filename {
    if {$filename eq "Found"} {
        set man [join $Found ""]
    } else {
        set fh [open |[list man -Tutf8 $filename]]
        try {
            try {
                fconfigure $fh -encoding utf-8
                set man [read $fh]
            } finally {
                close $fh
            }
        } on error err {
            puts "error running 'man -Tutf8 $filename': $err"
        }
    }
    return $man
}

oo::define App method update_history filename {
    $Cfg set_page $filename
    set manlink [man_link_for_filename $filename]
    if {$manlink ne ""} {
        set past [$Tree children History]
        $Tree delete $past
        $Tree insert History end -id $filename#0 -text $manlink
        set n 1
        foreach name $past {
            set name [regsub {#\d+$} $name ""]
            if {$name ne $filename} {
                set manlink [man_link_for_filename $name]
                if {$manlink ne ""} {
                    $Tree insert History end -id $name#$n -text $manlink
                    incr n
                }
            }
        }
    }
}
