# Copyright © 2025 Mark Summerfield. All rights reserved.

package require autoscroll 1
package require shtmlview::shtmlview 1
package require txt
package require ui

oo::define App method make_ui {} {
    my prepare_ui
    my make_widgets
    my make_layout
    my make_bindings
}

oo::define App method prepare_ui {} {
    wm withdraw .
    wm title . [tk appname]
    wm iconname . [tk appname]
    wm minsize . 640 480
    catch {wm iconphoto . -default [image create photo -file \
                                    $::APPPATH/images/icon.svg]}
    make_fonts [$Cfg fontfamily] [$Cfg fontsize]
}

oo::define App method make_widgets {} {
    ttk::frame .top
    ttk::label .top.findLabel -text Find -underline 0
    ttk::entry .top.findEntry -width 40
    ttk::radiobutton .top.findApropos -text Apropos -underline 0 \
        -variable [my variable FindWhat] -value apropos
    ttk::radiobutton .top.findFreeText -text Text -underline 0 \
        -variable [my variable FindWhat] -value freetext
    ttk::radiobutton .top.findName -text Name -underline 0 \
        -variable [my variable FindWhat] -value name
    ttk::button .top.aboutButton -text About -underline 1 \
        -command [callback on_about]
    ttk::panedwindow .hsplit -orient horizontal
    my make_tree
    my make_view
}

oo::define App method make_tree {} {
    set left [ttk::frame .hsplit.left]
    ttk::label $left.viewLabel -text "Man Pages" -underline 0
    set treeframe [ttk::frame $left.tree]
    set name tree
    set Tree [ttk::treeview $treeframe.$name -selectmode browse -show tree \
              -striped true]
    ui::scrollize $treeframe $name vertical
    pack $left.viewLabel -side top
    pack $treeframe -fill both -expand true
    .hsplit add $left
}

oo::define App method make_view {} {
    set right [ttk::frame .hsplit.right]
    set View [shtmlview::shtmlview $right.view -closebutton false \
                -toolbar false]
    pack $View -fill both -expand true
    # TODO none of these work
    # $View helptext tag configure mono -font Mono
    # $View helptext tag configure bold -font MonoBold
    # $View helptext tag configure italic -font MonoItalic
    # $View helptext tag configure bolditalic -font MonoBoldItalic
    .hsplit add $right
}

oo::define App method make_layout {} {
    pack .top.findLabel -side left -pady 3 -padx 3
    pack .top.findEntry -fill x -side left
    pack .top.findApropos -side left
    pack .top.findFreeText -side left
    pack .top.findName -side left
    pack .top.aboutButton -side right -pady 3 -padx 3
    grid .top -row 0 -column 0 -sticky we
    grid .hsplit -row 1 -column 0 -sticky news
    grid rowconfigure . 1 -weight 1
    grid columnconfigure . 0 -weight 1
}

oo::define App method make_bindings {} {
    bind $Tree <<TreeviewSelect>> [callback on_tree_select]
    bind . <Escape> [callback on_quit]
    bind .top.findEntry <Return> [callback on_find]
    bind . <F3> [callback on_find]
    bind . <Alt-a> {.top.findApropos invoke}
    bind . <Alt-b> [callback on_about]
    bind . <Alt-f> {focus .top.findEntry}
    bind . <Alt-m> [callback on_focus_tree]
    bind . <Alt-n> {.top.findName invoke}
    bind . <Alt-t> {.top.findFreeText invoke}
    wm protocol . WM_DELETE_WINDOW [callback on_quit]
}
