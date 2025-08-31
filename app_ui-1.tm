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
    ttk::label .top.findLabel -text Find -underline 0
    set FindEntry [ttk::entry .top.findEntry]
    $tip $FindEntry "Word to find.\nClick Search or Press\
        Enter or F3 to do or redo the search\n(e.g.,\
        after setting Apropos or Text or Name)."
    set FindCombobox [ttk::combobox .top.findWhatCombobox -width 10 \
                      -values {Apropos Text Name}]
    $FindCombobox set Apropos
    $FindCombobox state readonly
    $tip $FindCombobox "• Apropos to search for a keyword.\n• Text to\
        search for free text (slow!).\n• Name to search man page filenames."
    set opts "-compound left -width 9"
    ttk::button .top.searchButton -text Search -underline 0 \
        -image [ui::icon edit-find.svg $::ICON_SIZE] \
        -command [callback on_find] {*}$opts
    $tip .top.searchButton "Do or redo the search for the word to find."
    ttk::button .top.randomButton -text Random -underline 0 \
        -image [ui::icon dice.svg $::ICON_SIZE] \
        -command [callback show_random_page] {*}$opts
    $tip .top.searchButton "Do or redo the search for the word to find."
    ttk::button .top.configButton -text Config… -underline 0 \
        -command [callback on_config] \
        -image [ui::icon preferences-system.svg $::ICON_SIZE] {*}$opts
    $tip .top.configButton "Show configuration dialog."
    ttk::button .top.aboutButton -text About -underline 1 \
        -image [ui::icon about.svg $::ICON_SIZE] \
        -command [callback on_about] {*}$opts
    $tip .top.aboutButton "About Manpager."
    ttk::button .top.quitButton -text Quit -underline 0 \
        -image [ui::icon shutdown.svg $::ICON_SIZE] \
        -command [callback on_quit] {*}$opts
    $tip .top.quitButton "Save config and quit."
}

oo::define App method make_tree {} {
    set left [ttk::frame .hsplit.left]
    set TreeLabel [ttk::label $left.viewLabel -text "Man Pages" \
        -underline 0]
    set treeframe [ttk::frame $left.tree]
    set name tree
    set Tree [ttk::treeview $treeframe.$name -selectmode browse -show tree \
              -striped true]
    $Tree column #0 -width [font measure TkDefaultFont \
                            "1 Programs/commands nnn"]
    ui::scrollize $treeframe $name vertical
    pack $left.viewLabel -side top
    pack $treeframe -fill both -expand true
    .hsplit add $left
}

oo::define App method make_view {} {
    set right [ttk::frame .hsplit.right]
    set View [text $right.view -font Mono -undo false -wrap none \
                -tabs {2.25i 2.5i 2.75i 3i}]
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
    $View tag configure stripe -background gray90
    $View tag configure special -foreground gray85 -background gray85
    ui::scrollize $right view both
    .hsplit add $right
}

oo::define App method make_layout {} {
    const opts "-pady 3 -padx 3"
    pack .top.findLabel -side left {*}$opts
    pack .top.findEntry -side left
    pack .top.findWhatCombobox -side left {*}$opts
    pack .top.searchButton -side left {*}$opts
    pack .top.randomButton -side left {*}$opts
    pack [ttk::frame .top.pad] -side left -expand true
    pack .top.configButton -side left {*}$opts
    pack .top.aboutButton -side left {*}$opts
    pack .top.quitButton -side left {*}$opts
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
    bind . <Alt-b> [callback on_about]
    bind . <Alt-c> [callback on_config]
    bind . <Alt-f> {focus .top.findEntry}
    bind . <Alt-m> [callback on_focus_tree]
    bind . <Alt-q> [callback on_quit]
    bind . <Alt-r> [callback show_random_page]
    bind . <Alt-s> [callback on_find]
    wm protocol . WM_DELETE_WINDOW [callback on_quit]
}
