#!/usr/bin/sh

checkmodule -M -m -o autosign.mod autosign.te
semodule_package -m autosign.mod -o autosign.pp
semodule -X 300 -i autosign.pp
rm autosign.pp autosign.mod