# Copyright © 2025 Mark Summerfield. All rights reserved.

package require abstract_form
package require tooltip 2
package require ui

oo::class create ConfigForm {
    superclass AbstractForm

    variable Ok
    variable Cfg
    variable Blinking
    variable FontFamily
    variable FontSize
    variable RandomStartPage
    variable Path
}

oo::define ConfigForm constructor {ok cfg} {
    set Ok $ok
    set Cfg $cfg
    set Blinking [$Cfg blinking]
    set FontFamily [$Cfg fontfamily]
    set FontSize [$Cfg fontsize]
    set RandomStartPage [$Cfg randomstartpage]
    set Path [$Cfg path]
    my make_widgets 
    my make_layout
    my make_bindings
    next .configForm [callback on_cancel]
    my show_modal .configForm.frame.scaleSpinbox
}

oo::define ConfigForm method make_widgets {} {
    tk::toplevel .configForm
    wm resizable .configForm false false
    wm title .configForm "[tk appname] — Config"
    ttk::frame .configForm.frame
    set tip tooltip::tooltip
    ttk::label .configForm.frame.scaleLabel -text "Application Scale" \
        -underline 12
    ttk::spinbox .configForm.frame.scaleSpinbox -format %.2f -from 1.0 \
        -to 10.0 -increment 0.1
    $tip .configForm.frame.scaleSpinbox "Application’s scale factor.\nBest\
        to set this before setting the font.\nRestart to apply."
    .configForm.frame.scaleSpinbox set [format %.2f [tk scaling]]
    ttk::checkbutton .configForm.frame.blinkCheckbutton \
        -text "Cursor Blink" -underline 7 -variable [my varname Blinking]
    if {$Blinking} { .configForm.frame.blinkCheckbutton state selected }
    $tip .configForm.frame.blinkCheckbutton \
        "Whether the text cursor should blink."
    set opts "-compound left -width 15"
    ttk::button .configForm.frame.fontButton -text Font… -underline 0 \
        -image [ui::icon preferences-desktop-font.svg $::ICON_SIZE] \
        -command [callback on_font] {*}$opts
    $tip .configForm.frame.fontButton "The font to use for displaying man\
        pages.\nBest to set the application’s scale (and restart) first."
    ttk::label .configForm.frame.fontLabel -relief sunken \
        -text "[$Cfg fontfamily] [$Cfg fontsize]"
    ttk::label .configForm.frame.startPageLabel -text "Start at"
    ttk::radiobutton .configForm.frame.randomPageRadiobutton \
        -text "Random Page" -underline 0 -value true \
        -variable [my varname RandomStartPage]
    $tip .configForm.frame.randomPageRadiobutton \
        "Start at a random man page."
    ttk::radiobutton .configForm.frame.lastViewedPageRadiobutton \
        -value false -text "Last Viewed Page" -underline 0 \
        -variable [my varname RandomStartPage]
    $tip .configForm.frame.lastViewedPageRadiobutton \
        "Start at the last viewed man page."
    ttk::button .configForm.frame.manPathButton -text "Man Pages Path…" \
        -underline 0 -image [ui::icon folder.svg $::ICON_SIZE] \
        -command [callback on_man_path] {*}$opts
    $tip .configForm.frame.manPathButton \
        "The path to the system’s man pages."
    ttk::label .configForm.frame.manPathLabel -relief sunken \
        -text [$Cfg path]
    ttk::label .configForm.frame.configFileLabel -foreground gray25 \
        -text "Config file"
    ttk::label .configForm.frame.configFilenameLabel -foreground gray25 \
        -text [$Cfg filename] -relief sunken
    ttk::frame .configForm.frame.buttons
    ttk::button .configForm.frame.buttons.okButton -text OK -underline 0 \
        -compound left -image [ui::icon ok.svg $::ICON_SIZE] \
        -command [callback on_ok]
    ttk::button .configForm.frame.buttons.cancelButton -text Cancel \
        -compound left -image [ui::icon gtk-cancel.svg $::ICON_SIZE] \
        -command [callback on_cancel]
}

oo::define ConfigForm method make_layout {} {
    const opts "-padx 3 -pady 3"
    grid .configForm.frame.scaleLabel -row 0 -column 0 -sticky w {*}$opts
    grid .configForm.frame.scaleSpinbox -row 0 -column 1 -columnspan 2 \
        -sticky we {*}$opts
    grid .configForm.frame.fontButton -row 1 -column 0 -sticky w {*}$opts
    grid .configForm.frame.fontLabel -row 1 -column 1 -columnspan 2 \
        -sticky news {*}$opts
    grid .configForm.frame.blinkCheckbutton -row 2 -column 1 -sticky we
    grid .configForm.frame.startPageLabel -row 3 -column 0 -sticky w \
        {*}$opts
    grid .configForm.frame.randomPageRadiobutton -row 3 -column 1 \
        -sticky w {*}$opts
    grid .configForm.frame.lastViewedPageRadiobutton -row 3 -column 2 \
        -sticky w {*}$opts
    grid .configForm.frame.manPathButton -row 4 -column 0 -sticky w {*}$opts
    grid .configForm.frame.manPathLabel -row 4 -column 1 -columnspan 2 \
        -sticky news {*}$opts
    grid .configForm.frame.configFileLabel -row 8 -column 0 -sticky we \
        {*}$opts
    grid .configForm.frame.configFilenameLabel -row 8 -column 1 \
        -columnspan 2 -sticky we {*}$opts
    grid .configForm.frame.buttons -row 9 -column 0 -columnspan 3 -sticky we
    pack [ttk::frame .configForm.frame.buttons.pad1] -side left -expand true
    pack .configForm.frame.buttons.okButton -side left {*}$opts
    pack .configForm.frame.buttons.cancelButton -side left {*}$opts
    pack [ttk::frame .configForm.frame.buttons.pad2] -side right \
        -expand true
    grid columnconfigure .configForm 1 -weight 1
    pack .configForm.frame -fill both -expand true
}

oo::define ConfigForm method make_bindings {} {
    bind .configForm <Escape> [callback on_cancel]
    bind .configForm <Return> [callback on_ok]
    bind .configForm <Alt-b> {.configForm.frame.blinkCheckbutton invoke}
    bind .configForm <Alt-f> [callback on_font]
    bind .configForm <Alt-l> \
        {.configForm.frame.lastViewedPageRadiobutton invoke}
    bind .configForm <Alt-m> [callback on_man_path]
    bind .configForm <Alt-o> [callback on_ok]
    bind .configForm <Alt-r> \
        {.configForm.frame.randomPageRadiobutton invoke}
    bind .configForm <Alt-s> {focus .configForm.frame.scaleSpinbox}
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
            .configForm.frame.fontLabel configure \
                -text "$FontFamily $FontSize"
        }
    }
}

oo::define ConfigForm method on_man_path {} {
    set dir [tk_chooseDirectory -parent .configForm -mustexist true \
        -title "[tk appname] — Choose Man Pages Path" -initialdir $Path]
    if {$dir ne "" && $dir ne $Path} {
        .configForm.frame.manPathLabel configure -text $dir
        set Path $dir
    }
}

oo::define ConfigForm method on_ok {} {
    tk scaling [.configForm.frame.scaleSpinbox get]
    $Cfg set_blinking $Blinking
    $Cfg set_fontfamily $FontFamily
    $Cfg set_fontsize $FontSize
    $Cfg set_randomstartpage $RandomStartPage
    $Cfg set_path $Path
    $Ok set true
    my delete
}

oo::define ConfigForm method on_cancel {} { my delete }
