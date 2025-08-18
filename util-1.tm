# Copyright © 2025 Mark Summerfield. All rights reserved.

proc lrandom lst { lindex $lst [expr {int(rand() * [llength $lst])}] }
