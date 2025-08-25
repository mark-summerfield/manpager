#!/usr/bin/env wish9
# Copyright © 2025 Mark Summerfield. All rights reserved.

if {![catch {file readlink [info script]} name]} {
    const APPPATH [file dirname $name]
} else {
    const APPPATH [file normalize [file dirname [info script]]]
}
tcl::tm::path add $APPPATH

package require app
package require app_actions
package require app_ui

const VERSION 1.1.0

set app [App new]
$app show
