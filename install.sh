#!/bin/bash

set -e

OPTIND=1

# Maps java package version to its build number.
declare -A PACKAGES

PACKAGES=(
    [7]=
    [7u1]=8
    [7u2]=13
    [7u3]=4
    [7u4]=20
    [7u5]=6
    [7u6]=24
    [7u7]=10
    [7u9]=5
    [7u10]=18
    [7u11]=21
    [7u13]=20
    [7u15]=3
    [7u17]=2
    [7u21]=11
    [7u25]=15
    [7u40]=43
    [7u45]=18
    [7u51]=13
    [7u55]=13
    [7u60]=19
    [7u65]=17
    [7u67]=14
    [7u71]=14
    [7u72]=14
    [7u75]=13
    [7u76]=13
    [7u79]=15
    [7u80]=15
    [8]=132
    [8u5]=13
    [8u11]=12
    [8u20]=26
    [8u25]=17
    [8u31]=13
    [8u40]=26
    [8u45]=14
    [8u51]=16
    [8u60]=27
)

# Package metadata. This controls which Java package is installed.
# The values are set via the parse_parameters() function.
TYPE=""
OS=""
ARCH=""

VERSION=""
declare -i MAJOR_VERSION
declare -i MINOR_VERSION
declare -i BUILD

DISPLAY_NAME=""
FILENAME=""
INSTALL_DIR=""
URL=""

# Defaults
BASE_INSTALL_DIR="/usr/java"
DEFAULT_URL="http://download.oracle.com/otn-pub/java/jdk"
DEFAULT_VERSION="8u60"
DEFAULT_TYPE="jre"



######################################################################
# Displays help information.                                         #
######################################################################
show_usage() {
    echo "$(basename "$0") [-h] [-v s] [-t s] [-s s] -- Oracle JRE/JDK installer.

where:
    -h show this help text.
    -s source url to download the package from.
    -t type of Java package to install (jdk not currently supported).
    -v JRE/JDK version to be installed (eg: 8u60)";
}



#####################################################################
# Sets the package architecture (ie: x86 or x64).                   #
#####################################################################
set_architecture() {
    if [ $(uname -m) == "x86_64" ]; then
        ARCH="x64"
    else
        ARCH="i586"
    fi
}



#####################################################################
# Sets the user-friendly package name.                              #
#####################################################################
set_display_name() {
    local type_arg="${1}"
    local major_version_arg=${2}
    local minor_version_arg=${3}
 
    DISPLAY_NAME="${type_arg^^} 1.${major_version_arg}.0"
    
    if [ -n "${minor_version_arg}" ]; then
        DISPLAY_NAME+=$(printf "_%02d" "${minor_version_arg}")
    fi
}



#####################################################################
# Sets the name of the package file to be downloaded/installed.     #
#####################################################################
set_filename() {
    local type_arg="${1}"
    local version_arg="${2}"
    local os_arg="${3}"
    local arch_arg="${4}"

    FILENAME=$(printf "%s-%s-%s-%s.rpm" "${type_arg}" "${version_arg}" "${os_arg}" "${arch_arg}")
}



#####################################################################
# Sets the package installation directory.                          #
#####################################################################
set_install_directory() {
    INSTALL_DIR="${1}/${2}${3}"
}



#####################################################################
# Sets the OS that the package will be installed on.                #
#####################################################################
set_os() {
    # TODO: Add support for Solaris, MacOS and ARM.
    OS="linux"
}



#####################################################################
# Sets the type of java package to install (jre or jdk).            #
#####################################################################
set_type() {
    local type_arg=${1,,}

    if [ "${type_arg}" != "jdk" ] && [ "${type_arg}" != "jre" ]; then
        TYPE="jre"
    else
        TYPE="${type_arg}"
    fi
}



#####################################################################
# Sets the Url that the package will be downloaded from.            # 
#####################################################################
set_url() {
    local base_arg="${1}"
    local version_arg=${2}
    local build_arg=${3}
    local filename_arg="${4}"

    if [[ "${base_arg}" == *"download.oracle.com"* ]]; then
        echo "ARGS ARE: ${base_arg} - ${version_arg} - ${build_arg} - ${filename}"
        set_oracle_url "${base_arg}" "${version_arg}" "${build_arg}" "${filename_arg}"
    else
        set_custom_url "${base_arg}" "${filename_arg}"
    fi
}



#####################################################################
# Generates the url required to download the Java package from the  #
# Oracle site.                                                      #
#####################################################################
set_oracle_url() {
    local base_arg="${1}"
    local version_arg=${2}
    local build_arg=${3}
    local filename_arg="${4}"

    if [ -n "${build_arg}" ]; then
        URL=$(printf "%s/%s-b%02d/%s" "${base_arg}" "${version_arg}" "${build_arg}" "${filename_arg}")
    else
        URL=$(printf "%s/%s/%s" "${base_arg}" "${version_arg}" "${filename_arg}")
    fi
}

#####################################################################
# Generates the url required to download the Java package from a    #
# custom endpoint.                                                  #
#####################################################################
set_custom_url() {
    local base_arg="${1}"
    local filename_arg="${2}"

     URL=$(printf "%s/%s" "${base_arg}" "${filename_arg}")
}

######################################################################
# Sets the package version, major+minor version and build number     #
# based on the selected JRE/JDK version.                             #
######################################################################
set_version_info() {
    local version_arg=${1,,}

    MAJOR_VERSION=$(echo "${version_arg}" | cut -c 1)

    if [[ "${version_arg}" == *"u"* ]]; then
        MINOR_VERSION=$(echo "${version_arg}" | cut -d"u" -f 2)
    fi

    VERSION="1.${MAJOR_VERSION}.0"

    if [ -n "${MINOR_VERSION}" ]; then
        VERSION+=$(printf "_%02d" "${MINOR_VERSION}")
    fi

    BUILD="${PACKAGES["${version_arg}"]}"
}



