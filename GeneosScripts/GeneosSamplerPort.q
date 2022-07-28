

/Pull connection details from discovery processs
opts:.Q.def[`Server`Port`Timeout!(`::;0;1000)] .Q.opt .z.x;


//TODO - overwrite credentials with something internal.
//TODO - add in option to run for other hosts? May make life simpler
Server:opts`Server;
Port:opts`Port;
Timeout:opts`Timeout;
Query:string opts`Query;
Script:string opts`Script;

printHeaders:{
  -1 "";
  -1 "<!>LocalSampleTime,",string .z.Z;
 };

hp:`$(string[Server],":",string[Port]);


hp

exit 0
