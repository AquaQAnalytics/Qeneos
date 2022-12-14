## XML Builder Setup

## Prerequisites

In order to run the Geneos XML Builder we expect that you have the following already set up.

1. A KDB+ environment
2. A geneos gateway and appropriate licensing
3. One or more geneos netprobes running on your server - you should know the port number
4. Appropriate Access to Edit your Geneos configuration files.

### Set up buildXML.sh script

The buildXML.sh script will work as is. 
The only configuration you might consider changing is the location where you build the XML file.
In our setup, we are storing the XML file within our repository, but equally you might want to keep it in a location outside your codebase.
As we are using this on a small scale internally we have set up geneos to read the includes file directly from the file we generate. If your geneos server is on another server, you will likely want to add an additional step to copy the data to a location that geneos can read the file from. Alternatively, you can copy and paste the file into your Geneos configuration editor.  


## Populating the CSV files

**The following instructions go in to quite a lot of detail on why we are doing particular things, with a focus on learning. We realise that some people will want the quickfire experience and so we have put learning information in italics.**
**If you are in a rush, edit the values where necessary in the 5 csv files to match your own kdb+ setup - you shouldn't have to add any new lines to get a basic setup running. Then run the shell script as described at the bottom of this file.**
**We don't advise skipping unless you are familiar with geneos.**

### variables.csv

We should start by populating some of the variables and attributes in this csv. We will keep returning to this file as we build out our monitoring system, so we don't need to fully populate everything in one go.

*The variables csv contains variables for two different types of processes in Geneos - Managed Entities and Types. I generally consider Managed Entities (ME) as the top level container within your geneos system and personally prefer to have one ME per data flow. Types are the mid level building blocks and our philosophy here is to have one process or type of process (HDB, RDB) per type. MEs are generally groups of types, and types are groups of samplers.*

**Note - 'default' in the variables.csv will apply it to all the Managed Entities or Types (depending on Level value). Applying a variable to a specific Managed Entity or Type will overwrite the default variables for that ME or Type. A variable set for a Type will take precedence over the same variable set on a ME.**

Lets start populating the variables.csv by defining some expected values for ME. We have prepopulated the csv file with some of the variables and attributes that you should be able to populate at this point. We have called our Managed Entity Example1 - this should be changed to something more relevant.

**Note - All the ME variables we have prepopulated contain example values - All of these variables need to be changed based off your personal configuration for it to work**

**Note -  We can also populate some attribute here (Atr in the variables.csv). Attributes won't impact your samplers, but are used to improve the navigation of your MEs. The order and what attributes are considered are configured within the geneos user console, so each individual user can prioritise them as they like.**

*Provided you're intending to follow our philosophy of one process per type, you can keep the variables we have populated for the HDB and RDB Types as well.
The 'process' and 'instance' variables are used to locate the processes via your discovery process. Therefore they should match the names exactly!*
**Note - we have set the default instance number here to 1. If you're using a framework that starts its instances from 0, or you want to specifically query another instance, you should overwrite this. In cases where you have multiple instances of a process running, it may make sense to make multiple types - e.g. HDB1 and HDB2**

### process.csv

The process.csv file is the easiest file to begin with - its purpose is to tell the XML Builder script which processes you want to have basic monitoring on.
*It does this by using our philosophy of a type for each process or process type. Every type listed can then have a process monitor (returns stats on each process of that type running) and a log sampler, which scans the log files for that processes.*

*We have assumed a standard KDB setup and that you may want to monitor our rdb and hdb, so have prepopulated these values.*

```
Type,ProcessSampler,LogSampler
HDB,1,1
RDB,1,1
```

Any additional processes to be monitored should be added as above.

### back to the variables.csv

Once we have decided what processes are going to be in this sampler we should update the variables.csv for any missing 'Types'. We have prepopulated HDB and RDB with variables, but any additional processes should be added here as well.

**Note - You can name your Type whatever you like - but when setting the PROCESS variable, it must match the process name/proctype** 

### samplers.csv and samplerQuery.csv

Populating the samplers.csv and the samplerQuery.csv files is probably the most complex part of setting up the Geneos XML builder.
This is where the more complex functions are created using KDB+ code and turned into samplers. 

The samplerQuery.csv file is reasonably simple - it contains a name and the query.
**Note - because geneos queries don't like apostrophes `'` we can't use them in our queries. As we can use every other available symbol in a kdb query, including commas, we have chosen to make this an apostrophe separated file.**
**Just in case - samplerQuery.csv is apostrophe separated!**
**We have designed the queries to be functions, so please wrap them in `{}`**
We have added more samplerQuery lines that we are currently using in sampler.csv. This is to give you lots of options to quickly build in your initial setup

The sampler.csv file contains the rest of the information required to run the sampler, including the arugments to run the query. This is a comma separated file.

Keeping with our running assumption of wanting to set up checks for an RDB and an HDB we have included two examples in this file.
Some important factors to note:
- You can assign a sampler to multiple 'Types' by pipe separating them - ...,RDB|HDB,
- The group column will be used by Geneos to organise the samplers in each managed entity - therefore its useful to group things together.
- Interval is how often the query samples in seconds. This should be decided on how likely the data is to change in that period, to minimise the impact your monitoring has on the system.
- Timezone funcationality is not available in version 1, but will be available in later versions. Please put in some value to keep Geneos happy.
- We have gone with a Function and argument structure - even if you are using a simple select function, please wrap it in {}, and give an arguement of ` to run it.
- In order to use our in-built rules and keep your life as simple as possible, try to add a 'Status' column to your results tables, with`` `OK`` for Green,`` `WARN`` for amber and`` `FAIL`` for Red. Which value appears in the status column should be determined in your function - ie set your rules functionally. 
- You can create geneos variables inside your samplers. To do so, you should use the following format `$(myNewVariable)` - you then need to add the variable to your variables csv for either the ME or the Type.
- There are 2 rules that you need to remember when creating samplers in Geneos
  1. If using a `$` to cast you should put a space afterwards, so Geneos doesn't think it's a variable - e.g. `` `$ "string"``
  2. Our geneos code wraps the query argument in apostrophes so these should be avoided in samplers - I advise using a function and each rather than `'` to avoid any issues


### netprobe.csv

*The netprobe.csv file is designed to link the geneos netprobes you have installed to our XML builder. In order to populate this you should have already installed the netprobe and no the server and port they are running on.*
*You can call your netprobes whatever you like, however it is wise to link it in someway to the server it is running on, to make it as transparent as possible if you're ever debugging any issues.*

We have left an example in the netprobe.csv file for you to edit - Please change the hostname and port as required.

**Note - you can only create one probe entry in geneos for each netprobe running on your server**

### mEntity.csv

*The final file to populate is the mEntity.csv. The purpose of this file is to add the relevant types into your managed entities and link it to a netprobe.*
Again we have prepopulated this file for you, using our earlier example ME (Example1) and Types (RDB and HDB). Again, all types being applied to a ME should be pipe delimited - .e.g HDB|RDB

**Note - For the Geneos XML Builder to work, each Managed Entity defined in this csv needs to have a working netprobe assigned to it.**

## Building your Geneos XML File

Now that everything is prepopulated we should build our geneos XML file.
This is done by running
```
. buildXML.sh
```
**Note - you should have q setup on the process you're running on**

Running this inputs some prewritten xml snippets (intro, outro and rules) either side of running our GeneosXMLBuilder.q script. 

**Note - if you are running the GeneosXMLBuilder.q script by itself for testing/debugging purposes, you should comment out the final exit 0 line.**
