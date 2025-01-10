#!/usr/bin/env roll

# Faddy's Sak Synthesizer

?# if [ ! -d node_modules/@faddys/scenarist ]; then npm i @faddys/scenarist ; fi

?# cat - > index.orc

+==

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giStrikeFT ftgen 0, 0, 256, 1, "prerequisites/marmstk1.wav", 0, 0, 0
giVibratoFT ftgen 0, 0, 128, 10, 1

instr 13, sak

aNote = 0

iPitch init 1 + p4/p5

iAttack init 1/256
iDecay init 1/256 
iRelease init 1/512

p3 init iAttack + iDecay + iRelease

aMainSubAmplitude linseg 0, iAttack, 1, iDecay, .25, iRelease, 0
aMainSubFrequency linseg cpsoct ( 12 + iPitch ), iAttack, cpsoct ( 8 + iPitch )

aMainSub poscil aMainSubAmplitude, aMainSubFrequency

aNote += aMainSub

aHighSubAmplitude linseg 0, iAttack/8, 1, iDecay/8, .25, iRelease/8, 0
aHighSubFrequency linseg cpsoct ( 13 + iPitch ), iAttack/2, cpsoct ( 10 + iPitch )

aHighSub poscil aHighSubAmplitude, aHighSubFrequency

aNote += aHighSub

aGogobell gogobel 1, cpsoct ( 6 + iPitch ), .75, .75, giStrikeFT, 6.0, 0.3, giVibratoFT

aNote += aGogobell/4

aSnatchAmplitude linseg 0, iAttack/8, 1, iDecay/8, 0
aSnatchFrequency linseg cpsoct ( 13 + iPitch ), iAttack/2, cpsoct ( 11 + iPitch )

aSnatch noise aSnatchAmplitude, 0
aSnatch butterlp aSnatch, aSnatchFrequency

aNote += aSnatch

aNote clip aNote, 1, 1

outs aNote, aNote

endin

-==

?# cat - > index.mjs

+==

import Scenarist from '@faddys/scenarist';

await Scenarist ( new class {

$_producer ( $ ) {

const sak = this;

sak .degrees = parseInt ( process .argv .slice ( 2 ) .pop () ) || 24;

sak .prepare ();

}

prepare () {

const sak = this;

for ( let step = 0; step < sak .degrees; step++ ) {

let score = `sco/${ step + 1 }.sco`;
let audio = `audio/sak.${ step + 1 }.wav`;
let gap = 512;

console .log ( [

`echo "i 13 0 1 ${ step } ${ sak .degrees }" > ${ score }`,
`echo "i 13.1 ${ 1/gap } 1 ${ step + 1/3 } ${ sak .degrees }" >> ${ score }`,
`echo "i 13.2 ${ 2/gap } 1 ${ step + 2/3 } ${ sak .degrees }" >> ${ score }`,
`csound -o ${ audio } index.orc ${ score }`,
`aplay ${ audio }`

] .join ( ' ; ' ) );

}

}

} );

-==

?# rm -fr index.sh sco audio ; mkdir sco audio
?# node ./index.mjs >> index.sh

?# bash index.sh
