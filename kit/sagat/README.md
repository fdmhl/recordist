#!/usr/bin/env roll

# Faddy's Sagat Synthesizer

?# cat - > index.orc

+==

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

-==

?# cat - > index.mjs

+==

import Scenarist from '@faddys/scenarist';
import $0 from '@faddys/command';

await Scenarist ( new class {

async $_producer ( $ ) {

const sagat = this;
let version = 0;

for ( let pitch = 0; pitch < 12; pitch++ )
for ( let length = 1; length <= 12; length++ ) {

let score = `sco/${ ++version }.sco`;
let audio = `audio/${ version }.wav`;

await $0 ( `echo "i 13 0 [1/${ length }] 256 .5 .5 ${ pitch * 25 }" > ${ score }` );
await $0 ( `csound -o ${ audio } index.orc ${ score }` );
await $0 ( `aplay ${ audio }` );

}

}

} );

-==

?# rm -fr index.sh sco audio ; mkdir sco audio
?# node index.mjs > index.sh

?# bash index.sh
