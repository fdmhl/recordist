sr = 48000
ksmps = 16
nchnls = 2
0dbfs = 1

opcode instance, i, 0

iInstance chnget "instance"
iInstance += 1

if iInstance % 10 == 0 then

iInstance += 1

endif

chnset iInstance, "instance"

SInstance sprintf ".%d", iInstance
iInstance strtod SInstance

xout iInstance

endop

alwayson "clock"

chnset 90, "tempo"
chnset 4, "measure"

instr clock

kTempo chnget "tempo"
kMeasure chnget "measure"

chnset kMeasure * 60 / kTempo, "bar"

kBeat metro kTempo/60

chnset kBeat, "beat"

if kBeat == 1 then

kClock chnget "clock"

chnset kClock + 1, "clock"

endif

endin

instr sampler

iInstance instance
p1 init int ( p1 ) + iInstance

iNote nstrnum "sample"
SKit strget p4
iSize init p5
iStep init p6
iSwing init p7

kSwing random 0, 1

kClock chnget "clock"
kMeasure chnget "measure"
kBeat chnget "beat"
kTempo chnget "tempo"

if kBeat == 1 && kClock % kMeasure == int ( iStep ) && kSwing > iSwing then

kSample random 1, iSize
SSample sprintfk "%s.%d.wav", SKit, int ( kSample )

schedulek iNote + iInstance, frac ( iStep ) * 60 / kTempo, 1, SSample, SKit, kClock

endif

endin

instr sample

print p6

SSample strget p4
SChannel strget p5

SLeft strcat SChannel, "/left"
SRight strcat SChannel, "/right"

p3 filelen SSample

aNote [] diskin2 SSample

chnmix aNote [ 0 ], SLeft
chnmix aNote [ 0 ], SRight

endin

chnset 60, "key"

giDrone ftgen 0, 0, 256, 10, 1

instr drone

iInstance instance
p1 init int ( p1 ) + iInstance

SChannel strget p4

SLeft strcat SChannel, "/left"
SRight strcat SChannel, "/right"

iPartials init p5
iDetune init p6
iDistance init p7

if iPartials > 0 then

schedule "drone", 0, -1, SChannel, iPartials - 1, iDetune, iDistance
schedule "drone", 0, -1, SChannel, -iPartials, iDetune, iDistance

endif

kKey chnget "key"
kFrequency = cpsmidinn ( kKey + iDetune + 12 * iPartials )

iPartials = abs ( iPartials )

kBar chnget "bar"

iDistance += 1 + iPartials * 64

aDetune jspline 1, 0, kBar
aFrequency poscil kFrequency, kFrequency * cent ( aDetune * 5 )

kModulator jspline .5, 0, kBar
kModulator += .5

aAmplitude jspline .5, 0, kBar
aAmplitude = ( aAmplitude + .5 ) / iDistance
aAmplitude *= kModulator

aNote foscil aAmplitude, kFrequency, 1, 1, kModulator, giDrone

chnmix aNote, SLeft
chnmix aNote, SRight

aClip jspline .5, 0, kBar
aClip += .5

aSkew jspline .5, 0, kBar
aSkew += .5

aNote squinewave aFrequency, aClip, aSkew

aFilter jspline 1, 0, kBar
aFilter += 1

iFilter init 8

aNote butterlp aNote, cent ( aFilter * 1200 ) * kFrequency * iFilter
aNote butterhp aNote, cent ( aFilter * 1200 ) * kFrequency / iFilter

aNote *= aAmplitude/8

chnmix aNote, SLeft
chnmix aNote, SRight

endin

instr arpeggiator

iInstance instance
p1 init int ( p1 ) + iInstance

SChannel strget p4
iStep init p5

kTempo chnget "tempo"
kBeat chnget "beat"
kMeasure chnget "measure"
kClock chnget "clock"

if kBeat == 1 && kClock % kMeasure == int ( iStep ) then

schedulek "pluck", frac ( iStep ) * 60 / kTempo, 1, SChannel

endif

endin

instr pluck

iInstance instance
p1 init int ( p1 ) + iInstance

SChannel strget p4

SLeft strcat SChannel, "/left"
SRight strcat SChannel, "/right"

iBar chnget "bar"
iRhythm random 4, 6

if iRhythm < 0 then

p3 = 0

else

p3 init iBar / 2 ^ int ( iRhythm )

endif

iAttack init p3/64
iDecay init p3/4
iSustain init 1/64
iRelease init p3/8

aAmplitude madsr iAttack, iDecay, iSustain, iRelease

iKey chnget "key"

iNote random 0, 6
iNote init int ( iNote )

SNote sprintf "note/%d", iNote
iDetune chnget SNote

prints "%s\n", SNote

iOctave random -1, 0
iOctave init 1; int ( iOctave ) * 12

iKey += iDetune + iOctave

print iNote
print iDetune
print iKey

iShift init 64

aFrequency linsegr cpsmidinn ( iKey + 12 ), iAttack / iShift, cpsmidinn ( iKey ), iRelease, cpsmidinn ( iKey - .25 )

aClip jspline .5, 0, iBar
aClip += .5

aSkew jspline .5, 0, iBar
aSkew += .5

aNote squinewave aFrequency, aClip, aSkew
aNote *= aAmplitude

aNote butterlp aNote, aFrequency * 4
aNote butterhp aNote, aFrequency / 1

chnmix aNote, SLeft
chnmix aNote, SRight

endin

instr mix

iInstance instance
p1 init int ( p1 ) + iInstance

SInput strget p4
SOutput strget p5
iLeft init p6 + 1

if p7 == 0 then

p7 init p6

endif

iRight init p7 + 1

