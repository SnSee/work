#!/bin/csh -f

source {{ sourceme }}

# generate dspf
setenv MGC_HOME {{ MGC_HOME }}
$MGC_HOME/bin/calibre -lvs -hier -turbo 2 -nowait {{ xact }}
$MGC_HOME/bin/calibre -xact -rc -turbo 2 -nowait {{ xact }}

# simulate
{{ spectre }} {{ cell }}_post.sp -format psfxl -raw {{ cell }}_post.raw ++aps +emir=emir.conf +ms +mt=64 -64 +speed=2

