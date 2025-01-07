
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giStrikeFT ftgen 0, 0, 256, 1, "prerequisites/marmstk1.wav", 0, 0, 0
giVibratoFT ftgen 0, 0, 128, 10, 1

instr 13, tak

aNote = 0

iPitch init p4/p5

iAttack init 1/128
iDecay init 1/64 
iRelease init 1/64

p3 init iAttack + iDecay + iRelease

aLowSubAmplitude linseg 0, iAttack, 1, iDecay, .05, iRelease, 0
aLowSubFrequency linseg cpsoct ( 12 + iPitch ), iAttack/1, cpsoct ( 7 + iPitch )

aLowSub poscil aLowSubAmplitude, aLowSubFrequency

aNote += aLowSub

aHighSubAmplitude linseg 0, iAttack, 1, iDecay/8, .25, iRelease/8, 0
aHighSubFrequency linseg cpsoct ( 14 + iPitch ), iAttack/1, cpsoct ( 8 + iPitch )

aHighSub poscil aHighSubAmplitude, aHighSubFrequency

aNote += aHighSub/4

aGogobell gogobel 1, cpsoct ( 6 + iPitch ), .75, .75, giStrikeFT, 6.0, 0.3, giVibratoFT

aNote += aGogobell/4

aSnatchAmplitude linseg 0, iAttack/2, 1, iDecay/8, 0
aSnatchFrequency linseg cpsoct ( 13 + iPitch ), iAttack/2, cpsoct ( 11 + iPitch )

aSnatch noise aSnatchAmplitude, 0
aSnatch butterlp aSnatch, aSnatchFrequency

aNote += aSnatch

aNote clip aNote, 1, 1

outs aNote, aNote

endin
