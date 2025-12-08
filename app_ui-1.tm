# Copyright © 2025 Mark Summerfield. All rights reserved.

package require autoscroll 1
package require scrollutil_tile 2
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
    wm title . [tk appname]
    wm iconname . [tk appname]
    wm minsize . 640 480
    wm iconphoto . -default [ui::icon icon.svg]
    set config [Config new]
    make_fonts [$config fontfamily] [$config fontsize]
}

oo::define App method make_widgets {} {
    ttk::panedwindow .hsplit -orient horizontal
    my make_controls
    my make_tree
    my make_view
}

oo::define App method make_controls {} {
    set tip tooltip::tooltip
    ttk::label .searchLabel -text Search -underline 1
    set SearchEntry [ttk::entry .searchEntry]
    ui::apply_edit_bindings $SearchEntry
    $tip $SearchEntry "Word to search for to find man pages.\nClick the\
        Search button or Press Enter or F5 to do or redo the search\n(e.g.,\
        after setting Apropos or Text or Name)."
    set SearchCombobox [ttk::combobox .searchWhatCombobox -width 10 \
                        -values {Apropos Text Name}]
    ui::apply_edit_bindings $SearchCombobox
    $SearchCombobox set Apropos
    $SearchCombobox state readonly
    $tip $SearchCombobox "Use:\n  • Apropos to search for a\
        keyword.\n  • Text to search for free text (slow!).\n  • Name to\
        search man page filenames."
    set opts "-compound left -width 9"
    ttk::button .searchButton -text Search -underline 0 \
        -image [ui::icon edit-find.svg $::ICON_SIZE] \
        -command [callback on_search] {*}$opts
    $tip .searchButton "Do or redo the search for man pages."
    ttk::button .randomButton -text Random -underline 0 \
        -image [ui::icon dice.svg $::ICON_SIZE] \
        -command [callback show_random_page] {*}$opts
    $tip .randomButton "Show a randomly chosen man page."
    ttk::button .configButton -text Config… -underline 0 \
        -command [callback on_config] \
        -image [ui::icon preferences-system.svg $::ICON_SIZE] {*}$opts
    $tip .configButton "Show configuration dialog."
    ttk::button .aboutButton -text About -underline 1 \
        -image [ui::icon about.svg $::ICON_SIZE] \
        -command [callback on_about] {*}$opts
    $tip .aboutButton "About Manpager."
    ttk::button .quitButton -text Quit -underline 0 \
        -image [ui::icon shutdown.svg $::ICON_SIZE] \
        -command [callback on_quit] {*}$opts
    $tip .quitButton "Save config and quit."
}

oo::define App method make_tree {} {
    set left [ttk::frame .hsplit.left]
    set TreeLabel [ttk::label $left.viewLabel -text "Man Pages" \
        -underline 0]
    set treeframe [ttk::frame $left.tree]
    set sa [scrollutil::scrollarea $treeframe.sa -xscrollbarmode none]
    set Tree [ttk::treeview $treeframe.sa.tree -selectmode browse \
              -show tree -striped true]
    $sa setwidget $Tree
    pack $sa -fill both -expand 1
    $Tree column #0 -width [font measure TkDefaultFont \
                            "1 Programs/commands nnn"]
    pack $left.viewLabel -side top
    pack $treeframe -fill both -expand true
    .hsplit add $left
}

oo::define App method make_view {} {
    set right [ttk::frame .hsplit.right]
    set rightframe [ttk::frame $right.frame]
    my make_page_view $rightframe
    set bottomframe [ttk::frame $right.bottomframe]
    my make_find_panel $bottomframe
    pack $rightframe -side top -fill both -expand true
    pack $bottomframe -side bottom -fill x
    .hsplit add $right
}

oo::define App method make_page_view rightframe {
    set sa [scrollutil::scrollarea $rightframe.sa]
    set View [text $rightframe.sa.view -font Mono -undo false -wrap none \
                -tabs {2.25i 2.5i 2.75i 3i}]
    $sa setwidget $View
    pack $sa -fill both -expand 1
    $View tag configure sel -selectbackground yellow
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
    $View tag configure stripe -background gray90
    $View tag configure special -foreground gray85 -background gray85
    $View tag configure name -font MonoBold -foreground darkgoldenrod4
}

oo::define App method make_find_panel bottomframe {
    ttk::label $bottomframe.findLabel -text Find -underline 1
    set FindEntry [ttk::entry $bottomframe.findEntry]
    ui::apply_edit_bindings $FindEntry
    tooltip::tooltip $FindEntry "Text to find in the current man\
        page.\nClick the Find button or Press Enter or F3 to do or redo\
        the find."
    ttk::button $bottomframe.findButton -text Find -underline 0 \
        -image [ui::icon edit-find.svg $::ICON_SIZE] -compound left \
        -width 9 -command [callback on_find]
    tooltip::tooltip $bottomframe.findButton "Do or redo the find in\
        the current man page."
    set LinoLabel [ttk::label $bottomframe.lineLabel -relief sunken]
    const opts "-pady 3 -padx 3"
    pack $bottomframe.findLabel -side left {*}$opts
    pack $bottomframe.findEntry -side left -fill both -expand true -padx 3 \
        -pady 9
    pack $bottomframe.findButton -side left {*}$opts
    pack $LinoLabel -side left -fill both -padx 3 -pady 9
}

oo::define App method make_layout {} {
    const opts "-pady 3 -padx 3"
    grid .searchLabel -row 0 -column 0 {*}$opts
    grid .searchEntry -row 0 -column 1 -sticky news -padx 3 -pady 9
    grid .searchWhatCombobox -row 0 -column 2 -sticky news -padx 3 -pady 9
    grid .searchButton -row 0 -column 3 {*}$opts
    grid .randomButton -row 0 -column 4 {*}$opts
    # column 5 is empty — but stretchable!
    grid .configButton -row 0 -column 6 {*}$opts
    grid .aboutButton -row 0 -column 7 {*}$opts
    grid .quitButton -row 0 -column 8 {*}$opts
    grid .hsplit -row 1 -column 0 -columnspan 9 -sticky news
    grid rowconfigure . 1 -weight 1
    grid columnconfigure . 1 -weight 1
    grid columnconfigure . 5 -weight 1
}

oo::define App method make_bindings {} {
    bind $Tree <<TreeviewSelect>> [callback on_tree_select]
    bind $View <<Selection>> [callback on_text_select]
    bind $SearchEntry <Return> [callback on_search]
    bind $FindEntry <Return> [callback on_find]
    bind . <F3> [callback on_find]
    bind . <F5> [callback on_search]
    bind . <Alt-b> [callback on_about]
    bind . <Alt-c> [callback on_config]
    bind . <Alt-e> {focus .searchEntry}
    bind . <Alt-f> [callback on_find]
    bind . <Alt-i> "focus $FindEntry"
    bind . <Alt-m> [callback on_focus_tree]
    bind . <Alt-q> [callback on_quit]
    bind . <Alt-r> [callback show_random_page]
    bind . <Alt-s> [callback on_search]
    wm protocol . WM_DELETE_WINDOW [callback on_quit]
}