SInputLeft strcat SInput, "/left"
SInputRight strcat SInput, "/right"
SOutputLeft strcat SOutput, "/left"
SOutputRight strcat SOutput, "/right"

prints "Mixing from %s and %s to %s and %s\n", SInputLeft, SInputRight, SOutputLeft, SOutputRight

aLeft chnget SInputLeft
aRight chnget SInputRight

aLeft /= iLeft
aRight /= iRight

chnmix aLeft, SOutputLeft
chnmix aRight, SOutputRight

chnclear SInputLeft
chnclear SInputRight

endin

instr output

iInstance instance
p1 init int ( p1 ) + iInstance

SInput strget p4
iDistance init p5 + 1

prints "Output from %s to final destination\n", SInput

SLeft sprintf "%s/left", SInput
SRight sprintf "%s/right", SInput

aLeft chnget SLeft
aRight chnget SRight

aLeft clip aLeft, 1, 1
aRight clip aRight, 1, 1

aLeft /= iDistance
aRight /= iDistance

outs aLeft, aRight

chnclear SLeft
chnclear SRight

endin

instr reverb

iInstance instance
p1 init int ( p1 ) + iInstance

SInput strget p4
SOutput strget p5
iLeft init p6 + 1


if p7 == 0 then

p7 init p6

endif

iRight init p7 + 1

prints "Adding reverb for %s to %s\n", SInput, SOutput

SInputLeft sprintf "%s/left", SInput
SInputRight sprintf "%s/right", SInput
SOutputLeft sprintf "%s/left", SOutput
SOutputRight sprintf "%s/right", SOutput

aLeft chnget SInputLeft
aRight chnget SInputRight

kBar chnget "bar"

kRoom jspline .5, 0, kBar
kRoom += .5

kDamp jspline .5, 0, kBar
kDamp += .5

aReverbLeft, aReverbRight freeverb aLeft, aRight, kRoom, kDamp

aLeft += aReverbLeft / iLeft
aRight += aReverbRight / iRight

aLeft clip aLeft, 1, 1
aRight clip aRight, 1, 1

chnmix aLeft, SOutputLeft
chnmix aRight, SOutputRight

chnclear SInputLeft
chnclear SInputRight

endin

alwayson "keyboard"

instr keyboard

kKey, kPressed sense

if kPressed == 1 then

SKey sprintfk "%c", kKey

schedulek SKey, 0, 0

endif

endin

chnset .5, "tempo-shift"

instr a

iTempo chnget "tempo"
iShift chnget "tempo-shift"

chnset iTempo - iShift, "tempo"

endin

instr d

iTempo chnget "tempo"
iShift chnget "tempo-shift"

chnset iTempo + iShift, "tempo"

endin

instr q

iKey chnget "key"
chnset iKey - .5, "key"

endin

instr e

iKey chnget "key"
chnset iKey + .5, "key"

endin

chnset 1, "maqam/index"

opcode maqam, 0, i

iShift xin

iIndex chnget "maqam/index"
iCount chnget "maqam/count"

iIndex += iShift

if iIndex < 0 then

iIndex init 0

elseif iIndex >= iCount then

iIndex init iCount - 1

endif

SIndex sprintf "maqam/%d", iIndex

SMaqam chnget SIndex

schedule SMaqam, 0, 0

chnset iIndex, "maqam/index"

endop

instr z

maqam -1

endin

instr c

maqam 1

endin

#define mix #schedule "mix", 0, -1,#
#define reverb #schedule "reverb", 0, -1,#
#define output #schedule "output", 0, -1,#

$output "output", 0

$mix "drone", "drone-reverb"
$reverb "drone-reverb", "drone-final"
$mix "drone-final", "output", 8

$mix "arpeggiator", "arpeggiator/reverb"
$reverb "arpeggiator/reverb", "arpeggiator/final", 2
$mix "arpeggiator/final", "output", 2

$mix "dom", "percussion"
$mix "dem", "percussion"
$mix "tak", "percussion"
$mix "sak", "percussion", 1
$mix "sagat", "percussion", 2
$mix "claps", "percussion"

$mix "percussion", "output", 1

#define drone #schedule "drone", 0, -1, "drone", 0,#
#define arpeggiator #schedule "arpeggiator", 0, -1, "arpeggiator",#

#define dom #schedule "sampler", 0, -1, "dom", 24,#
#define dem #schedule "sampler", 0, -1, "dem", 24,#

#define tak #schedule "sampler", 0, -1, "tak", 24,#
#define sak #schedule "sampler", 0, -1, "sak", 24,#
#define sagat #schedule "sampler", 0, -1, "sagat", 24,#
#define claps #schedule "sampler", 0, -1, "claps", 4,#

$drone 0

iNote init 0
iChord init 1

while iNote < iChord do

$arpeggiator 0

$arpeggiator .5
$arpeggiator .75

$arpeggiator 1.25
$arpeggiator 1.5

$arpeggiator 2

$arpeggiator 2.5
$arpeggiator 2.75
$arpeggiator 3

iNote += 1

od

$dom 0

$sak .5, 1/2

$tak .75

$sak 1.25, 1/4

$tak 1.5

$dem 2

$sak 2.25, 1/4

$dem 2.5

$tak 3

$sak 3.5, 1/4
$sak 3.75, 1/2

$sagat 0, 1/4
$sagat 1, 1/4
$sagat 2, 1/4
$sagat 3, 1/4

$claps .5, 1/4
$claps 1.5, 1/4
$claps 2.5, 1/4
$claps 3.5, 1/4

#include "maqam.index"

SMaqam chnget "maqam/1"

schedule SMaqam, 0, 0
