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
}

proc text_apply_links txt {
    foreach i1 [$txt search -all -regexp {\w+\(\d\)} 1.0] {
        set i2 "$i1 wordend + 3 chars"
        $txt tag add manlink $i1 $i2
    }
    foreach i1 [$txt search -all -regexp {https?://} 1.0] {
        set i2 [$txt search -regexp {[\s>]} $i1]
        $txt tag add url $i1 $i2
    }
}
