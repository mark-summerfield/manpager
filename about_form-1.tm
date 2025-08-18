# Copyright © 2025 Mark Summerfield. All rights reserved.

package require form
package require ui

namespace eval about_form {}

proc about_form::show_modal {} {
    make_widgets 
    make_layout
    make_bindings
    form::prepare .about { about_form::on_close }
    form::show_modal .about
}

proc about_form::make_widgets {} {
    tk::toplevel .about
    wm title .about "[tk appname] — About"
    wm resizable .about false false
    set height 14
    tk::text .about.text -width 50 -height $height -wrap word \
        -background "#F0F0F0" -spacing3 3
    populate_about_text
    .about.text configure -state disabled
    ttk::button .about.close_button -text Close -compound left \
        -image [ui::icon close.svg $::ICON_SIZE] \
        -command { about_form::on_close }
}


proc about_form::make_layout {} {
    grid .about.text -sticky nsew -pady 3
    grid .about.close_button -pady 3
}


proc about_form::make_bindings {} {
    bind .about <Escape> { about_form::on_close }
    bind .about <Return> { about_form::on_close }
    .about.text tag bind url <Double-1> {
        about_form::on_click_url @%x,%y
    }
}


proc about_form::on_click_url index {
    set indexes [.about.text tag prevrange url $index]
    set url [string trim [.about.text get {*}$indexes]]
    if {$url ne ""} {
        if {![string match -nocase http*://* $url]} {
            set url [string cat http:// $url]
        }
        ui::open_webpage $url
    }
}


proc about_form::on_close {} { form::delete .about }


proc about_form::populate_about_text {} {
    set txt .about.text
    add_text_tags $txt
    set img [$txt image create end -align center \
             -image [ui::icon icon.svg 64]]
    $txt tag add spaceabove $img
    $txt tag add center $img
    set cmd [list $txt insert end]
    {*}$cmd "\nManview $::VERSION\n" {center title}
    {*}$cmd "A Unix man page viewer.\n\n" {center navy}
    set year [clock format [clock seconds] -format %Y]
    if {$year > 2025} { set year "2025-[string range $year end-1 end]" }
    set bits [expr {8 * $::tcl_platform(wordSize)}]
    set distro [exec lsb_release -ds]
    {*}$cmd "https://github.com/mark-summerfield/manview\n" \
        {center green url}
    {*}$cmd "Copyright © $year Mark Summerfield.\nAll Rights Reserved.\n" \
        {center green}
    {*}$cmd "License: GPLv3.\n" {center green}
    {*}$cmd "[string repeat " " 60]\n" {center hr}
    {*}$cmd "Tcl/Tk $::tcl_patchLevel (${bits}-bit)\n" center
    if {$distro != ""} { {*}$cmd "$distro\n" center }
    {*}$cmd "$::tcl_platform(os) $::tcl_platform(osVersion)\
        ($::tcl_platform(machine))\n" center
}

proc about_form::add_text_tags txt {
    set margin 12
    $txt configure -font TkTextFont
    set cmd [list $txt tag configure]
    {*}$cmd spaceabove -spacing1 6
    {*}$cmd margins -lmargin1 $margin -lmargin2 $margin -rmargin $margin
    {*}$cmd center -justify center
    {*}$cmd title -foreground navy -font H1
    {*}$cmd navy -foreground navy
    {*}$cmd green -foreground darkgreen
    {*}$cmd bold -font bold
    {*}$cmd italic -font italic
    {*}$cmd url -underline true -underlinefg darkgreen
    {*}$cmd hr -overstrike true -overstrikefg lightgray -spacing3 10
}
