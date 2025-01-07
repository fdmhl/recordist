
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
