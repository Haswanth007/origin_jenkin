set -xe
copy_seed(){
    # Split comma separated seed list
    # copy all seed.groovy files with prefixed dir name
    # param - comma separated relative paths of seed.groovy
    # “${BUILD_NUMBER}/seed_<seeddirname>.groovy” is a hardcoded path
    # for ‘Process Job DSLs’ part of the job.
    # See cicd/SuperSeed/seed.groovy file.
    mkdir -p ${WORKSPACE}/${BUILD_NUMBER}
    seed_list=$(echo $1 | tr “,” “\n”)
    for seed in $seed_list; do
        seed_file=“${WORKSPACE}/${seed}”
        if [ -f ${seed_file} ]; then
            # copy dependency file(s)
            grep -E “evaluate\(.+\.groovy.?\)” “${seed_file}” | while read -r match ; do
                eval dep_file_target_loc=$(echo “$match” | cut -d ‘“’ -f2)
                dep_file_name=$(basename “$dep_file_target_loc”)
                dep_file_loc=$(find ${WORKSPACE} -name “$dep_file_name”)
                cp -a $dep_file_loc $dep_file_target_loc
            done            # suffix directory name to seed to identify multiple seeds
            # convert ‘-’ to ‘_’ to avoid dsl script name error
            seed_dir=$(dirname ${seed} | awk -F ‘/’ ‘{print $NF}’ | tr ‘-’ ‘_’)
            cp -a ${seed_file} ${WORKSPACE}/${BUILD_NUMBER}/seed.groovy
        else
            # Fail the build if file doesn’t exists:
            echo “ERROR: ${seed_file} not found”
            exit 1
        fi
    done
}
get_seed(){
    # recursive search of seed.groovy for a Jenkinsfile
    # Lookup in same or higher level directories
    SEED=‘’
    dir_path=$1
    set +e
    FILE=`ls ${WORKSPACE}/${dir_path}/ | egrep “*seed*.groovy”`
    if [ $FILE ]; then
       # found seed for the Jenkinsfile
       SEED=“${dir_path}/$FILE”
        return
    fi
    up_dir=$(dirname ${dir_path})
    if [ ${up_dir} == “.” ]; then
        # reached top level dir
        echo “ERROR: seed file not found in ${dir_path}/...”
        exit 1
    fi
    # check seed in one level higher directory
    get_seed ${up_dir}
}
find_seed(){
		LAST_2COMMITS=`git log -2 --reverse --pretty=format:%H`
        # Looking for added or modified seed.groovy files or Jenkinsfiles or only superseed.sh:
        MODIFIED_FILES=`git diff --name-status --no-renames ${LAST_2COMMITS} | egrep “*.groovy”| cut -f2`
        if [ ! -z “${MODIFIED_FILES}” ]; then
            for file in ${MODIFIED_FILES}; do
                # lookup seed.groovy
                get_seed “$(dirname ${file})”
                if [[ -z “${SEED_PATH}” ]]; then
                    # set first time
                    SEED_PATH=${SEED}
                elif [[ ! ${SEED_PATH} =~ ${SEED} ]]; then
                    # if seed not already present, append to it
                    SEED_PATH=${SEED_PATH},${SEED}
                fi
            done
		fi
    export SEED_PATH=$SEED_PATH
    echo “INFO: SEED_PATH is [${SEED_PATH}]”
}
######MAIN#####find_seed
   copy_seed ${SEED_PATH}
# Empty space for DSL script debug information:
echo -e “=================================================“#!/bin/bash
set -xe
copy_seed(){
    # Split comma separated seed list
    # copy all seed.groovy files with prefixed dir name
    # param - comma separated relative paths of seed.groovy
    # “${BUILD_NUMBER}/seed_<seeddirname>.groovy” is a hardcoded path
    # for ‘Process Job DSLs’ part of the job.
    # See cicd/SuperSeed/seed.groovy file.
    mkdir -p ${WORKSPACE}/${BUILD_NUMBER}
    seed_list=$(echo $1 | tr “,” “\n”)
    for seed in $seed_list; do
        seed_file=“${WORKSPACE}/${seed}”
        if [ -f ${seed_file} ]; then
            # copy dependency file(s)
            grep -E “evaluate\(.+\.groovy.?\)” “${seed_file}” | while read -r match ; do
                eval dep_file_target_loc=$(echo “$match” | cut -d ‘“’ -f2)
                dep_file_name=$(basename “$dep_file_target_loc”)
                dep_file_loc=$(find ${WORKSPACE} -name “$dep_file_name”)
                cp -a $dep_file_loc $dep_file_target_loc
            done
            random_string=$(head /dev/urandom | tr -dc A-Za-z | head -c 6)
            # suffix directory name to seed to identify multiple seeds
            # convert ‘-’ to ‘_’ to avoid dsl script name error
            seed_dir=$(dirname ${seed} | awk -F ‘/’ ‘{print $NF}’ | tr ‘-’ ‘_’)
            cp -a ${seed_file} ${WORKSPACE}/${BUILD_NUMBER}/seed_${random_string}_${seed_dir}groovy
        else
            # Fail the build if file doesn’t exists:
            echo “ERROR: ${seed_file} not found”
            exit 1
        fi
    done
}
get_seed(){
    # recursive search of seed.groovy for a Jenkinsfile
    # Lookup in same or higher level directories
    SEED=‘’
    dir_path=$1
    set +e
    FILE=`ls ${WORKSPACE}/${dir_path}/ | egrep “*seed*.groovy”`
    if [ $FILE ]; then
       # found seed for the Jenkinsfile
       SEED=“${dir_path}/$FILE”
        return
    fi
    up_dir=$(dirname ${dir_path})
    if [ ${up_dir} == “.” ]; then
        # reached top level dir
        echo “ERROR: seed file not found in ${dir_path}/...”
        exit 1
    fi
    # check seed in one level higher directory
    get_seed ${up_dir}
}
find_seed(){
		LAST_2COMMITS=`git log -2 --reverse --pretty=format:%H`
        # Looking for added or modified seed.groovy files or Jenkinsfiles or only superseed.sh:
        MODIFIED_FILES=`git diff --name-status --no-renames ${LAST_2COMMITS} | egrep “*.groovy”| cut -f2`
        if [ ! -z “${MODIFIED_FILES}” ]; then
            for file in ${MODIFIED_FILES}; do
                # lookup seed.groovy
                get_seed “$(dirname ${file})”
                if [[ -z “${SEED_PATH}” ]]; then
                    # set first time
                    SEED_PATH=${SEED}
                elif [[ ! ${SEED_PATH} =~ ${SEED} ]]; then
                    # if seed not already present, append to it
                    SEED_PATH=${SEED_PATH},${SEED}
                fi
            done
		fi
    export SEED_PATH=$SEED_PATH
    echo “INFO: SEED_PATH is [${SEED_PATH}]”
}
######MAIN#####find_seed
   copy_seed ${SEED_PATH}
# Empty space for DSL script debug information:
echo -e “=================================================”
