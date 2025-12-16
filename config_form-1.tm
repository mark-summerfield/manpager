# Copyright © 2025 Mark Summerfield. All rights reserved.

package require abstract_form
package require tooltip 2
package require ui

oo::class create ConfigForm {
    superclass AbstractForm

    variable Ok
    variable Blinking
    variable FontFamily
    variable FontSize
    variable RandomStartPage
    variable Path
}

oo::define ConfigForm constructor ok {
    set Ok $ok
    set config [Config new]
    set Blinking [$config blinking]
    set FontFamily [$config fontfamily]
    set FontSize [$config fontsize]
    set RandomStartPage [$config randomstartpage]
    set Path [$config path]
    my make_widgets 
    my make_layout
    my make_bindings
    next .configForm [callback on_cancel]
    my show_modal .configForm.mf.scaleSpinbox
}

oo::define ConfigForm method make_widgets {} {
    set config [Config new]
    tk::toplevel .configForm
    wm resizable .configForm 0 0
    wm title .configForm "[tk appname] — Config"
    ttk::frame .configForm.mf
    set tip tooltip::tooltip
    ttk::label .configForm.mf.scaleLabel -text "Application Scale" \
        -underline 12
    ttk::spinbox .configForm.mf.scaleSpinbox -format %.2f -from 1.0 \
        -to 10.0 -increment 0.1
    ui::apply_edit_bindings .configForm.mf.scaleSpinbox
    $tip .configForm.mf.scaleSpinbox "Application’s scale factor.\nBest\
        to set this before setting the font.\nRestart to apply."
    .configForm.mf.scaleSpinbox set [format %.2f [tk scaling]]
    ttk::checkbutton .configForm.mf.blinkCheckbutton \
        -text "Cursor Blink" -underline 7 -variable [my varname Blinking]
    if {$Blinking} { .configForm.mf.blinkCheckbutton state selected }
    $tip .configForm.mf.blinkCheckbutton \
        "Whether the text cursor should blink."
    set opts "-compound left -width 15"
    ttk::button .configForm.mf.fontButton -text Font… -underline 0 \
        -image [ui::icon preferences-desktop-font.svg $::ICON_SIZE] \
        -command [callback on_font] {*}$opts
    $tip .configForm.mf.fontButton "The font to use for displaying man\
        pages.\nBest to set the application’s scale (and restart) first."
    ttk::label .configForm.mf.fontLabel -relief sunken \
        -text "[$config fontfamily] [$config fontsize]"
    ttk::label .configForm.mf.startPageLabel -text "Start at"
    ttk::radiobutton .configForm.mf.randomPageRadiobutton \
        -text "Random Page" -underline 0 -value 1 \
        -variable [my varname RandomStartPage]
    $tip .configForm.mf.randomPageRadiobutton \
        "Start at a random man page."
    ttk::radiobutton .configForm.mf.lastViewedPageRadiobutton -value 0 \
        -text "Last Viewed Page" -underline 0 \
        -variable [my varname RandomStartPage]
    $tip .configForm.mf.lastViewedPageRadiobutton \
        "Start at the last viewed man page."
    ttk::button .configForm.mf.manPathButton -text "Man Pages Path…" \
        -underline 0 -image [ui::icon folder.svg $::ICON_SIZE] \
        -command [callback on_man_path] {*}$opts
    $tip .configForm.mf.manPathButton \
        "The path to the system’s man pages."
    ttk::label .configForm.mf.manPathLabel -relief sunken \
        -text [$config path]
    ttk::label .configForm.mf.configFileLabel -foreground gray25 \
        -text "Config file"
    ttk::label .configForm.mf.configFilenameLabel -foreground gray25 \
        -text [$config filename] -relief sunken
    ttk::frame .configForm.mf.buttons
    ttk::button .configForm.mf.buttons.okButton -text OK -underline 0 \
        -compound left -image [ui::icon ok.svg $::ICON_SIZE] \
        -command [callback on_ok]
    ttk::button .configForm.mf.buttons.cancelButton -text Cancel \
        -compound left -image [ui::icon gtk-cancel.svg $::ICON_SIZE] \
        -command [callback on_cancel]
}

