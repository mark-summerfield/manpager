# Copyright © 2025 Mark Summerfield. All rights reserved.

package require about_form
package require fileutil 1

oo::define App method on_find {} {
    puts "TODO on_find"
}

oo::define App method on_tree_select {} {
    set sel [$Tree selection]
    if {[string match /* $sel]} {
        my view_page $sel
    }
}

oo::define App method on_focus_tree {} {
    focus $Tree
    set sel [$Tree selection]
    if {$sel eq ""} {
        set sel S1 ;# TODO choose a random leaf
    }
    $Tree see $sel
    $Tree selection set $sel
    $Tree focus $sel
}

oo::define App method on_about {} { about_form::show_modal }

oo::define App method on_quit {} {
    $Cfg save
    exit
}

oo::define App method view_page filename {
    set base [regsub {\.gz$} [file tail $filename] ""]
    set html [fileutil::tempdir]/$base.html
    if {![file isfile $html]} {
        if {[catch {exec man -Thtml $filename > $html} err]} {
            puts stderr "error creating $html: $err"
        }
    }
    $View browse $html
    # $View helptext tag add mono 1.0 end ;# TODO doesn't work
}
