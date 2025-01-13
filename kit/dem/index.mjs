
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
