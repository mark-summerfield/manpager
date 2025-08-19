# Copyright © 2025 Mark Summerfield. All rights reserved.

proc make_fonts {family size} {
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
        if {[string match {-*} $word]} {
            $txt tag remove bold $i $j
            $txt tag add option $i $j
        } elseif {[regexp {^\d+\.0$} $i]} {
            $txt tag remove bold $i $j
            $txt tag add subhead $i "$i lineend"
        }
    }
}

proc text_apply_styles txt {
    foreach i [$txt search -all -regexp {[-\w]+\(\d\)} 2.0] {
        set j "$i wordend + 3 chars"
        $txt tag add manlink $i $j
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
}
