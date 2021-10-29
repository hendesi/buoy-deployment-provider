GREEN='\033[0;32m'
DEFAULT='\033[0m'

EXEC_PATH=".build/debug/BuoyDeploymentTarget --config-file config.json --docker-compose-path buoy-deployment-provider/docker-compose.yml"

ipAddresses=( "192.168.2.116" "192.168.2.118" "192.168.2.119" )

function reset() {
    for ipAddress in "${ipAddresses[@]}"; do
        ssh ubuntu@$ipAddress "docker stop ApodiniIoTDockerInstance; docker rm ApodiniIoTDockerInstance; docker image prune -a -f"
    done
}

ssh ${addresses[0]} 'echo "[0,2]" >| /buoy/available_sensors.json'
ssh ${addresses[1]} 'echo "[0,1]" >| /buoy/available_sensors.json'
ssh ${addresses[2]} 'echo "[2]" >| /buoy/available_sensors.json'

echo "Testing normal deployment. Downloading images only on first run"
reset
for ((i=1;i<=10;i++)); do
    SECONDS=0
    ./$EXEC_PATH
    echo "$i - $SECONDS"$'\n' >> buoy_resultTimes_normal.txt
    echo "${GREEN}\xE2\x9C\x94 RUN $i done in $SECONDS${DEFAULT}"
done

sleep 120
echo "Testing with docker reset. Downloading images on every run"

for ((i=1;i<=10;i++)); do
    reset
    SECONDS=0
    ./$EXEC_PATH
    echo "$i - $SECONDS"$'\n' >> buoy_resultTimes_reset.txt
    echo "${GREEN}\xE2\x9C\x94 RUN $i done in $SECONDS${DEFAULT}"
done

sleep 120
echo "Testing without docker reset. Assuming needed images are already downloaded"

for ((i=1;i<=10;i++)); do
    SECONDS=0
    ./$EXEC_PATH
    echo "$i - $SECONDS"$'\n' >> buoy_resultTimes_noReset.txt
    echo "${GREEN}\xE2\x9C\x94 RUN $i done in $SECONDS${DEFAULT}"
done


