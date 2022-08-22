git-fetch-repos
===========

Bash script that fetch and pull all cloned repos.

The purpose of this script is to locate the git group directory and perform a fetch to all the repos it contains.
The git directory tree is meant as "organization/repository".
In the case of GitLab, "organization/repository" corresponds to "group/project".

The only variable that it needs is the $base_dir that define where the repos are.
When the script are lunched, we can pass a $1 to specify what organization or group we would to sync.
