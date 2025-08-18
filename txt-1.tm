# Copyright © 2025 Mark Summerfield. All rights reserved.

proc make_fonts {family size} {
    font create Mono -family $family -size $size
    font create MonoBold -family [font configure Mono -family] \
        -size $size -weight bold
    font create MonoItalic -family [font configure Mono -family] \
        -size $size -slant italic
    font create MonoBoldItalic -family [font configure Mono -family] \
        -size $size -weight bold -slant italic
}
