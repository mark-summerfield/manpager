# Copyright © 2025 Mark Summerfield. All rights reserved.

proc commas n {regsub -all {\d(?=(\d{3})+($|\.))} $n {\0,}}

proc lrandom lst { lindex $lst [expr {int(rand() * [llength $lst])}] }

proc uid {} { return #[string range [clock clicks] end-8 end] }

oo::class create Ref {
    variable Value
    constructor value { set Value $value }
    method get {} { return $Value }
    method set value { set Value $value }
}