oo::define ConfigForm method make_layout {} {
    const opts "-padx 3 -pady 3"
    grid .configForm.mf.scaleLabel -row 0 -column 0 -sticky w {*}$opts
    grid .configForm.mf.scaleSpinbox -row 0 -column 1 -columnspan 2 \
        -sticky we {*}$opts
    grid .configForm.mf.fontButton -row 1 -column 0 -sticky w {*}$opts
    grid .configForm.mf.fontLabel -row 1 -column 1 -columnspan 2 \
        -sticky news {*}$opts
    grid .configForm.mf.blinkCheckbutton -row 2 -column 1 -sticky we
    grid .configForm.mf.startPageLabel -row 3 -column 0 -sticky w \
        {*}$opts
    grid .configForm.mf.randomPageRadiobutton -row 3 -column 1 \
        -sticky w {*}$opts
    grid .configForm.mf.lastViewedPageRadiobutton -row 3 -column 2 \
        -sticky w {*}$opts
    grid .configForm.mf.manPathButton -row 4 -column 0 -sticky w {*}$opts
    grid .configForm.mf.manPathLabel -row 4 -column 1 -columnspan 2 \
        -sticky news {*}$opts
    grid .configForm.mf.configFileLabel -row 8 -column 0 -sticky we \
        {*}$opts
    grid .configForm.mf.configFilenameLabel -row 8 -column 1 \
        -columnspan 2 -sticky we {*}$opts
    grid .configForm.mf.buttons -row 9 -column 0 -columnspan 3 -sticky we
    pack [ttk::frame .configForm.mf.buttons.pad1] -side left -expand 1
    pack .configForm.mf.buttons.okButton -side left {*}$opts
    pack .configForm.mf.buttons.cancelButton -side left {*}$opts
    pack [ttk::frame .configForm.mf.buttons.pad2] -side right -expand 1
    grid columnconfigure .configForm 1 -weight 1
    pack .configForm.mf -fill both -expand 1
}

oo::define ConfigForm method make_bindings {} {
    bind .configForm <Escape> [callback on_cancel]
    bind .configForm <Return> [callback on_ok]
    bind .configForm <Alt-b> {.configForm.mf.blinkCheckbutton invoke}
    bind .configForm <Alt-f> [callback on_font]
    bind .configForm <Alt-l> \
        {.configForm.mf.lastViewedPageRadiobutton invoke}
    bind .configForm <Alt-m> [callback on_man_path]
    bind .configForm <Alt-o> [callback on_ok]
    bind .configForm <Alt-r> \
        {.configForm.mf.randomPageRadiobutton invoke}
    bind .configForm <Alt-s> {focus .configForm.mf.scaleSpinbox}
}

oo::define ConfigForm method on_font {} {
    tk fontchooser configure -parent .configForm \
        -title "[tk appname] — Choose Font" -font Mono \
        -command [callback on_font_chosen]
    tk fontchooser show
}

oo::define ConfigForm method on_font_chosen args {
    if {[llength $args] > 0} {
        set args [lindex $args 0]
        if {[llength $args] > 1} {
            set FontFamily [lindex $args 0]
            set FontSize [lindex $args 1]
            .configForm.mf.fontLabel configure \
                -text "$FontFamily $FontSize"
        }
    }
}

oo::define ConfigForm method on_man_path {} {
    set dir [tk_chooseDirectory -parent .configForm -mustexist 1 \
        -title "[tk appname] — Choose Man Pages Path" -initialdir $Path]
    if {$dir ne "" && $dir ne $Path} {
        .configForm.mf.manPathLabel configure -text $dir
        set Path $dir
    }
}

oo::define ConfigForm method on_ok {} {
    tk scaling [.configForm.mf.scaleSpinbox get]
    set config [Config new]
    $config set_blinking $Blinking
    $config set_fontfamily $FontFamily
    $config set_fontsize $FontSize
    $config set_randomstartpage $RandomStartPage
    $config set_path $Path
    $Ok set 1
    my delete
}

oo::define ConfigForm method on_cancel {} { my delete }
