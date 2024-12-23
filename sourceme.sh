#!/usr/bin/env bash
PYEXE=python3.12
#VIVADO_VERSION=2024.1
THIS_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))
VENV_DIR=${THIS_DIR}/.venv
PYREQS_FILE=requirements.txt
VENV_REQS=${THIS_DIR}/${PYREQS_FILE}
VENV_NAME=$(basename ${THIS_DIR})
export VENV_ACT=${VENV_DIR}/bin/activate

export WORKSPACE=${THIS_DIR}
export SERV=${WORKSPACE}/fusesoc_libraries/serv
FUSESOC_LIBS=${WORKSPACE}/fusesoc_libraries
SERV_LIB=${FUSESOC_LIBS}/serv
MDU_LIB=${FUSESOC_LIBS}/mdu

# Xilinx settings
#XILINX=/opt/Xilinx/Vivado/${VIVADO_VERSION}/settings64.sh
#source $XILINX


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

function serv_setup() {
    if [ ! -d ${FUSESOC_LIBS} ]; then
        printf "\nAdding FuseSoC standard library\n"
        fusesoc library add fusesoc_cores https://github.com/fusesoc/fusesoc-cores
    fi
    if [ ! -d ${SERV_LIB} ]; then
        printf "\nAdding FuseSoC SERV library\n"
        fusesoc library add serv https://github.com/olofk/serv
    fi
    if [ ! -d ${MDU_LIB} ]; then
        printf "\nAdding FuseSoC MDU library (for SERV)\n"
        fusesoc library add mdu https://github.com/zeeshanrafique23/mdu
    fi
}

# ########################
# ## Setup & run        ##
# ########################


# Create the venv if it does not already exist and/or activate it
venv_setup
# Setup the SERV libraries (if they don't already exist)
serv_setup

# Return to setup dir
cd ${THIS_DIR}
