#!/bin/bash


function commit () {

    git commit -am "[ci skip] ${1}" 

}

function push () {
    ### TODO THIS NEEDS TO BE WORKING ###
    git push -o [ci skip] "https://${GITHUB_USER}:${GITHUB_TOKEN}@${REPO_URL#*@}" ${GITHUB_SHA}

}


function tf_check_fmt () {
    set +e
    terraform fmt -check -recursive
    result=$?
    echo "Last exist code: $result"
    echo "ran from: $(pwd)"
    set -e
    if [ $result -ne 0 ]; then
        echo "There are formatting errors. Please review the changes below."
        echo "If the changes are acceptable, run "terraform fmt -recursive" on the root project and update the merge request."
        terraform fmt -diff -recursive
        exit 1
    fi
}

function _tf_dirs () {
    dirs=$(find . -type f -name "*.tf" | grep -v ".terraform" | rev | cut -d '/' -f 2- | rev | sort -u)
    for d in $dirs; do
        echo "Processing directory: $d"
        $1
    done
}

function docs () {
    terraform-docs markdown table --output-check --output-file README.md --output-mode inject 
}

function tf_auto_fmt () {
  terraform fmt -recursive
  commit "Github CI update terraform files fmt $(date)."
}

function tf_auto_docs () {
    dirs=$(find . -type f -name "*.tf" | grep -v ".terraform" | rev | cut -d '/' -f 2- | rev | sort -u)
    for d in $dirs; do
        echo "Processing directory: $d"
        terraform-docs markdown table --output-file README.md --output-mode inject $d
        result+=$?
    done
    commit "Github CI update terraform docs $(date)."

}

function tf_check_docs () {

    set +e
    dirs=$(find . -type f -name "*.tf" | grep -v ".terraform" | rev | cut -d '/' -f 2- | rev | sort -u)
    for d in $dirs; do
        echo "Processing directory: $d"
        terraform-docs markdown table --output-check --output-file README.md --output-mode inject $d
        result+=$?
    done
    set -e
    if [ $result -ne 0 ]; then
        echo "There are doc updates that have not been staged."
        exit 1
    fi
}

function tf_validate () {
    terraform init -backend=false ${PLUGIN_DIR}
    terraform validate

}


# Evaluate input
case $1 in
    validate)
        echo "Running Terraform Validate."
        tf_validate
        ;;
    check-fmt)
        echo "Running tf format check."
        tf_check_fmt
        ;;
    
    check-docs)
        echo "Running tf doc check."
        tf_check_docs
        ;;
    auto-fmt)
        echo "Running tf auto format."
        tf_auto_fmt
        ;;
    
    auto-docs)
        echo "Running tf auto doc."
        tf_auto_docs
        ;;
    auto-update)
        echo "Updating tf docs and format."
        tf_auto_fmt
        tf_auto_docs
        ;;
    *)
        echo "Invalid option."
        echo "Valid Options are validate, check-fmt, check-docs, auto-fmt, auto-docs or auto-update."
        ;;
esac