#!/bin/bash
set -euo pipefail
deploymentName=$1
namespace=$2
podRunningStatus() {
        count=`kubectl get deploy $deploymentName -n $namespace -o jsonpath="{.spec.replicas}"`
        echo "Number of replicas of application = $count"
        i=1

        for (( i=1; i <= $count; i++ )) do
                podName=`kubectl get po -n $namespace  | grep $deploymentName | awk NR==$i{'print $1'}`
                echo "$i pod name is $podName"
                sleep 3
                podStatus=`kubectl get po $podName -n $namespace | grep $podName | cut -d ' ' -f9`
                if [ "$podStatus" == "Running" ]; then
                        echo "$podName status is $podStatus"
                        echo "Checking if pods are running with out restart"
                        restartNumberCheck1=`kubectl get po $podName -n $namespace | grep $podName | cut -d ' ' -f12`
                        sleep 3
                        #restartNumberCheck2=`kubectl get po $podName -n $namespace | grep $podName | cut -d ' ' -f12`
                        if [ "$restartNumberCheck1" -gt "5" ]; then
                                echo "Pod is restarting. Please check"
                                break
                        else
                                echo "$podName is Running fine without any restarts"
                        fi
                else
                        echo "$podName is running with error. Please check"
                        exit 1
                fi
done
}

PSPCheck(){
        echo "Checking PSP"
        PSP=`kubectl -n $namespace get pod $podName -o jsonpath='{.metadata.annotations.kubernetes\.io\/psp}'`
        #kubectl get pod $podName -n $namespace
        # $PSP should be equal to policy name
        if [ "$PSP" == "permissive" ]; then
                echo "PSP are implemented"
        else
                echo "PSP are not implemented"
                exit 1
        fi
}

PNPCheck(){
        echo "Checking PNP"
        PNP=`kubectl get netpol tunnelfront -n $namespace | awk 'NR==2{print $1}'`
        #PNP=`kubectl get netpol -tunnelfront -n $namespace`
        # Fetch the policy name and match it with the defined vaule
        if [ "$PNP" == "tunnelfront" ]; then
                echo "PNP are implemented"
                echo "Checking if pods are attached to Network policy are not"
                podLable=`kubectl get netpol tunnelfront -n $namespace | awk 'NR==2{print $2}'`
                name=`kubectl get po -l $podLable -n $namespace | grep tunnel | awk '{print $1}'`
                if [[ ("$name" == "tunnel"*) ]]; then
                        echo "pods are attached with PNP"
                else
                        echo "pods are not attached with PNP"
                        exit 1
                fi
        else
                echo "PNP are not implemented"
                exit 1
        fi
}
# check PNP attached to pods or not

Istio(){
        echo "Checking Istio"
        count=`kubectl get deploy $deploymentName -n $namespace -o jsonpath="{.spec.replicas}"`
        echo "Number of replicas of application = $count"
        i=1
        for (( i=1; i <= $count; i++ )) do
                podName=`kubectl get po -n $namespace  | grep $deploymentName | awk NR==$i{'print $1'}`
                echo "$i pod name is $podName"
                sleep 3
                podLable="istio.io/rev=default"
                name=`kubectl get po -l $podLable -n $namespace | grep $podName | awk '{print $1}'`
                if [[ ("$name" == "$podName") ]]; then
                        echo "pods are attached with PNP"
                else
                        echo "pods are not attached with PNP"
                        exit 1
                fi
        done
}

APIFileCreation(){
cat <<'EOF' >> api-check.yml
apiVersion: batch/v1
kind: Job
metadata:
  name: api-check
  namespace: default
  labels:
     app: api-check
spec:
    template:
        spec:
          hostPID: true
          containers:
          - name: api-check
            image: srikanth0379/curl:latest
            args:
              - /bin/bash
              - -c
              - date; curl -k -X GET http://nginx.jenkins.svc.cluster.local:80/status
            resources:
              requests:
                cpu: "1m"
                memory: "40Mi"
              limits:
                cpu: "2m"
                memory: "80Mi"
          restartPolicy: OnFailure
EOF
}

APICheck(){
        echo "checking the API"
        kubectl delete job api-check || true
        kubectl apply -f api-check.yml
        sleep 30
        jobStatus=`kubectl get po | grep api-check | awk '{print $3}'`
        if [ "$jobStatus" == "Completed" ]; then
                echo "API check passed. Application is Running fine"
        else
                echo "API check Failed"
        fi
        #rm -rf api-check.yml
}

echo "##################################################################"
echo "################# Pod Running Status #############################"
echo "##################################################################"
podRunningStatus
echo "##################################################################"
echo "################# Running PSP Check ##############################"
echo "##################################################################"
PSPCheck
echo "##################################################################"
echo "################# Running PNP Check ##############################"
echo "##################################################################"
#PNPCheck
#Istio
echo "##################################################################"
echo "################# Running API Check ##############################"
echo "##################################################################"
APIFileCreation
#APICheck

exit 0