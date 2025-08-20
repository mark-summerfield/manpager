# Copyright © 2025 Mark Summerfield. All rights reserved.

oo::abstract create AbstractForm {
    variable Window
}

oo::define AbstractForm constructor {window on_close {modal true} \
        {x 0} {y 0}} {
    set Window $window
    wm withdraw $Window
    wm attributes $Window -type dialog
    if {$modal} {
        wm transient $Window .
    }
    wm group $Window .
    set parent [winfo parent $Window]
    if {!($x && $y)} {
        set x [expr {[winfo x $parent] + [winfo width $parent] / 3}]
        set y [expr {[winfo y $parent] + [winfo height $parent] / 3}]
    }
    wm geometry $Window "+$x+$y"
    wm protocol $Window WM_DELETE_WINDOW $on_close
}

oo::define AbstractForm method show_modal {{focus_widget ""}} {
    wm deiconify $Window
    grab set $Window
    raise $Window
    update
    focus $Window
    if {$focus_widget ne ""} { focus $focus_widget }
}

oo::define AbstractForm method show_modeless {} {
    wm deiconify $Window
    raise $Window
    update
    focus $Window
}

oo::define AbstractForm method delete {} {
    grab release $Window
    destroy $Window
}

oo::define AbstractForm method hide {} {
    grab release $Window
    wm withdraw $Window
}
