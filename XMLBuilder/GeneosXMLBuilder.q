/Utility functions
.util.indent:{(4*x)#" "};


//Load and expand CSVs to build tables containing netprobe, sampler, type and managed entity data
/load in netprobeTab from csv
netprobeTab:("SSI";enlist",") 0: `:./netprobe.csv;

/load in Managed Entity from csv
METab:("SSS";enlist",") 0: `:./mEntity.csv;
/change type of Types to a list
METab:update Types:{`$"|" vs string x} each Types from METab;

/load in samplerTab from csv
samplerTab:("SSSISS";enlist ",") 0: `:./sampler.csv;
samplerQueryTab:("SS";enlist "'") 0: `:./samplerQuery.csv;
samplerTab:0!(1!samplerTab)lj(1!samplerQueryTab);
/ungroup samplerTab and string Query/Arguments
samplerTab:update string Query, string Arguments from ungroup update {`$"|" vs x} each string Type from samplerTab;

/load variables Tab
variablesTab:("SSSSSSS";enlist",") 0: `:./variables.csv;
attributesTab:select from variablesTab where VarAtr in `Atr;
variablesTab:select from variablesTab where VarAtr in `Var;

/load processSamplerTab from csv
processSamplerTab:("SBB";enlist",") 0: `:./process.csv;
processSamplerDict:raze {(enlist[x]!(enlist first ?[`variablesTab;((in;`Level;enlist `type);(in;`Name;enlist `PROCESS);(in;`LevelName;enlist x));();`Var]))} each exec Type from processSamplerTab;

/load ME Varaibles
meVariablesTab:select from variablesTab where Level in `ME;
meVarList:exec distinct LevelName from meVariablesTab where not LevelName in `default;
meVariablesTab:0!(`LevelName`Name xkey ungroup {update LevelName:((),meVarList) from x} each select from meVariablesTab where LevelName in `default) uj `LevelName`Name xkey select from meVariablesTab where not LevelName in `default;

/Build Types Tab
/create inital typeTab
typeTab:select Type:LevelName, Name, VarType, Var from variablesTab where Level in `type;
/load distinct list of all types from samplers/variablesTab
typeList:distinct (exec distinct Type from samplerTab),(exec distinct Type from typeTab where not Type in `default);

/load distinct list of Managed Entities
MEList:exec distinct Name from METab;

/build full typeTab from ungrouped defaults and specific variables
typeTab:`Type xasc 0!(`Type`Name xkey ungroup {update Type:((),typeList) from x} each select from typeTab where Type in `default) uj (`Type`Name xkey select from typeTab where not Type in `default);


/Basic XML Building blocks
/takes symbol argument for XML header and level of indentation
printOpen:{[x;y] -1 (.util.indent[y],"<",string[x],">");}
printClose:{[x;y] -1 (.util.indent[y],"</",string[x],">");}

// NETPROBE SPECIFIC

/Probe Bookends
printProbeBookendOpen:{
  -1 ("<probes>");
 };

printProbeBookendClose:{
  -1 ("</probes>");
 };

/All the probe information
/NB - Can override Probe command timeout by adding an additional variable to this function - geneos (and therefore our) default is 30 seconds.
printNetprobe:{[Name;Server;Port]
  -1 (.util.indent[1],"<probe name=\"",string[Name],"\">");
  -1 (.util.indent[2],"<hostname>",string[Server],"</hostname>");
  -1 (.util.indent[2],"<port>",string[Port],"</port>");
  -1 (.util.indent[2],"<commandTimeout>30</commandTimeout>");
  -1 (.util.indent[1],"</probe>");
 };


// SAMPLER SPECIFIC

/printing specific snippets
printSamplerGroup:{
  -1 (.util.indent[2],"<var-group>");
  -1 (.util.indent[3],"<data>",(string x),"</data>");
  -1 (.util.indent[2],"</var-group>");
 };

printSamplerInterval:{
  -1 (.util.indent[2],"<sampleInterval>");
  -1 (.util.indent[3],"<data>",(string x),"</data>");
  -1 (.util.indent[2],"</sampleInterval>");
 };

/Samplers Bookends
printSamplerBookendOpen:{
  -1 ("<samplers>");
 };

printSamplerBookendClose:{
  -1 ("</samplers>");
 };

/Sampler beginnings and endings
printSamplerOpen:{[Name;Group;interval]
  printOpen[`$("sampler name=\"",string[Name],"\"");1];
  printSamplerGroup[Group];
  printSamplerInterval[interval];
 };

printSamplerClose:{
  printClose[`sampler;1];
 };

//TODO - build the following variables in to types: GENEOS_WRAPPER_SCRIPT, GENERIC_SAMPLER, DISCOVERY_CONNECTION, PROCESS and INSTANCE
//TODO - make sure the first three of the above are read in from existing config files 
/Prints the specifics of each query - not includes variables that are assigned in types/managed entities 
printSamplerScript:{
  -1 (.util.indent[5],"<var ref=\"GENEOS_WRAPPER_SCRIPT\"></var>");
  -1 (.util.indent[5],"<data> -Script </data>");
  -1 (.util.indent[5],"<var ref=\"GENERIC_SAMPLER\"></var>");
  -1 (.util.indent[5],"<data> -DiscoveryConnection </data>");
  -1 (.util.indent[5],"<var ref=\"DISCOVERY_CONNECTION\"></var>");
  -1 (.util.indent[5],"<data> -Process </data>");
  -1 (.util.indent[5],"<var ref=\"PROCESS\"></var>");
  -1 (.util.indent[5],"<data> -Instance </data>");
  -1 (.util.indent[5],"<var ref=\"INSTANCE\"></var>");
  -1 (.util.indent[5],"<data> -Query '",x," ",y,"'</data>");
 };


/printing wrappers
printAllInit:{[x;y;z] {printOpen[x[0];x[1]]} each x;printSamplerScript[y;z];{printClose[x[0];x[1]]}each reverse x;};

printAll:printAllInit[((`plugin;2);(`toolkit;3);(`samplerScript;4))];

printSampler:{[Name;Group;interval;Query;Arguments]
  printSamplerOpen[Name;Group;interval];
  printAllInit[((`plugin;2);(`toolkit;3);(`samplerScript;4));Query;Arguments];
  printSamplerClose[];
 };


// Process Sampler Specific

printProcDescriptor:{[Type] -1 (.util.indent[6],"<processDescriptor ref=\"",string[Type],"\"></processDescriptor>")};
printAllProcessInit:{[x;y] {printOpen[x[0];x[1]]} each x;printProcDescriptor[y];{printClose[x[0];x[1]]}each reverse x;};

printProcessSampler:{[Type]
  printSamplerOpen[`$(string[Type]," Process Check");`$upper string[Type];60];
  printAllProcessInit[((`plugin;2);(`processes;3);(`processes;4);(`process;5));Type];
  printSamplerClose[];
 };

// Process Log Sampler Specific

printLogPath:{[Type]
  -1 (.util.indent[8],"<path>");
  -1 (.util.indent[9],"<var ref=\"LOG\"></var>");
  -1 (.util.indent[9],"<data>*_",string[Type],"?.log</data>");
  -1 (.util.indent[8],"</path>");
  -1 (.util.indent[8],"<pattern>");
  -1 (.util.indent[9],"<data>");
  -1 (.util.indent[10],"<regex>^.*.log</regex>");
  -1 (.util.indent[9],"</data>");
  -1 (.util.indent[8],"</pattern>");
 };

printAllLogInit:{[x;y] {printOpen[x[0];x[1]]} each x;printLogPath[y];{printClose[x[0];x[1]]}each reverse x;};

printLogSampler:{[Type]
  printSamplerOpen[`$(string[Type]," Log Check");`$upper string[Type];60];
  printAllLogInit[((`plugin;2);(`fkm;3);(`files;4);(`file;5);(`source;6);(`dynamicFiles;7));Type];
  printSamplerClose[];
 };

// PROCESS DESCRIPTOR SPECIFIC

printPDBookendOpen:{
  -1 ("<staticVars>");
  -1 (.util.indent[1],"<processDescriptors>");
 };

printPDBookendClose:{
  -1 (.util.indent[1],"</processDescriptors>");
  -1 ("</staticVars>");
 };

printPD:{[Name]
  -1 (.util.indent[2],"<processDescriptor name=\"",string[Name],"\">");
  -1 (.util.indent[3],"<alias>");
  -1 (.util.indent[4],"<data>",string[Name],"</data>");
  -1 (.util.indent[3],"</alias>");
  -1 (.util.indent[3],"<ID>");
  -1 (.util.indent[4],"<searchString>");
  -1 (.util.indent[5],"<data>-stackid </data>");
  -1 (.util.indent[5],"<var ref=\"STACK_ID\"></var>");
  -1 (.util.indent[5],"<data> -proctype ",string[Name],"</data>");
  -1 (.util.indent[4],"</searchString>");
  -1 (.util.indent[3],"</ID>");
  -1 (.util.indent[2],"</processDescriptor>");
 };

printPDAll:{[NameList]
  printPDBookendOpen[];
  printPD each NameList;
  printPDBookendClose[];
 };

// TYPE SPECIFIC

/Types Bookends
printTypeBookendOpen:{
  -1 ("<types>");
 };

printTypeBookendClose:{
  -1 ("</types>");
 };

/Type Open and Closing
printTypeOpen:{[Name]
  -1 (.util.indent[1],"<type name=\"",string[Name],"\">");
 }

printTypeClose:{
  -1 (.util.indent[1],"</type>");
 };

printTypeVariables:{[VarName;VarType;Var]
  -1 (.util.indent[2],"<var name=\"",string[VarName],"\">");
  -1 (.util.indent[3],"<",string[VarType],">",string[Var],"</",string[VarType],">");
  -1 (.util.indent[2],"</var>");
 };

printTypeSampler:{[sampler]
  -1 (.util.indent[2],"<sampler ref=\"",string[sampler],"\"></sampler>");
 };

printType:{[TypeName]
  printTypeOpen[TypeName];
  {{printTypeVariables[x;y;z]}[x`Name;x`VarType;x`Var]} each select from typeTab where Type in TypeName;
  printTypeSampler each exec Name from samplerTab where Type in TypeName;
  if[1b~first exec ProcessSampler from processSamplerTab where Type in TypeName;printTypeSampler each `$(string[first processSamplerDict[exec Type from processSamplerTab where Type in TypeName]]," Process Check")];
  if[1b~first exec LogSampler from processSamplerTab where Type in TypeName;printTypeSampler each `$(string[first processSamplerDict[exec Type from processSamplerTab where Type in TypeName]]," Log Check")];
  printTypeClose[];
 };

//Managed Entity Specific

/ME Bookends
printMEBookendOpen:{
  -1 ("<managedEntities>");
 };

printMEBookendClose:{
  -1 ("</managedEntities>");
 };

printManagedEntityOpen:{[Name]
  -1 (.util.indent[1],"<managedEntity name=\"",string[Name],"\">");
 };

printManagedEntityClose:{
  -1 (.util.indent[1],"</managedEntity>");
 };

printProbe:{[netprobe]
  -1 (.util.indent[2],"<probe ref=\"",string[netprobe],"\"></probe>");
 };


/print Attributes for ME
printMEAttr:{[attribute;val]
  -1 (.util.indent[2],"<attribute name=\"",string[attribute],"\">",string[val],"</attribute>");
 };

/Add types to managed entities
printMETypeOpen:{
  -1 (.util.indent[2],"<addTypes>");
 };

printMETypeClose:{
  -1 (.util.indent[2],"</addTypes>");
 };

printMEType:{[Type]
  -1 (.util.indent[3],"<type ref=\"",string[Type],"\"></type>");
 };

printAllMEType:{[TypeList]
  printMETypeOpen[];
  printMEType each TypeList;
  printMETypeClose[];
 };

printMEVar:{[Name;VarType;Var]
  -1 (.util.indent[2],"<var name=\"",string[Name],"\">");
  -1 (.util.indent[3],"<",string[VarType],">",string[Var],"</",string[VarType],">");
  -1 (.util.indent[2],"</var>");
 };

printME:{[METab;attributesTab;meVariablesTab;me]
  printManagedEntityOpen each me;
  printProbe[first exec Probe from METab where Name in me];
  {.[printMEAttr;value x]}each flip exec Name,Var from attributesTab where Level in `ME, LevelName in me;
  printAllMEType raze exec Types from METab where Name in me;
  {.[printMEVar;value x]} each flip exec Name, VarType, Var from meVariablesTab where LevelName in me;
  printManagedEntityClose[];
 }[METab;attributesTab;meVariablesTab];

printAllME:{[tab]
  printMEBookendOpen[];
  printME each exec distinct Name from tab;
  printMEBookendClose[];
 }

//Writing XML

/build Sampler XML
{[typeList]
  /Probes
  printProbeBookendOpen[];
  {printNetprobe[x`Name;x`Server;x`Port]} each netprobeTab;
  printProbeBookendClose[];
  /Managed Entities
  printAllME[METab];
  /Types
  printTypeBookendOpen[];
  printType each typeList;
  printTypeBookendClose[];
  /Samplers
  printSamplerBookendOpen[];
  {printSampler[x`Name;x`Group;x`Interval;x`Query;x`Arguments]} each distinct select Name, Group, Interval, Query, Arguments from samplerTab;
  printProcessSampler each processSamplerDict[exec Type from processSamplerTab where ProcessSampler in 1];
  printLogSampler each processSamplerDict[exec Type from processSamplerTab where LogSampler in 1];
  printSamplerBookendClose[];
  printPDAll[processSamplerDict[exec Type from processSamplerTab]];
 }[typeList];

exit 0
