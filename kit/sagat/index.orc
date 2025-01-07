
sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

instr 13, sagat

iNumberOfObjects init 4
iDamp init 5
iShakingEnergy init 6
iPitch init 7

aNote tambourine 1, p3, \
p ( iNumberOfObjects ), \ ; defaults to 32
p ( iDamp ), \ ; ranges between 0 and .75
p ( iShakingEnergy ), \ ; defaults to 0, ranges between 0 and 1
2100 * cent ( p ( iPitch ) ), \ ; defaults to 2300
5100 * cent ( p ( iPitch ) ), \ ; defaults to 5600
7100 * cent ( p ( iPitch ) ) ; defaults to 8100

aNote clip aNote, 1, 1

outs aNote, aNote

endin
