#!/bin/bash
set -euo pipefail
NAMESPACE=$1
ENVIRONMENT=$2

namespaceCheck(){
echo "Checking namespace"
ns=$(kubectl get namespace)
if [[ ($ns == *"$NAMESPACE"* && $ns == *"Active"*) ]]; then
    echo "Namespace $NAMESPACE is already there"
else
    echo "Namespace $NAMESPACE does not exist"> error.txt
    exit 1
fi
}

rbacCheck(){
    echo "Check RBAC authorization"
    rbac=$(kubectl api-versions |grep rbac)
    if [[ ($rbac == *"rbac.authorization"*) ]]; then
        echo "RBAC authorization is enabled"
    else
        echo "RBAC authorization is not enabled" >> error.txt
        exit 1
    fi
}

PSPCheck(){
    echo  "Checking PSP"
    PSP=`kubectl get psp $1`
    if [ "$?" -eq "0" ]; then
        echo "PSP are implemented"
    else
        echo "PSP are not implemented"
        exit 1
    fi
}

PNPCheck() {
    echo  "Checking Pod network policy"
    PNP=`kubectl get netpol -n $NAMESPACE`
    if [ "$?" -eq "0" ]; then
        echo "PNP are implemented"
    else
        echo "PNP are not implemented"
        exit 1
    fi
}

Istio(){
    echo  "Checking Istio"
    istioNamespace=`kubectl get ns | grep istio-system | awk '{print $1}'`
    if [ "$istioNamespace" == "istio-system" ]; then
        kubectl get po -n istio-system | grep istiod | awk '{print $1}'
        if [ "$?" -eq "0" ]; then
            echo "Istio is in place"
        else
            echo "Istio is not in place"
            exit 1
        fi
    fi
}

#Resources limit check need to be added
echo "##################################################################"
echo "################# Pod NAMESPACE Status ###########################"
echo "##################################################################"
namespaceCheck

echo "##################################################################"
echo "################# Running RBAC Check #############################"
echo "##################################################################"
rbacCheck

if [ "$ENVIRONMENT" == "PROD" ]; then
    echo "##################################################################"
    echo "################# Running PSP Check ##############################"
    echo "##################################################################"
    # PSPCheck eks.privileged
else
    echo "PSPCheck is not applicable for $ENVIRONMENT"
fi

if [ "$ENVIRONMENT" == "UAT" ] || [ "$ENVIRONMENT" == "PROD" ]; then
    echo "##################################################################"
    echo "################# Running PNP Check ##############################"
    echo "##################################################################"
#PNPCheck
    Istio
else
    echo "PNPCheck is not applicable for $ENVIRONMENT"
fi

exit 0