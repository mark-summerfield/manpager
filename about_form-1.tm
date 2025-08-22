# Copyright © 2025 Mark Summerfield. All rights reserved.

package require abstract_form
package require ui
package require util

oo::class create AboutForm {
    superclass AbstractForm
}

oo::define AboutForm constructor {} {
    my make_widgets
    my make_layout
    my make_bindings
    next .about [callback on_close]
    my show_modal .about.closeButton
}

oo::define AboutForm method make_widgets {} {
    tk::toplevel .about
    wm title .about "[tk appname] — About"
    wm resizable .about false false
    set height 15
    tk::text .about.text -width 50 -height $height -wrap word \
        -background "#F0F0F0" -spacing1 3 -spacing3 3
    my Populate
    .about.text configure -state disabled
    ttk::button .about.closeButton -text Close -compound left \
        -image [ui::icon close.svg $::ICON_SIZE] \
        -command [callback on_close]
}

oo::define AboutForm method make_layout {} {
    grid .about.text -sticky nsew -pady 3
    grid .about.closeButton -pady 3
}

oo::define AboutForm method make_bindings {} {
    bind .about <Escape> [callback on_close]
    bind .about <Return> [callback on_close]
    .about.text tag bind url <Double-1> [callback on_click_url @%x,%y]
}

oo::define AboutForm method on_click_url index {
    set indexes [.about.text tag prevrange url $index]
    set url [string trim [.about.text get {*}$indexes]]
    if {$url ne ""} {
        if {![string match -nocase http*://* $url]} {
            set url [string cat http:// $url]
        }
        util::open_webpage $url
    }
}

oo::define AboutForm method on_close {} { my delete }

oo::define AboutForm method Populate {} {
    set txt .about.text
    my AddTextTags $txt
    set img [$txt image create end -align center \
             -image [ui::icon icon.svg 64]]
    $txt tag add spaceabove $img
    $txt tag add center $img
    set add [list $txt insert end]
    {*}$add "\nManpager $::VERSION\n" {center title}
    {*}$add "A Unix man page viewer.\n\n" {center navy}
    set year [clock format [clock seconds] -format %Y]
    if {$year > 2025} { set year "2025-[string range $year end-1 end]" }
    set bits [expr {8 * $::tcl_platform(wordSize)}]
    set distro [exec lsb_release -ds]
    {*}$add "https://github.com/mark-summerfield/manpager\n" \
        {center green url}
    {*}$add "Copyright © $year Mark Summerfield.\nAll Rights Reserved.\n" \
        {center green}
    {*}$add "License: GPLv3.\n" {center green}
    {*}$add "[string repeat " " 60]\n" {center hr}
    {*}$add "Tcl/Tk $::tcl_patchLevel (${bits}-bit)\n" center
    if {$distro != ""} { {*}$add "$distro\n" center }
    {*}$add "$::tcl_platform(os) $::tcl_platform(osVersion)\
        ($::tcl_platform(machine))\n" center
}

oo::define AboutForm method AddTextTags txt {
    set margin 12
    $txt configure -font TkTextFont
    set cmd [list $txt tag configure]
    {*}$cmd spaceabove -spacing1 6
    {*}$cmd margins -lmargin1 $margin -lmargin2 $margin -rmargin $margin
    {*}$cmd center -justify center
    {*}$cmd title -foreground navy -font H1
    {*}$cmd gray -foreground gray
    {*}$cmd navy -foreground navy
    {*}$cmd green -foreground darkgreen
    {*}$cmd bold -font bold
    {*}$cmd italic -font italic
    {*}$cmd url -underline true -underlinefg darkgreen
    {*}$cmd hr -overstrike true -overstrikefg lightgray -spacing3 10
}
