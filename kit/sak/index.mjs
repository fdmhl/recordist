
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
