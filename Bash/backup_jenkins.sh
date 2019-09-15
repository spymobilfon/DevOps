#!/bin/bash

# - Prepare git repository directory (JENKINS_HOME)
#   cd /var/lib/jenkins
#   sudo git init
#   sudo git remote add origin git@github.com:username/repo.git
# - Create job in Jenkins
#   - mark "None" for Source Control Management
#   - select the "Build Periodically" build trigger
#   - add new "Execute Shell" build step

# Change to Jenkins work directory
cd /var/lib/jenkins

# Add general configurations, job configurations, user content, ssh key
git add -- *.xml jobs/*/*.xml userContent/* .ssh/*

# Add user configurations if they exist
if [ -d users ]; then
    user_configs=`ls users/*/config.xml`

    if [ -n "$user_configs" ]; then
        git add $user_configs
    fi
fi

# Mark as deleted that has been deleted
to_remove=`git status | grep "deleted" | awk '{print $3}'`

if [ -n "$to_remove" ]; then
    git rm --ignore-unmatch $to_remove
fi

# Set timestamp
timestamp=$(date +"%Y.%m.%d %H:%M")
# Commit
git commit -m "Backup Jenkins configurations at $timestamp"
# Push
git push -q -u origin master