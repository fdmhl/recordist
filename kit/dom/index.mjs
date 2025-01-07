
import Scenarist from '@faddys/scenarist';

await Scenarist ( new class {

$_producer ( $ ) {

const dom = this;

dom .degrees = parseInt ( process .argv .slice ( 2 ) .pop () ) || 24;

dom .prepare ();

}

prepare () {

const dom = this;

for ( let step = 0; step < dom .degrees; step++ ) {

let score = `sco/${ step }.sco`;
let audio = `audio/dom.${ step + 1 }.wav`;

console .log ( [

`echo "i 13 0 1 ${ step } ${ dom .degrees }" > ${ score }`,
`csound -3 -o ${ audio } index.orc ${ score }`,
//`aplay ${ audio }`

] .join ( ' ; ' ) );

}

}

} );
