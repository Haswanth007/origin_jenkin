######MAIN#####
git_clone ${GERRIT_PROJECT} ${WORKSPACE} ${GERRIT_REFSPEC}
if [[ ! -z ${RELEASE_FILE_PATH} ]]; then
    if [[ ! -z ${SEED_PATH} ]]; then
       echo "ERROR: Please choose one out of RELEASE_FILE_PATH, SEED_PATH"
       exit 1
    fi
    create_seed_list ${RELEASE_FILE_PATH}
    copy_seed ${RELEASE_LIST}
else
    lint_whitespaces
    lint_jenkins_files
    if [[ "${GERRIT_HOST}" = review ]]; then
        check_sandbox_parameter
    fi

    # Skip applying the seed files for patchsets
    if [[ ${GERRIT_EVENT_TYPE} == "patchset-created" ]]; then
        echo "INFO: Not applying seeds for patchsets, Seeds are applied only after merge"
        exit 0
    fi

    find_seed

    if [[ ! ${SEED_PATH} =~ ^tests/ ]]; then
        copy_seed ${SEED_PATH}
    else
        echo "Not copying seed(s), because it is in tests/ directory"
    fi
fi
# Empty space for DSL script debug information:
echo -e "=================================================\n"
