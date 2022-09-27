echo $SERVICES
cp -f backup.properties sonar-project.properties

key="CDP-BE-${ENV_LABEL}-$1"
echo "Performing (${ENV_LABEL}) sonar-scan for $1"
echo "" >> sonar-project.properties
echo "sonar.projectKey=$key" >> sonar-project.properties
echo "sonar.projectName=CDP BE $1 (${ENV_LABEL})" >> sonar-project.properties
echo "sonar.sources=apps/$1" >> sonar-project.properties
echo "sonar.tests=apps/$1" >> sonar-project.properties
cat sonar-project.properties
echo "sonar.token=$SONAR_TOKEN"  >> sonar-project.properties
echo "sonar.host.url=$SONARQUBE_URL" >> sonar-project.properties
# echo "$WORKSPACE" >> temp.txt
# sed -i "s/[//]/+/g" temp.txt
# wk=$(cat temp.txt)
# sed -i 's/[//]/+/g' test-report.xml
# sed -i "s/$wk/+usr+src/g" test-report.xml
# echo "Performing sed manips on test-report.xml"
# sed -i "s/+/\//g" test-report.xml
echo -e "\n"
echo "Running Sonar scanner!"
${SS_PATH}/bin/sonar-scanner
echo "Sleeping 10s for reports to populate"
sleep 10s

json=$(curl -k -u $SONAR_TOKEN: "${SONARQUBE_URL}/api/qualitygates/project_status?projectKey=$key" | jq -r '.projectStatus.status')
echo $json
# if [[ "$json" == "OK" ]]
# then
#   echo "Sonar Quality gates have passed for Key: ${key}!"
# else
#   echo "Sonar Quality gates have Failed for Key: ${key}!"
#   exit 1
# fi
