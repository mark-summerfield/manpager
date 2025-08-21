# Copyright © 2025 Mark Summerfield. All rights reserved.

package require autoscroll 1
package require tooltip 2
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
    catch {wm iconphoto . -default [ui::icon icon.svg]}
    make_fonts [$Cfg fontfamily] [$Cfg fontsize]
}

oo::define App method make_widgets {} {
    ttk::frame .top
    ttk::panedwindow .hsplit -orient horizontal
    my make_controls
    my make_tree
    my make_view
}

oo::define App method make_controls {} {
    set tip tooltip::tooltip
    ttk::label .top.findLabel -text Find -underline 0 -compound left \
        -image [ui::icon edit-find.svg $::ICON_SIZE]
    set FindEntry [ttk::entry .top.findEntry]
    $tip .top.findEntry "Text to find; press Enter to start the search or\
        F3 to continue the search."
    ttk::radiobutton .top.findApropos -text Apropos -underline 0 \
        -variable [my varname FindWhat] -value apropos
    $tip .top.findApropos "Search man page names and short descriptions."
    ttk::radiobutton .top.findFreeText -text Text -underline 0 \
        -variable [my varname FindWhat] -value freetext
    $tip .top.findFreeText "Search all man page text—slow!"
    ttk::radiobutton .top.findName -text Name -underline 0 \
        -variable [my varname FindWhat] -value name
    $tip .top.findName "Search the tree of man pages."
    ttk::button .top.configButton -text Config… -underline 0 \
        -compound left -command [callback on_config] \
        -image [ui::icon preferences-system.svg $::MENU_ICON_SIZE]
    $tip .top.configButton "Show configuration dialog."
    ttk::button .top.aboutButton -text About -underline 1 -compound left \
        -image [ui::icon about.svg $::MENU_ICON_SIZE] \
        -command [callback on_about]
    $tip .top.aboutButton "About Manpager."
    ttk::button .top.quitButton -text Quit -underline 0 -compound left \
        -image [ui::icon shutdown.svg $::MENU_ICON_SIZE] \
        -command [callback on_quit]
    $tip .top.quitButton "Save config and quit."
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
    set View [text $right.view -font Mono -undo false -wrap none -tabs 1i]
    pack $View -fill both -expand true
    $View tag configure header -foreground darkblue -background lightcyan \
        -underline false
    $View tag configure footer -foreground gray25 -background gray85 \
        -underline false
    $View tag configure bold -font MonoBold -foreground blue
    $View tag configure option -font MonoBold -foreground green
    $View tag configure subhead -font MonoBold -foreground navy
    $View tag configure italic -font MonoItalic -foreground green
    $View tag configure manlink -foreground darkcyan -underline true
    $View tag configure url -foreground brown -underline true
    ui::scrollize $right view both
    .hsplit add $right
}

oo::define App method make_layout {} {
    const opts "-pady 3 -padx 3"
    pack .top.findLabel -side left {*}$opts
    pack .top.findEntry -fill x -expand true -side left
    pack .top.findApropos -side left
    pack .top.findFreeText -side left
    pack .top.findName -side left
    pack .top.quitButton -side right {*}$opts
    pack .top.aboutButton -side right {*}$opts
    pack .top.configButton -side right {*}$opts
    grid .top -row 0 -column 0 -sticky we
    grid .hsplit -row 1 -column 0 -sticky news
    grid rowconfigure . 1 -weight 1
    grid columnconfigure . 0 -weight 1
}

oo::define App method make_bindings {} {
    bind $Tree <<TreeviewSelect>> [callback on_tree_select]
    bind $View <<Selection>> [callback on_text_select]
    bind .top.findEntry <Return> [callback on_find]
    bind . <F3> [callback on_find]
    bind . <Alt-a> {.top.findApropos invoke}
    bind . <Alt-b> [callback on_about]
    bind . <Alt-c> [callback on_config]
    bind . <Alt-f> {focus .top.findEntry}
    bind . <Alt-m> [callback on_focus_tree]
    bind . <Alt-n> {.top.findName invoke}
    bind . <Alt-q> [callback on_quit]
    bind . <Alt-t> {.top.findFreeText invoke}
    wm protocol . WM_DELETE_WINDOW [callback on_quit]
}
