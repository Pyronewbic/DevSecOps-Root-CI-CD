cp -f backup.properties sonar-project.properties
cat sonar-project.properties
echo $services
key="CDP-FE-${ENV_LABEL}"
echo "Performing (${ENV_LABEL}) sonar-scan"
echo "" >> sonar-project.properties
echo "sonar.projectKey=$key" >> sonar-project.properties
echo "sonar.projectName=Corporate Digital Frontend (${ENV_LABEL})" >> sonar-project.properties
cat sonar-project.properties
echo "sonar.token=$1"  >> sonar-project.properties
echo "sonar.host.url=$SONARQUBE_URL" >> sonar-project.properties

#cat test-report.xml
echo -e "\n"
#cat coverage/lcov.info
#echo -e "\n"
echo "Running Sonar scanner!"
${SS_PATH}/bin/sonar-scanner
echo "Sleeping 30s for reports to populate"
#sleep 30s


#key=$(cat key.txt)
#json=$(curl -k -u $1: "${SONARQUBE_URL}/api/qualitygates/project_status?projectKey=$key" | jq -r '.projectStatus.status')
#echo $json
#if [[ "$json" == "OK" ]]
#then
#    echo "Sonar Quality gates have passed for Key: ${key}!"
#else
#    echo "Sonar Quality gates have Failed for Key: ${key}!"
#    exit 1
#fi