#####################################################################
# Generates the package metadata based off the selected package     #
# type and version.                                                 #
#####################################################################
set_package_info() {
    local version_arg="${1,,}"
    local type_arg="${2,,}"
    local url_arg="${3,,}"

    if [ -z "${version_arg}" ]; then
        version_arg="${DEFAULT_VERSION}"
    fi

    if [ -z "${type_arg}" ]; then
        type_arg="${DEFAULT_TYPE}"
    fi

    if [ -z "${url_arg}" ]; then
        url_arg="${DEFAULT_URL}"
    fi

    set_version_info "${version_arg}"
    set_type "${type_arg}"
    set_architecture
    set_os
    set_display_name "${TYPE}" "${MAJOR_VERSION}" "${MINOR_VERSION}"
    set_install_directory "${BASE_INSTALL_DIR}" "${TYPE}" "${VERSION}"
    set_filename "${TYPE}" "${version_arg}" "${OS}" "${ARCH}"
    set_url "${url_arg}" "${version_arg}" "${BUILD}" "${FILENAME}"
}



#####################################################################
# Downloads and installs the selected Java package.                 #
#####################################################################
install() {
    if [ "${OS}" == "sparc" ]; then
        printf "Sorry, SPARC is not currently supported. You will need to install ${DISPLAY_NAME} manually.\n" >&2
        exit 1
    fi

    if [[ $(rpm -qa | grep "${VERSION}" ) =~ ${VERSION} ]]; then
        echo "${DISPLAY_NAME} is already installed."
    else
        echo "Installing ${DISPLAY_NAME}..."

        if [ ! -e "${FILENAME}" ]; then
            echo "    downloading from ${URL}"
            curl --progress-bar --connect-timeout 30 --junk-session-cookies --insecure --location --max-time 3600 --retry 3 --retry-delay 60 --header "Cookie: oraclelicense=accept-securebackup-cookie" "${URL}" --output "${FILENAME}"
        fi

        yum install "${FILENAME}" -y

        if [ $(echo $?) -ne 0 ]; then
            exit 1
        fi
    fi

    if [[ ! $(alternatives --display java) =~ "/${INSTALL_DIR}/" ]]; then
        # TODO: Find a better way to do this to avoid creating 
        # multiple alternatives pointing to the same path.
        alternatives --install /usr/bin/java java "${INSTALL_DIR}/bin/java" 20000
    fi

    echo "Setting new version"
    alternatives --set java "${INSTALL_DIR}/bin/java"    
}



#####################################################################
# Configures the required environment variables
#####################################################################
configure() {
    local dirname="${1}"

    if grep -xq ".*JAVA_HOME.*" /etc/profile; then
        sed -iE "s|JAVA_HOME=.*|JAVA_HOME=/usr/java/${dirname}|g" /etc/profile
    else
        echo "export JAVA_HOME=${dirname}" >> /etc/profile
    fi

    sed -iE "s|.*export PATH=.*||g" /etc/profile

    new_path=$(echo "${PATH}" | sed -e "s|:/usr/java/.*/bin||g")
    new_path="${new_path}:${dirname}/bin"

    echo "export PATH="${new_path}"" >> /etc/profile

    source /etc/profile
}



#####################################################################
# Error handling for required CLI arguments that do not have a      #
# value set.                                                        #
#####################################################################
handle_missing_arg() {
    local opt_arg=${1}

    printf "missing argument for -%s\n" "${opt_arg}" >&2
    >&2 show_usage
    exit 1
}



#####################################################################
# Validates the user-specified Java package type.                   #
#####################################################################
validate_type() {
    local type_arg=${1,,}

    # TODO: Add support for JDK installations.
    if [ "${OPTARG,,}" != "jre" ]; then
        >&2 show_usage
        exit 1
    fi

    type="${OPTARG}"
}



#####################################################################
# Validates the user-specified Java version.                        #
#####################################################################
validate_version() {
    local version_arg=${1,,}

    if [ -z "${version_arg}" ]; then
        >&2 show_usage
        exit 1
    fi

    for key in "${!PACKAGES[@]}"; do
        if [ "${version_arg}" == "${key}" ]; then
            version_found=0
        fi
    done

    if [ "${version_found}" -ne 0 ]; then
        printf "ERROR: Unsupported Java version.\n" >&2
        exit 1
    fi
}



#####################################################################
# Displays the help screen and exists.                              #
#####################################################################
show_help() {
    show_usage
    exit 0
}



####################################################################
# Parses the provided command line arguments and loads the metadata
# for the selected JRE/JDK package.
#####################################################################
parse_args() {
    local OPTIND option a
    local version
    local java_type
    local base_url
    local version_found=-1

    while getopts ":h?v:t:s:" option; do
        case "${option}" in
            s)
                base_url="${OPTARG}"
                ;;
            v) 
                validate_version "${OPTARG}"
                version="${OPTARG}"
                ;;
            t) 
                validate_type "${OPTARG}"
                java_type="${OPTARG}"
                ;;
            :) 
                handle_missing_arg "${OPTARG}"
                ;;   
            h|\?) 
                show_help
                ;;
        esac
    done

    shift $((OPTIND -1))

    set_package_info "${version}" "${java_type}" "${base_url}"
}



parse_args "$@"
install
configure "${INSTALL_DIR}"

