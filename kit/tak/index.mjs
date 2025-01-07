
import Scenarist from '@faddys/scenarist';

await Scenarist ( new class {

$_producer ( $ ) {

const tak = this;

tak .degrees = parseInt ( process .argv .slice ( 2 ) .pop () ) || 24;

tak .prepare ();

}

prepare () {

const tak = this;

for ( let step = 0; step < tak .degrees; step++ ) {

let score = `sco/${ step }.sco`;
let audio = `audio/tak.${ step + 1 }.wav`;
let gap = 512;

console .log ( [

`echo "i 13 0 1 ${ step } ${ tak .degrees }" > ${ score }`,
`echo "i 13.1 ${ 1/gap } 1 ${ step + 1/3 } ${ tak .degrees }" >> ${ score }`,
`echo "i 13.2 ${ 2/gap } 1 ${ step + 2/3 } ${ tak .degrees }" >> ${ score }`,
`csound -o ${ audio } index.orc ${ score }`,
`aplay ${ audio }`

] .join ( ' ; ' ) );

}

}

} );
