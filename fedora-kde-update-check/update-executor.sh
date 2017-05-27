#!/bin/sh

nice -15 dnf --assumeyes -v update >dnf.log 2>dnf-error.log