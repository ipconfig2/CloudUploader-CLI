#!/bin/bash

# A script that will will enable users to upload files via the cli

setup() { 
    # Install az cli
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    # Login
    az login --use-device-code
    echo "You're logged in."
}



setup
