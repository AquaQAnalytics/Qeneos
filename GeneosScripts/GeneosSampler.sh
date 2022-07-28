#/bin/bash



LOCAL="`dirname \"$0\"`"

#For TorQ Installation
#DISCORESULT=$(${Q} ${LOCAL}/GeneosSampler.q ${@})

#For Direct Port Connection
#DISCORESULT=$(${Q} ${LOCAL}/GeneosSamplerPort.q ${@})

#For a Process Map CSV
#DISCORESULT=$(${Q} ${LOCAL}/GeneosSamplerMap.q ${@})

CONN=`echo ${DISCORESULT} | sed 's/\`//'`

while true; do
	case "$1" in
		-Script) SCRIPT=$2; shift ;;
		-- ) shift; break ;;
		* ) break ;;
	esac
done

${Q} ${SCRIPT} "$@" -Connection ${CONN}

