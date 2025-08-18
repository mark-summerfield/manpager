#!/bin/bash
nagelfar.sh \
    | grep -v Unknown.command \
    | grep -v Unknown.variable \
    | grep -v No.info.on.package.*found \
    | grep -v Variable.*is.never.read \
    | grep -v Unknown.subcommand..home..to..file \
    | grep -v Found.constant.*which.is.also.a.variable \
    | grep -v Suspicious.variable.name
du -sh .git
ls -sh .manview.str
clc -s -l tcl
str s
git st
