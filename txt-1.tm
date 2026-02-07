# Copyright © 2025 Mark Summerfield. All rights reserved.

proc make_fonts {family size} {
    foreach name {Mono MonoBold MonoItalic} { catch { font delete $name } }
    font create Mono -family $family -size $size
    font create MonoBold -family [font configure Mono -family] \
        -size $size -weight bold
    font create MonoItalic -family [font configure Mono -family] \
        -size $size -slant italic
}

# convert _^Hc to italic c and c^Hc to bold c
proc text_replace_ctrl_h txt {
    set j 1.0
    while {$j ne ""} {
        set j [$txt search "\x08" $j end]
        if {$j eq ""} { break }
        set i [$txt index "$j -1 char"]
        set k [$txt index "$j +1 char"]
        set tag [expr {[$txt get $i] eq "_" ? "italic" : "bold"}]
        $txt tag add $tag $k
        $txt delete $i $k
        set j $k
    }
    foreach {i j} [$txt tag ranges bold] {
        set word [$txt get $i $j]
        if {[string match {-*} $word]} { ;# -o or --option
            $txt tag remove bold $i $j
            $txt tag add option $i $j
        } elseif {[regexp {^\d+\.0$} $i]} { ;# at start of line
            $txt tag remove bold $i $j
            $txt tag add subhead $i "$i lineend"
        }
    }
}

proc text_apply_styles txt {
    foreach i [$txt search -all -regexp {[-.:\w]+\(\d[^)]*?\)} 1.0] {
        set j [$txt search ) $i "$i lineend"]
        $txt tag add manlink $i "$j + 1 char"
    }
    foreach i [$txt search -all -regexp {https?://} 1.0] {
        set j [$txt search -regexp {[\s>]} $i]
        $txt tag add url $i $j
    }
    set last [$txt index "end -1 line"]
    $txt tag remove manlink 1.0 1.end
    $txt tag remove url 1.0 1.end
    $txt tag remove manlink $last end
    $txt tag remove url $last end
    $txt tag add header 1.0 1.end
    $txt tag add footer $last end
    set i [$txt search -exact NAME 1.0 10.0]
    if {$i ne ""} {
        set i [$txt index "$i + 1 line"]
        $txt tag add name $i "$i lineend"
    }
}

proc text_stripe txt {
    set pos 1.0
    while {[$txt compare $pos < end]} {
        set pos [$txt index "$pos +2 lines"]
        $txt tag add stripe $pos "$pos lineend"
    }
}
