#!/bin/bash


###################################################################################################################
##
##  NAME
##  fetch.sh
##
##  SUMMARY
##  The purpose of this script is to locate the git group directory and perform a fetch to all the repos it contains.
##  The git directory tree is meant as "organization/repository".
##  In the case of GitLab, "organization/repository" corresponds to "group/project".
##
##  DETAILS
##  This script do a "find" starting from a defined base directory.
##  The results of the "find" correspond to a list of "organization" folders ("group" in GitLab), that will be passed 
##  to a "for" loop that contain another "find" to identify the individual repository ("project" in GitLab).
##  The main function take the path of all repos that will be fetched starting from the $base_dir.
##  Firstly, for each repository sync, it fetch the data and, if there is any new code, it try to pull starting from the 
##  current branch.
##  All the output are reported and there is no filter for STDERR and STDOUT.
##
###################################################################################################################
##
##  WORKLOG:
##  2022-05-01		Enrico C.					Initial draft.
##  2022-06-01		Enrico C.					Refactoring and introducing variable.
##  2023-09-05		Enrico C.					Adding semicolon and pulling list of tags.
##
###################################################################################################################


## Color Table.
Green='\033[0;32m'        # Green
Cyan='\033[0;36m'         # Cyan
# Reset.
NC='\033[0m'              # Color Text Reset


####################################################################################################################


## Variables.
base_dir="/some/existing/path"

# Setting which ones (single group or all groups) will be fetched.
# $groups variable.
if [[ -z $1 ]]; then
    echo -e " ${Green}Fetching all cloned repos${NC}";
    groups=$(find $base_dir/ -maxdepth 1 -type d | tail -n +2 );
else
    echo -e " ${Green}Fetching all repos inside ${1} group${NC}";
    groups=$(realpath $(ls -d $base_dir/$1));
fi


####################################################################################################################


## Function.
# Set the function that will fetch and pull all repositories.
git-fetch-repo-in-group-folder ()
{
    # Set the "if" the pick up the current repo and fetch it .
    if [[  -d "$repo_group/$repo_name" ]]; then
        echo -e "--- Fetching the ${Cyan}$group_name/$repo_name${NC} directory ---";
        git -C "$repo_group/$repo_name" fetch origin --progress --prune --prune-tags 2>&1 | grep " ";
        if [ $? == 0 ]; then
            echo -e "\n- Upgrading ${Cyan}$(git -C "$repo_group/$repo_name" rev-parse --abbrev-ref HEAD)${NC} branch";
            git -C "$repo_group/$repo_name" pull origin --autostash --force;
            echo -e "\n- Upgrading tags list";
            git -C "$repo_group/$repo_name" pull origin --tags --force;
        fi;
    fi;
    echo "";
}


####################################################################################################################

## Script.
# This "for loop" sync all the repo started from this directory.
for repo_group in $groups;
do
    projects=$(find $repo_group/ -maxdepth 1 -type d | tail -n +2 | awk -F "/" '{ print $(NF) }');
    group_name=$(ls -d $repo_group | awk -F "/" '{ print $(NF) }');
    for repo_name in $projects;
    do
        echo "";
        echo -e " ${Green}Fetching the $repo_group group${NC} ";
        echo "";
        cd $base_dir/;
        git-fetch-repo-in-group-folder;
    done
done
