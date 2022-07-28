

/Pull connection details from discovery processs
opts:.Q.def[`Map`Name`Timeout!(`;`;1000)] .Q.opt .z.x;


//TODO - overwrite credentials with something internal.
//TODO - add in option to run for other hosts? May make life simpler
MapPath:opts`Map;
Name:opts`Name;
Timeout:opts`Timeout;
Query:string opts`Query;
Script:string opts`Script;

printHeaders:{
  -1 "";
  -1 "<!>LocalSampleTime,",string .z.Z;
 };

map:`name xkey ("SS";enlist",") 0:MapPath;

hp:map[Name];

hp

exit 0
