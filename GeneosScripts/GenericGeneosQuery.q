

/Define variables from script inputs
opts:.Q.def[`Connection`Query`Timeout!(`;`;1)] .Q.opt[.z.x];

Connection:opts`Connection;
Query:opts`Query;
Timeout:opts`Timeout;


/Print Headers - Geneos picks these up as 'Headlines'

printHeaders:{
  -1 "";
  -1 "<!>LocalSampleTime,",string .z.Z;
  -1 "<!>Connection,",string Connection;
  -1 "<!>Query,",string Query;
 };


/Error trap - display Fail message in Geneos
// TODO - check this works and improve/fix if doesn't

et:{[message]
  t:([] Process:enlist Connection; Status:enlist `FAILED;Message:enlist `$message);
  -1 csv 0:t;
  printHeaders[];
  /exit 1;
 };


/Connect to TorQ process
//Check timeout is ms or seconds

conn:`$string[Connection],":admin:admin";
h:@[hopen;(conn;Timeout);{et[raze "Connection to processs failed with error: ",string x]}];


/run Query 

result:h string[Query];
hclose h;

/print results
-1 csv 0:result;

/print Headlines
printHeaders[];

exit 0
