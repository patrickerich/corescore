#!/usr/bin/env bash

# Python virtual environment
PYEXE=python3.12
THIS_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))
VENV_DIR=${THIS_DIR}/.venv
PYREQS_FILE=requirements.txt
VENV_REQS=${THIS_DIR}/${PYREQS_FILE}
VENV_NAME=$(basename ${THIS_DIR})
export VENV_ACT=${VENV_DIR}/bin/activate

# Corescore
export WORKSPACE=${THIS_DIR}
FUSESOC_CONF=${WORKSPACE}/fusesoc.conf
FUSESOC_CORES=fusesoc_cores
FUSESOC_CORES_URL=https://github.com/fusesoc/fusesoc-cores
CORESCORE_CORE=corescore
#CORESCORE_CORE_URL=https://github.com/olofk/corescore
CORESCORE_CORE_URL=.

# ########################
# ## Helper functions   ##
# ########################

function prepend_path_unique() {
    if [ -n "${PATH}" ]; then
        export PATH=$1:$(sed -r "s,(:$1$)|($1:),,g" <<< "$PATH")
    else
        export PATH=$1
    fi
}

function create_venv() {
    ${PYEXE} -m venv --prompt ${VENV_NAME} ${VENV_DIR}
    . ${VENV_ACT}
    python -m pip install --upgrade pip
    pip install wheel
    if [ ! -f ${VENV_REQS} ]; then
        printf "\n\t${PYREQS_FILE} not found...skipping\n\n"
    else
        printf "\n\tInstalling packages listed in ${PYREQS_FILE}...\n\n"
        pip install -r ${VENV_REQS}
    fi
}

function venv_setup() {
    if [ ! -d ${VENV_DIR} ]; then
        printf " - Python virtual environment NOT found\n"
        printf "  -> Setting up Python virtual environment\n"
        create_venv
    else
        printf " - Python virtual environment found\n"
        printf "  -> Activating Python virtual environment\n"
        . ${VENV_ACT}
    fi
}

function corescore_setup() {
    if [ ! -f ${FUSESOC_CONF} ]; then
        printf "\nAdding FuseSoC standard cores library\n"
        fusesoc library add ${FUSESOC_CORES} ${FUSESOC_CORES_URL}
        printf "\nAdding (local) FuseSoC corescore library\n"
        fusesoc library add ${CORESCORE_CORE} ${CORESCORE_CORE_URL}
    fi
}

# ########################
# ## Setup & run        ##
# ########################

# Create the venv if it does not already exist and/or activate it
venv_setup
# Setup the CORESCORE libraries (if they don't already exist)
corescore_setup

# Return to setup dir
cd ${THIS_DIR}
