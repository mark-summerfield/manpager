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

oo::define App method on_text_select {} {
    set index [lindex [$View tag ranges sel] 0]
    if {$index ne ""} {
        foreach {first last} [$View tag ranges manlink] {
            if {$first <= $index && $index <= $last} {
                set manpage [$View get $first $last]
                puts "on_text_select man page '$manpage'"
                # TODO split
                return
            }
        }
        foreach {first last} [$View tag ranges url] {
            if {$first <= $index && $index <= $last} {
                # TODO open the url
                set url [$View get $first $last]
                puts "on_text_select url '$url'"
                return
            }
        }
    }
}

oo::define App method on_about {} { about_form::show_modal }

oo::define App method on_quit {} {
    $Cfg save
    exit
}

oo::define App method view_page filename {
    set fh [open |[list man -Tutf8 $filename]]
    fconfigure $fh -encoding utf-8
    set man [read $fh]
    close $fh
    $View delete 1.0 end
    $View insert end [string trimright $man]
    text_replace_ctrl_h $View
    text_apply_styles $View
}
