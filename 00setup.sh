#!/usr/bin/env bash
sudo apt-get --yes update \
&& sudo apt-get --yes install jq \
&& sudo apt-get --yes install unzip || log "ERROR: failed update" $?

KOPS_FLAVOR="kops-linux-amd64"
KOPS_VERSION="v1.20.0"
KOPS_URL="https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/${KOPS_FLAVOR}"

KUBECTL_VERSION="v1.20.6"
KUBECTL_URL="https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

TERRAFORM_VERSION="0.12.29"
TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

log()
{
         exit_code=$2
		 if [ -z $2 ]; then
		    exit_code=0
		 fi

		 echo "[`date '+%Y-%m-%d %T'`]:" $1
		 if [ ${exit_code} -ne "0" ]; then
		   exit ${exit_code}
		 fi
}

setup_kops(){

    log "INFO: Start kops download  -> Version : ${KOPS_VERSION} and Flavor: ${KOPS_FLAVOR}"
    curl -sLO ${KOPS_URL} || log  "ERROR: download failed"  $?
    log "INFO: download complete"

    chmod +x ${KOPS_FLAVOR} || log "ERROR: Cannot set the executable permission" $?

    if [ -d '/usr/local/bin' ]; then
        sudo mv kops-linux-amd64 /usr/local/bin/kops || log "ERROR: moving kops failed"  $?
    else
        log "ERROR: /usr/local/bin dir not found"
    fi

    log "INFO: kops setup done -> Version : ${KOPS_VERSION} and Flavor: ${KOPS_FLAVOR}"

    echo "======================================================================================"
    setup_kubectl

}

setup_kubectl(){

    log "INFO: Start kubectl download"
    curl -sLO ${KUBECTL_URL} || log  "ERROR: download failed" $?
    log "INFO: download complete"

    chmod +x kubectl || log "ERROR: Cannot set the executable permission" $?

    if [ -d '/usr/local/bin' ]; then
        sudo mv kubectl /usr/local/bin/kubectl || log "ERROR: moving kubectl failed" $?
    else
        log "ERROR: /usr/local/bin dir not found"
    fi

    log "INFO: kubectl setup done ->  Version : ${KUBECTL_VERSION}"

}

setup_tf(){

    log "INFO: download Terraform -> Version ${TERRAFORM_VERSION}"
    curl -sLO ${TERRAFORM_URL} || log  "ERROR: download failed" $?
    log "INFO: download complete"

    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip || log "ERROR: Unzipping terraform_${TERRAFORM_VERSION}_linux_amd64.zip" $?

    chmod +x terraform || log "ERROR: Cannot set the executable permission" $?

    if [ -d '/usr/local/bin' ]; then
        sudo mv terraform /usr/local/bin/terraform || log "ERROR: moving Terraform failed"  $?
    else
        log "ERROR: /usr/local/bin dir not found"
    fi
}

verify_install(){

    log "INFO: VERIFY KOPS"

    export PATH=${PATH}:/usr/local/bin/

    kops --help  >/dev/null 2>&1 || log "ERROR: kops verification failed" $?

    log "INFO: VERIFY KUBECTL"

    kubectl --help >/dev/null 2>&1 || log "ERROR: kubectl verification failed" $?

    log "INFO: VERIFY TERRAFORM"

    terraform --version || log "ERROR: terraform verification failed" $?

    log "INFO: Validation Successful !!!"

    rm -f terraform_0.11.13_linux_amd64.zip || log "ERROR: terraform zip cleanup failed" $?

}


echo "======================================================================================"
setup_kops
sleep 2
echo "======================================================================================"
setup_tf
sleep 2
echo "======================================================================================"
verify_install
echo "======================================================================================"