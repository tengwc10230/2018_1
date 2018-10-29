#!/bin/sh

ls -ARl | sort -k5nr | grep '^-\|^d' | awk '{if ($1~/^-/){sum += $5; file++; if(file <= 5 ) print file":"$5,$9;}}END{print "Dir num: "NR-file"\n" "File num: "file "\n" "Total: "sum}'
