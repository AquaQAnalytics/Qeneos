## Geneos Scripts

This directory holds scripts that can be used to run KDB+ Queries against q Processes.

Depending on which framework/connection method you want, you should uncomment the appropriate line from the GeneosSampler.sh scripts
Also in GeneosSampler.sh you should export your Q and QHOME paths

The General format to run the scripts is as follows:

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
