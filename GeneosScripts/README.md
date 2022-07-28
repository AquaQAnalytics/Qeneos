## Geneos Scripts

This directory holds scripts that can be used to run KDB+ Queries against q Processes.

Depending on which framework/connection method you want, you should uncomment the appropriate line from the GeneosSampler.sh scripts
Also in GeneosSampler.sh you should export your QHOME path and update your Q path as necessary. QHOME is usually set in your path when installing kdb+ - if you can't remember it try running `echo $QHOME` on your command line.

There is no need to manually do so as the Geneos XML Builder does all the heavy lifting for you, however if you wish to debug or view the scripts in action, the General format to run the scripts is as follows:

#### For TorQ installations or for other frameworks that have a discovery process mapping the ports
```
path/GeneosSampler.sh -script path/GenericGeneosQuery.q -DiscoveryConnection 5000 -Process HDB -Instance 0 -Query '([]a:1 2;b:2 3)'
```

#### For Installations where you only want to define host and port
1. Localhost
```
path/GeneosSampler.sh -script path/GenericGeneosQuery.q -Port 5003 -Query '([]a:1 2;b:2 3)'
```
2. Remote Host
```
path/GeneosSampler.sh -script path/GenericGeneosQuery.q -Server myServerName -Port 5003 -Query '([]a:1 2;b:2 3)'
```
#### For A Map CSV 

where the csv has two columns, name and connection as below

```
map,connection
gw,::5007
rdb,:myServerName:5003
```
```
path/GeneosSampler.sh -script path/GenericGeneosQuery.q -Map pathToMap -Name rdb -Query '([]a:1 2;b:2 3)'
```
