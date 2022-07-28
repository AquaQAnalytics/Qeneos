## XML Builder Setup

## Prerequisites

In order to run the Geneos XML Builder we expect that you have the following already set up.

1. A KDB+ environment
2. A geneos gateway and appropriate licensing
3. One or more geneos netprobes
4. Appropriate Access to Edit your Geneos configuration files.

### Set up buildXML.sh script

The buildXML.sh script will work as is. 
The only configuration you might consider changing is the location where you build the XML file.
In our setup, we are storing the XML file within our repository, but equally you might want to keep it in a location outside your codebase.
As we are using this on a small scale internally we have set up geneos to read the includes file directly from the file we generate. If your geneos server is on another server, you will likely want to add an additional step to copy the data to a location that geneos can read the file from. Alternatively, you can copy and paste the file into your Geneos configuration editor.  


## Populating the CSV files

### variables.csv

We should start by populating some of the variables and attributes in this csv. We will keep returning to this file as we build out our monitoring system, so we don't need to fully populate everything in one go.

Note, that 'default' in the variables.csv will apply it to all Managed Entities or Types. If you apply a default variable and then a variable to a specific Managed Entity or Type, the second will overwrite the first. Likewise if you apply a variable to a Managed Entity, any Types with different variables set used in that Managed Entity will use the variable set on the Type.

The variables csv containes variables for two different types of processes in Geneos - Managed Entities and Types. I generally consider Managed Entities (ME) as the top level container within your geneos system and personally prefer to have one ME per data flow. Types are the mid level building blocks and our philosophy here is to have one process or type of process (HDB, RDB) per type. MEs are generally groups of types, and types are groups of samplers.

Lets start populating the variables.csv by defining some expected values for ME. We have prepopulated the csv file with some of the variables and attributes that you should be able to populate at this point. We have called our Managed Entities Example1 and Example2 - these should be changed to names relevant to you. We have prepopulated all the variables for Example1 based off a TorQ release. Change the specifics and if applicable populate the rest of Example2.

Note, we can also populate some attribute here. Attributes won't impact your samplers, but are used to improve the navigation of your MEs. The order and what attributes are considered are configured within the geneos user console, so each individual user can prioritusee them as they like.

Provided you're intending to follow our philosophy of one process per type, you can keep the variables we have populated for the HDB and RDB Types as well.
The 'process' and 'instance' variables are used to locate the processes via your discovery process. Therefore they should match the names exactly!
Note - we have set the default instance number here to 1. If you're using a framework that starts its instances from 0, or you want to specifically query another instance, you should overwrite this. In cases where you have multiple instances of a process running, it may make sense to make multiple types - e.g. HDB1 and HDB2 

### process.csv

The process.csv file is the easiest file to begin with - its purpose is to tell the XML Builder script which processes you want to have basic monitoring on.
It does this by using our philosophy of a type for each process or process type. Every type listed can then have a process monitor (returns stats on each process of that type running) and a log sampler, which scans the log files for that processes.

We have assumed a standard KDB setup and that you may want to monitor our rdb and hdb, so have prepopulated these values. 

```
Type,ProcessSampler,LogSampler
HDB,1,1
RDB,1,1
```

Any additional processes to be monitored should be added as above.

Once we have decided what processes are going to be in this sampler we should update the variables.csv for any missing 'Types'. We have prepopulated HDB and RDB with variables, but any additional processes should be added here as well.
Note - the type name does not have to match the variable you give your process. For example if your framework uses the name PDB (persisting database) but you're more used to WDB (writing database) you can call your type WDB - as noted previously though its important that the 'process' variable matches exactly what your discovery process or map expects the process name to be.

### samplers.csv

Populating the samplers.csv file is probably the most complex part of setting up the Geneos XML builder.
This is where the more complex functions are created using KDB+ code and turned into samplers. 
Keeping with our running assumption of wanting to set up checks for an RDB and an HDB we have included two examples in this file.
Some important factors to note:
- You can assign a sampler to multiple 'Types' by pipe separating them - ...,RDB|HDB,
- The group column will be used by Geneos to organise the samplers in each managed entity - therefore its useful to group things together. Our philosophy is to order the items in the same way as the data flows.
- Interval is how often the query samples in seconds. This should be decided on how likely the data is to change in that period, to minimise the impact your monitoring has on the system.
- Timezone funcationality is not available in version 1, but will be available in later versions. Please put in some value to keep Geneos happy.
- We have gone with a Function and argument structure - even if you are using a simple select function, please wrap it in {}, and give an arguement of ` to run it.
- In order to use our in-built rules and keep your life as simple as possible, try to add a 'Status' column to your results tables, with `OK for Green, `WARN for amber and `FAIL for Red. Which value appears in the status column should be determined in your function - ie set your rules functionally. 

### netprobe.csv

The netprobe.csv file is designed to link the geneos netprobes you have installed to our XML builder. In order to populate this you should have already installed the netprobe and no the server and port they are running on.
You can call your netprobes whatever you like, however it is wise to link it in someway to the server it is running on, to make it as transparent as possible if you're ever debugging any issues.

We have left an example in the netprobe.csv file for you to edit

### mEntity.csv

The final file to populate is the mEntity.csv. The purpose of this file is to add the relevant types into your managed entities and link it to a netprobe.
Again we have prepopulated this file for you, using our earlier example MEs (Example1 & Example2) and Types (RDB and HDB). Again, all types being applied to a ME should be pipe delimited - .e.g HDB|RDB

## Building your Geneos XML File

Now that everything is prepopulated we should build our geneos XML file.
This is done by running
```
. buildXML.sh
```
(you should have q setup on the process you're running on)

Running this inputs some prewritten xml snippets (intro, outro and rules) either side of running our GeneosXMLBuilder.q script. 

Note - if you are running the GeneosXMLBuilder.q script by itself for testing/debugging purposes, you should comment out the final exit 0 line.
