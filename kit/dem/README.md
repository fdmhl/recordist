#!/usr/bin/env roll

# Faddy's dem/Kick Synthesizer

?# if [ ! -d node_modules/@faddys/scenarist ]; then npm i @faddys/scenarist ; fi

?# cat - > index.orc

+==

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giStrikeFT ftgen 0, 0, 256, 1, "prerequisites/marmstk1.wav", 0, 0, 0
giVibratoFT ftgen 0, 0, 128, 10, 1

instr 13, dem

aNote = 0

iPitch init p4/p5

iAttack init 1/32
iDecay init 1/8 
iRelease init 1/32

p3 init iAttack + iDecay + iRelease

aMainSubAmplitude linseg 0, iAttack, 1, iDecay, .25, iRelease, 0
aMainSubFrequency linseg cpsoct ( 8 + iPitch ), iAttack, cpsoct ( 5 + iPitch )

aMainSub poscil aMainSubAmplitude, aMainSubFrequency

aNote += aMainSub

aHighSubAmplitude linseg 0, iAttack/8, 1, iDecay/8, .25, iRelease/8, 0
aHighSubFrequency linseg cpsoct ( 10 + iPitch ), iAttack/2, cpsoct ( 7 + iPitch )

aHighSub poscil aHighSubAmplitude, aHighSubFrequency

aNote += aHighSub / 8

aGogobell gogobel 1, cpsoct ( 5 + iPitch ), .5, .5, giStrikeFT, 6.0, 0.3, giVibratoFT

aNote += aGogobell / 4

aSnatchAmplitude linseg 0, iAttack/8, 1, iDecay/8, 0
aSnatchFrequency linseg cpsoct ( 10 + iPitch ), iAttack/2, cpsoct ( 9 + iPitch )

aSnatch noise aSnatchAmplitude, 0
aSnatch butterlp aSnatch, aSnatchFrequency

aNote += aSnatch*4

aNote clip aNote, 1, 1

out aNote

endin

-==

?# cat - > index.mjs

+==

import Scenarist from '@faddys/scenarist';

await Scenarist ( new class {

$_producer ( $ ) {

const dem = this;

dem .degrees = parseInt ( process .argv .slice ( 2 ) .pop () ) || 24;

dem .prepare ();

}

prepare () {

const dem = this;

for ( let step = 0; step < dem .degrees; step++ ) {

let score = `sco/${ step }.sco`;
let audio = `audio/dem.${ step + 1 }.wav`;

console .log ( [

`echo "i 13 0 1 ${ step } ${ dem .degrees }" > ${ score }`,
`csound -3 -o ${ audio } index.orc ${ score }`,
//`aplay ${ audio }`

] .join ( ' ; ' ) );

}

}

} );

-==

?# rm -fr index.sh sco audio ; mkdir sco audio
?# node ./index.mjs >> index.sh

?# bash index.sh
