sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

chnset 90, "tempo"
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

xout iInstance

endop

schedule "refresh", 0, 0

instr refresh

iTempo chnget "tempo"
iMeasure chnget "measure"

chnset iMeasure * 60 / iTempo, "bar"

print iTempo

endin

alwayson "keyboard"

instr sampler

iInstance instance
p1 init int ( p1 ) + iInstance

iNote nstrnum "sample"
SKit strget p4
iSize init p5
iStep init p6
iSwing init p7

kBar chnget "bar"
kSwing random 0, 1
kClock metro 1 / kBar

if kClock == 1 && kSwing > iSwing then

kSample random 1, iSize
SSample sprintfk "%s.%d.wav", SKit, int ( kSample )

kBar chnget "bar"

schedulek iNote + frac ( p1 ), iStep * kBar, kBar, SSample, SKit

endif

endin

instr sample

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

aModulator poscil .25, 1/kBar
aModulator += .35

aAmplitude jspline .5, 0, kBar
aAmplitude = ( aAmplitude + .5 ) / iDistance
aAmplitude *= aModulator

aDetune jspline 1, 0, kBar
aFrequency poscil kFrequency, kFrequency * cent ( aDetune * 5 )

aNote poscil aAmplitude, aFrequency

chnmix aNote, SLeft
chnmix aNote, SRight

aClip jspline .5, 0, kBar
aClip += .5

aSkew jspline .5, 0, kBar
aSkew += .5

aNote squinewave aFrequency, aClip, aSkew

aNote butterlp aNote, kFrequency/2

aNote *= aAmplitude/8

chnmix aNote, SLeft
chnmix aNote, SRight

endin

instr arpeggiator

iInstance instance
p1 init int ( p1 ) + iInstance

SChannel strget p4
iStep init p5

kBar chnget "bar"
kClock metro 1/kBar

if kClock == 1 then

schedulek "pluck", iStep * kBar, 1, SChannel

endif

endin

instr pluck

iInstance instance
p1 init int ( p1 ) + iInstance

SChannel strget p4

SLeft strcat SChannel, "/left"
SRight strcat SChannel, "/right"

iBar chnget "bar"
iRhythm random 2, 6

if iRhythm < 0 then

p3 = 0

else

p3 init iBar / 2 ^ int ( iRhythm )

endif

iAttack init 1/128
iDecay init 1/32
iSustain init 1/8
iRelease init p3 - iAttack - iDecay

aAmplitude adsr iAttack, iDecay, iSustain, iRelease

iKey chnget "key"
iNote random -7, 19
iNote init int ( iNote )

if iNote < 0 then

iPitch init iNote + 12

else

iPitch init iNote % 12

endif

SNote sprintf "note/%d", iPitch
iDetune chnget SNote

if iNote < 0 then

iDetune -= 12

elseif iNote >= 12 then

iDetune += 12

endif

iKey += int ( iDetune )

iShift init 64

aFrequency linseg cpsmidinn ( iKey ), iAttack / iShift, cpsmidinn ( iKey + 12 ), iDecay / iShift, cpsmidinn ( iKey ), iRelease * iShift, cpsmidinn ( iKey - .25 )

aClip jspline .5, 0, iBar
aClip += .5

aSkew jspline .5, 0, iBar
aSkew += .5

aNote squinewave aFrequency, aClip, aSkew
aNote *= aAmplitude

aNote butterlp aNote, aFrequency

chnmix aNote, SLeft
chnmix aNote, SRight

aNote squinewave aFrequency/2, aClip, aSkew
aNote *= aAmplitude/8

aNote butterlp aNote, aFrequency

chnmix aNote, SLeft
chnmix aNote, SRight

aNote squinewave aFrequency*2, aClip, aSkew
aNote *= aAmplitude/2

aNote butterlp aNote, aFrequency

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

instr keyboard

kKey, kPressed sense

if kPressed == 1 then

SKey sprintfk "%c", kKey

schedulek SKey, 0, 0

endif

endin

instr a

iTempo chnget "tempo"
chnset iTempo - 5, "tempo"

schedule "refresh", 0, 0

endin

instr d

iTempo chnget "tempo"
chnset iTempo + 5, "tempo"

schedule "refresh", 0, 0

endin

instr q

iKey chnget "key"
chnset iKey - .5, "key"

endin

instr e

iKey chnget "key"
chnset iKey + .5, "key"

endin

#define mix #schedule "mix", 0, -1,#
#define reverb #schedule "reverb", 0, -1,#
#define output #schedule "output", 0, -1,#

$output "output", 1

$mix "drone", "drone-reverb"
$reverb "drone-reverb", "drone-final"
$mix "drone-final", "output", 2

$mix "arpeggiator", "arpeggiator-reverb", 0
$reverb "arpeggiator-reverb", "arpeggiator-final", 8
$mix "arpeggiator-final", "output", 2

$mix "dom", "output"
$mix "tak", "output"
$mix "sak", "output", 1
$mix "sagat", "output", 2
$mix "claps", "output"

#define drone #schedule "drone", 0, -1, "drone", 4,#
#define arpeggiator #schedule "arpeggiator", 0, -1, "arpeggiator",#
#define dom #schedule "sampler", 0, -1, "dom", 24,#
#define tak #schedule "sampler", 0, -1, "tak", 24,#
#define sak #schedule "sampler", 0, -1, "sak", 24,#
#define sagat #schedule "sampler", 0, -1, "sagat", 24,#
#define claps #schedule "sampler", 0, -1, "claps", 4,#

$drone 0
$drone -12, 8
$drone 12, 8
$drone 3, 8
$drone 8, 8

iNote init 0
iChord init 3

while iNote < iChord do

$arpeggiator 0/8

$arpeggiator 1/8
$arpeggiator 1.5/8

$arpeggiator 3/8
$arpeggiator 2.5/8

$arpeggiator 4/8

$arpeggiator 5/8
$arpeggiator 5.5/8
$arpeggiator 6/8

iNote += 1

od

$dom 0
$sak 1/8, 1/2
$tak 1.5/8
$sak 2.5/8, 1/4
$tak 3/8
$dom 4/8
$tak 5/8
$sak 5.5/8, 1/4
$tak 6/8
$sak 7/8, 1/4
$sak 7.5/8, 1/2

$sagat 0/4, 1/4
$sagat 1/4, 1/4
$sagat 2/4, 1/4
$sagat 3/4, 1/4

$claps 1/8, 1/4
$claps 3/8, 1/4
$claps 5/8, 1/4
$claps 7/8, 1/4

chnset 0, "note/0"
chnset 2.25, "note/1"
chnset 2.25, "note/2"
chnset 3, "note/3"
chnset 3, "note/4"
chnset 5, "note/5"
chnset 7.25, "note/6"
chnset 7.25, "note/7"
chnset 8, "note/8"
chnset 8, "note/9"
chnset 11.25, "note/10"
chnset 11.25, "note/11"

chnset 0, "note/0"
chnset 2, "note/1"
chnset 2, "note/2"
chnset 4, "note/3"
chnset 4, "note/4"
chnset 5, "note/5"
chnset 7, "note/6"
chnset 7, "note/7"
chnset 9, "note/8"
chnset 9, "note/9"
chnset 11, "note/10"
chnset 11, "note/11"
