# Copyright © 2025 Mark Summerfield. All rights reserved.

proc commas n {regsub -all {\d(?=(\d{3})+($|\.))} $n {\0,}}

proc lrandom lst { lindex $lst [expr {int(rand() * [llength $lst])}] }
