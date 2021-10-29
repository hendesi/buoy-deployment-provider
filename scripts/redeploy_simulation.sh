RED='\033[0;31m'
GREEN='\033[0;32m'
DEFAULT='\033[0m'

addresses=()
ipAddresses=()
# The integer values of the sensors
sensorValues=()
# The sensors in a string format that can written in the available_sensors.json
sensors=()
# The sensor names
sensorNames=( "temperature" "conductivity" "ph" )

errorOccurred=false

sleepTime=$2

EXEC_PATH=".build/debug/BuoyDeploymentTarget"

# 1. Define the initial random sensors on each device and compute ssh addresses
while IFS=' ' read -ra line; do
    addresses+=( "${line[0]}@${line[1]}" )
    ipAddresses+=( ${line[1]} )
    
    SENS_1=$(( ( RANDOM % 3 ) ))
    SENS_2=$(( ( RANDOM % 3 ) ))
    
    sensors+=( "[$SENS_1,$SENS_1]" )
    sensorValues+=( $SENS_1 )
    sensorValues+=( $SENS_2 )
done < $1

echo "${addresses[*]}"

if [ ${#ipAddresses[@] } != 3 ]; then
    echo "Specify exactly 3 devices."
    exit 0
fi

echo "Stopping docker instances on remote"
ssh ${addresses[0]} 'docker stop $(docker ps -a -q); docker rm $(docker ps -a -q)'
ssh ${addresses[1]} 'docker stop $(docker ps -a -q); docker rm $(docker ps -a -q)'
ssh ${addresses[2]} 'docker stop $(docker ps -a -q); docker rm $(docker ps -a -q)'

echo "Setting sensors on the gateways"

# Copy sensor content to available_sensors.json
ssh ${addresses[0]} 'echo "[0,2]" >| /buoy/available_sensors.json'
ssh ${addresses[1]} 'echo "[0,1]" >| /buoy/available_sensors.json'
ssh ${addresses[2]} 'echo "[2]" >| /buoy/available_sensors.json'

echo "Starting the Deployment Provider"

tmux new-session -d -s BuoyDeploymentProvider 'cd ..;./$EXEC_PATH'
echo "Waiting for initial deployment..."
SECONDS=0
printf "["
# While process is running...
while [ "$SECONDS" -ne "300" ]; do
    printf  "▓"
    sleep 10
done
printf "] Finished deployment!"

# The deployment runs in the tmux instance, so we cannot directly check if the initial deployment finished. Waiting 120s should be more than enough.

function call() {
    currentCall=$1:80/v1/data/${sensorNames[$2]}
    call=$(curl -s -o /dev/null -w "%{http_code}" $currentCall)
    if [ $call -eq 200 ] && $3; then
        echo "${GREEN}\xE2\x9C\x94 SUCCESS${DEFAULT}: $currentCall was successful"
    elif [ $call -ne 200 ] && ! $3; then
        echo "${GREEN}\xE2\x9C\x94 SUCCESS${DEFAULT}: $currentCall was expected to fail."
    else
        echo "${RED}ERROR${DEFAULT}: $currentCall failed unexpected."
        errorOccurred=true
    fi
}

function evaluate() {
    if [ "$errorOccurred" = false ]; then
        echo "${GREEN}\xE2\x9C\x94 $1 was successful!${DEFAULT}"
    else
        echo "${RED}$1 failed!${DEFAULT}"
    fi
    
    # Resetting error
    errorOccurred=false
}

echo "Testing initial deployment"
call ${ipAddresses[0]} 0 true
call ${ipAddresses[0]} 1 false
call ${ipAddresses[0]} 2 true

call ${ipAddresses[1]} 0 true
call ${ipAddresses[1]} 1 true
call ${ipAddresses[1]} 2 false

call ${ipAddresses[2]} 0 false
call ${ipAddresses[2]} 1 false
call ${ipAddresses[2]} 2 true

# Evaluate result
evaluate "Initial deployment"

exit 0

current_ipAddress=${ipAddresses[0]}

echo "Turn gateway ${current_ipAddress} off. Expect endpoints to be not available anymore."
ssh ${addresses[0]} 'sudo systemctl stop avahi-daemon.service'
sleep sleepTime
call ${current_ipAddress} 0 false
call ${current_ipAddress} 1 false
call ${current_ipAddress} 2 false

evaluate "Testing leaving IoT gateway"

echo "Turn device ${current_ipAddress} on again. Expect endpoints to be available again."
ssh ${addresses[0]} 'sudo systemctl start avahi-daemon.service'
sleep sleepTime
call ${current_ipAddress} 0 true
call ${current_ipAddress} 1 false
call ${current_ipAddress} 2 true

evaluate "Testing joining IoT gateway"

echo "Testing joining and leaving IoT devices.."
ssh ${ipAddresses[0]} 'echo "[1]" >| /buoy/available_sensors.json'
ssh ${ipAddresses[1]} 'echo "[2]" >| /buoy/available_sensors.json'
ssh ${ipAddresses[2]} 'echo "[]" >| /buoy/available_sensors.json'

sleep sleepTime
call ${ipAddresses[0]} 0 false
call ${ipAddresses[0]} 1 true
call ${ipAddresses[0]} 2 false

call ${ipAddresses[1]} 0 false
call ${ipAddresses[1]} 1 false
call ${ipAddresses[1]} 2 true

call ${ipAddresses[2]} 0 false
call ${ipAddresses[2]} 1 false
call ${ipAddresses[2]} 2 false

evaluate "Testing joing and leaving IoT devices - case 1"

ssh ${ipAddresses[0]} 'echo "[0]" >| /buoy/available_sensors.json'
sleep sleepTime
call ${ipAddresses[0]} 0 true
call ${ipAddresses[0]} 1 false
call ${ipAddresses[0]} 2 false

evaluate "Testing joing and leaving IoT devices - case 2"

ssh ${ipAddresses[1]} 'echo "[1,2]" >| /buoy/available_sensors.json'
sleep sleepTime
call ${ipAddresses[2]} 0 false
call ${ipAddresses[2]} 1 true
call ${ipAddresses[2]} 2 true

evaluate "Testing joing and leaving IoT devices - case 3"

ssh ${ipAddresses[2]} 'echo "[0,1,2]" >| /buoy/available_sensors.json'
sleep sleepTime
call ${ipAddresses[2]} 0 true
call ${ipAddresses[2]} 1 true
call ${ipAddresses[2]} 2 true

evaluate "Testing joing and leaving IoT devices - case 4"

evaluate "Simulation"

#for index in "${!sensors[@]}"; do
#    echo ssh ${addresses[index]} echo "${sensors[index]}"
#    # >| /buoy/available_sensors.json
#done
#
#echo "Starting the Deployment Provider"
#cd $PACKAGE_PATH
#echo 'tmux new-session -d -s BuoyDeploymentProvider 'swift run BuoyDeploymentProvider --automatic-redeployment''
## The deployment runs in the tmux instance, so we cannot directly check if the initial deployment finished. Waiting 120s should be more than enough.
## sleep 120
#
## Test if initial deployment for was successful
#echo ${sensorValues[@]}
#sensorIndex=-1
#
#for index in ${!ipAddresses[@]}; do
#    call_1=$(curl -s -o /dev/null -w "%{http_code}" www.google.de)
#    call_2=$(curl -s -o /dev/null -w "%{http_code}" www.google.de)
#    echo "$call_1 - $call_2"
#    # # ${ipAddresses[index]}:8080/v1/data/${sensorNames[${sensorValues[++sensorIndex]}]}
#    if [ $call_1 -eq 200 ] && [ $call_2 -eq 200 ]; then
#        echo Call successful
#    else
#        echo $call_1 or $call_2 failed
#        exit 0
#    fi
#
#
#    echo curl -s -o /dev/null -w "%{http_code}" ${ipAddresses[index]}:8080/v1/data/${sensorNames[${sensorValues[++sensorIndex]}]}
#done
#
#echo "The initial deployment was successful."
#
## Remove
#current_ipAddress=${ipAddresses[0]}
# sensors[0]=[]
