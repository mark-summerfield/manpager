# Copyright © 2025 Mark Summerfield. All rights reserved.

package require inifile
package require ui

oo::class create Config {
    variable Filename
    variable Geometry
    variable FontSize
    variable FontFamily
    variable Page
    variable Path
}

oo::define Config constructor {{filename ""} {geometry ""}} {
    set Filename $filename
    set Geometry $geometry
    set FontSize [expr {2 + [font configure TkFixedFont -size]}]
    set FontFamily [font configure TkFixedFont -family]
    set Page ""
    set Path /usr/share/man
}

oo::define Config classmethod load {} {
    set filename [ui::get_ini_filename]
    set config [Config new]
    $config filename $filename
    if {[file exists $filename] && [file size $filename]} {
        set ini [ini::open $filename -encoding utf-8 r]
        try {
            $config geometry [ini::value $ini General Geometry \
                                [$config geometry]]
            $config fontsize [ini::value $ini General FontSize \
                                [$config fontsize]]
            $config fontfamily [ini::value $ini General FontFamily \
                                [$config fontfamily]]
            $config page [ini::value $ini General Page [$config page]]
            $config path [ini::value $ini General Path [$config path]]
        } finally {
            ini::close $ini
        }
    }
    return $config
}

oo::define Config method save {} {
    set ini [ini::open $Filename -encoding utf-8 w]
    try {
        ini::set $ini General Geometry [wm geometry .]
        ini::set $ini General FontSize [my fontsize]
        ini::set $ini General FontFamily [my fontfamily]
        ini::set $ini General Page [my page]
        ini::set $ini General Path [my path]
        ini::commit $ini
    } finally {
        ini::close $ini
    }
}

oo::define Config method filename {{filename ""}} {
    if {$filename ne ""} { set Filename $filename }
    return $Filename
}

oo::define Config method geometry {{geometry ""}} {
    if {$geometry ne ""} { set Geometry $geometry }
    return $Geometry
}

oo::define Config method fontsize {{fontsize 0}} {
    if {$fontsize > 0} { set FontSize $fontsize }
    return $FontSize
}

oo::define Config method fontfamily {{fontfamily ""}} {
    if {$fontfamily ne ""} { set FontFamily $fontfamily }
    return $FontFamily
}

oo::define Config method path {{path ""}} {
    if {$path ne ""} { set Path $path }
    return $Path
}

oo::define Config method page {{page ""}} {
    if {$page ne ""} { set Page $page }
    return $Page
}

oo::define Config method to_string {} {
    return "Config filename=$Filename geometry=$Geometry\
        fontsize=$FontSize page=$Page path=$Path"
}
