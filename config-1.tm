# Copyright © 2025 Mark Summerfield. All rights reserved.

package require inifile
package require util

# Also handles tk scaling
oo::class create Config {
    variable Filename
    variable Blinking
    variable Geometry
    variable FontFamily
    variable FontSize
    variable RandomStartPage
    variable Path
    variable Page
}

oo::define Config constructor {{filename ""} {geometry ""}} {
    set Filename $filename
    set Blinking true
    set Geometry $geometry
    set FontFamily [font configure TkFixedFont -family]
    set FontSize [expr {2 + [font configure TkFixedFont -size]}]
    set RandomStartPage true
    set Path /usr/share/man
    set Page ""
}

oo::define Config classmethod load {} {
    set filename [util::get_ini_filename]
    set config [Config new]
    $config set_filename $filename
    if {[file exists $filename] && [file size $filename]} {
        set ini [ini::open $filename -encoding utf-8 r]
        try {
            tk scaling [ini::value $ini General Scale 1.0]
            $config set_blinking [ini::value $ini General Blinking \
                                    [$config blinking]]
            if {![$config blinking]} {
                option add *insertOffTime 0
                ttk::style configure . -insertofftime 0
            }
            $config set_geometry [ini::value $ini General Geometry \
                [$config geometry]]
            $config set_fontfamily [ini::value $ini General FontFamily \
                [$config fontfamily]]
            $config set_fontsize [ini::value $ini General FontSize \
                [$config fontsize]]
            $config set_randomstartpage [ini::value $ini General \
                RandomStartPage [$config randomstartpage]]
            $config set_path [ini::value $ini General Path [$config path]]
            $config set_page [ini::value $ini General Page [$config page]]
        } on error err {
            puts "invalid config in '$filename'; using defaults: $err"
        } finally {
            ini::close $ini
        }
    }
    return $config
}

oo::define Config method save {} {
    set ini [ini::open $Filename -encoding utf-8 w]
    try {
        ini::set $ini General Scale [tk scaling]
        ini::set $ini General Blinking [my blinking]
        ini::set $ini General Geometry [wm geometry .]
        ini::set $ini General FontFamily [my fontfamily]
        ini::set $ini General FontSize [my fontsize]
        ini::set $ini General RandomStartPage [my randomstartpage]
        ini::set $ini General Path [my path]
        ini::set $ini General Page [my page]
        ini::commit $ini
    } finally {
        ini::close $ini
    }
}

oo::define Config method filename {} { return $Filename }
oo::define Config method set_filename filename { set Filename $filename }

oo::define Config method blinking {} { return $Blinking }
oo::define Config method set_blinking blinking { set Blinking $blinking }

oo::define Config method geometry {} { return $Geometry }
oo::define Config method set_geometry geometry { set Geometry $geometry }

oo::define Config method fontsize {} { return $FontSize }
oo::define Config method set_fontsize fontsize { set FontSize $fontsize }

oo::define Config method fontfamily {} { return $FontFamily }
oo::define Config method set_fontfamily fontfamily {
    set FontFamily $fontfamily
}

oo::define Config method randomstartpage {} { return $RandomStartPage }
oo::define Config method set_randomstartpage randomstartpage {
    set RandomStartPage $randomstartpage
}

oo::define Config method path {} { return $Path }
oo::define Config method set_path path { set Path $path }

oo::define Config method page {} { return $Page }
oo::define Config method set_page page { set Page $page }

oo::define Config method to_string {} {
    return "Config filename=$Filename blinking=$Blinking\
        scaling=[tk scaling] geometry=$Geometry fontfamily=$FontFamily\
        fontsize=$FontSize page=$Page path=$Path\
        randomstartpage=$RandomStartPage"
}
