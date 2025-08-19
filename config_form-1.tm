# Copyright © 2025 Mark Summerfield. All rights reserved.

package require form
package require ui

oo::class create ConfigForm {
    variable Cfg
}

oo::define ConfigForm constructor cfg {
    set Cfg $cfg
    my make_widgets 
    my make_layout
    my make_bindings
    form::prepare .config [callback on_cancel]
    form::show_modal .config
}

oo::define ConfigForm method make_widgets {} {
    tk::toplevel .config
    wm title .config "[tk appname] — Config"
    # TODO 
    ttk::frame .config.buttons
    ttk::button .config.buttons.okButton -text OK -underline 0 \
        -compound left -image [ui::icon ok.svg $::ICON_SIZE] \
        -command [callback on_ok]
    ttk::button .config.buttons.cancelButton -text Cancel -compound left \
        -image [ui::icon gtk-cancel.svg $::ICON_SIZE] \
        -command [callback on_cancel]
}


oo::define ConfigForm method make_layout {} {
    # TODO 
    grid .config.buttons -sticky we -pady 3
    pack .config.buttons.okButton -side left
    pack .config.buttons.cancelButton -side left
}


oo::define ConfigForm method make_bindings {} {
    bind .config <Escape> [callback on_cancel]
    bind .config <Return> [callback on_ok]
    bind .config <Alt-o> [callback on_ok]
}


oo::define ConfigForm method on_ok {} {
    puts "TODO on_ok: save config"
    form::delete .config
}

oo::define ConfigForm method on_cancel {} { form::delete .config }
