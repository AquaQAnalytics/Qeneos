

/Pull connection details from discovery processs
opts:.Q.def[`DiscoveryConnection`Process`Instance`Timeout`Query!(`;`;`;1000;`)] .Q.opt .z.x;


//TODO - overwrite credentials with something internal.
//TODO - add in option to run for other hosts? May make life simpler
discoConn:`$"::",(string opts`DiscoveryConnection),":admin:admin";
process:`$(string[opts`Process],string[opts`Instance]);
Timeout:opts`Timeout;
Query:string opts`Query;
Script:string opts`Script;

et:{[message]t:([]process:enlist discoConn;status:enlist `FAIL;message:enlist `$message);-1 csv 0:t;printHeaders[];exit 1};

printHeaders:{
  -1 "";
  -1 "<!>DiscoveryConnection,",string discoConn;
  -1 "<!>LocalSampleTime,",string .z.Z;
 };

h:@[hopen;(discoConn;Timeout);{et["Unable to connect to discovery process with error: ",x]}];

query:"exec hpup from .servers.SERVERS where procname in `",string[process];

hp:first h query;

hclose h;

hp

exit 0
