#/bin/bash

cat fixedScripts/intro.xml > XML/geneos.xml
q GeneosXMLBuilder.q >> XML/geneos.xml
cat fixedScripts/rules.xml >> XML/geneos.xml
cat fixedScripts/outro.xml >> XML/geneos.xml
#scp XML/geneos.xml login@myGeneosServer:/path/to/geneos/includes/files
