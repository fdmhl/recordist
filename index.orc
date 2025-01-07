sr = 48000
ksmps = 32
nchnls = 1
0dbfs = 1

chnset 120, "tempo"
chnset 4, "measure"

opcode instance, i, 0

iInstance chnget "instance"
iInstance += 1

if iInstance % 10 == 0 then

iInstance += 1

endif

chnset iInstance, "instance"

SInstance sprintf ".%d", iInstance
iInstance strtod SInstance

print p1

xout iInstance

endop

schedule "refresh", 0, 0

instr refresh

iTempo chnget "tempo"
iMeasure chnget "measure"

chnset iMeasure * 60 / iTempo, "bar"

print iTempo

endin

gkClock init 0

alwayson "keyboard"

instr beat

iInstance instance
p1 init int ( p1 ) + iInstance

iNote nstrnum "sample"
SKit strget p4
iSize init p5
iStep init p6

kBar chnget "bar"

gkClock metro 1 / kBar

if gkClock == 1 then

kSample random 1, iSize
SSample sprintfk "%s.%d.wav", SKit, int ( kSample )

kBar chnget "bar"

schedulek iNote + frac ( p1 ), iStep * kBar, kBar, SSample, SKit

endif

endin

instr sample

SSample strget p4
SChannel strget p5

p3 filelen SSample

aNote [] diskin2 SSample

chnmix aNote [ 0 ], SChannel

endin

instr mix

iInstance instance
p1 init int ( p1 ) + iInstance

print p1

SChannel strget p4
iDistance init p5

aNote chnget SChannel
aNote clip aNote, 1, 1
aNote /= ( abs ( iDistance ) + 1 )

if iDistance < 0 then

out aNote

else

chnmix aNote, "mix"

endif

chnclear SChannel

endin

instr keyboard

kKey, kPressed sense

if kPressed == 1 then

SKey sprintfk "%c", kKey

schedulek SKey, 0, 0

endif

endin

instr a

iTempo chnget "tempo"
chnset iTempo - .5, "tempo"

schedule "refresh", 0, 0

endin

instr d

iTempo chnget "tempo"
chnset iTempo + .5, "tempo"

schedule "refresh", 0, 0

endin

schedule "mix", 0, -1, "mix", -1
schedule "mix", 0, -1, "dom"
schedule "mix", 0, -1, "tak"

#define dom #schedule "beat", 0, -1, "dom", 24,#
#define tak #schedule "beat", 0, -1, "tak", 24,#
#define claps #schedule "beat", 0, -1, "claps", 4,#

$dom 0
$tak 1/8
$tak 3/8
$dom 4/8
$tak 6/8
