import { readdir as list } from 'node:fs/promises';

const index = await list ( '.' ) .then (

directory => directory .filter ( file => file .endsWith ( '.maqam' ) )
.map ( file => file .slice ( 0, -'.maqam' .length ) )
.map ( ( maqam, index ) => `#include "${ maqam }.maqam"
chnset "maqam_${ maqam [ 0 ] .toUpperCase () + maqam .slice ( 1 ) }", "maqam/${ index }"` )

);

index .unshift ( `chnset ${ index .length }, "maqam/count"` );

console .log ( index .join ( '\n\n' ) );
