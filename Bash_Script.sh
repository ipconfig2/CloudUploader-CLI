#!/bin/bash

# A script that will enable users to upload files via the CLI

Authentication() { 
    # Install az cli
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    # Login
    az login --use-device-code
    echo "You're logged in."
}

# Print out 5 recommended regions
print_out_regions() {
    regions_array=($( az account list-locations --query "[?metadata.regionCategory=='Recommended'].{Name:name}" -o tsv | head -n 5))
    for i in "${regions_array[@]}"
    do
       echo "$i"
    done
}

# Select a region Function
check_region() {
    local region_exists=false
    while [[ "$region_exists" = false ]];  do
        print_out_regions
        read -p "Enter your region: " selected_region
        for j in "${regions_array[@]}"
        do
            if [[ "$selected_region" == "$j" ]]; then
                region_exists=true
                echo "Region exists"
                break
            else
                continue
            fi
        done
    done
}

    # Check if the resource group already exists.
check_resource_group () {
    while true; do
        read -p "Enter a name for your resource group: " resource_group
        if [ $(az group exists --name $resource_group) = true ]; then 
            echo "The group $resource_group exists in $selected_region, please provide another name..."
        else
            break
        fi
    done
}

# Create the resource group
create_resource_group () {
    echo "Creating resource group: $resource_group in $selected_region"
    az group create -g $resource_group -l $selected_region | grep provisioningState
}

#List all resource groups
list_resource_groups() {
    az group list -o table
}

#Creates Storage account, Container, list Blob, Upload blob

CreateStorageAccount() {
        while true; do
            read -p "Enter storage account name: " storageaccountname
            # Checks if the name already exists
            if [ "$(az storage account --name "$storageaccountname")" = true ]; then 
                echo "The name $storageaccountname is already taken, please provide another name..."
            else
                # Command to create a storage account
                az storage account create --name "$storageaccountname" --resource-group "$resource_group" --location "$selected_region" --sku Standard_ZRS --encryption-services blob
                # Command to list storage accounts
                az storage account list -g "$resource_group"
                break
            fi
        done
    # Get the connection string for the storage account
connection_string=$(az storage account show-connection-string --name $storageaccountname --resource-group $resource_group --output tsv)
}

CreateContainer(){
    
        while true; do
            read -p "Enter Container name: " Container
            # Checks if the name already exists
            if [ "$(az storage container --name "$Container")" = true ]; then 
                echo "The name $Container is already taken, please provide another name..."
            else
                # Command to create a Container
                az storage container create --account-name $storageaccountname --name $Container  --auth-mode login
                # Command to list Container
                az storage container list
                break
            fi
        done
}

CheckFile(){
    # Azure Storage Account and Container information
    echo "filename: $FILE_NAME"
    # Check if the blob exists
    az storage blob show -c $Container -n $FILE_NAME 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "File already exists in Azure Storage."
    else
        echo "Name not taken"
    fi
}

UploadFile(){
    #upload file
    export STORAGE_KEY=$(az storage account keys list --resource-group $resource_group --account-name $storageaccountname | jq -r '.[0].value')
    az storage blob upload --account-name $storageaccountname --container-name $Container --name $FILE_NAME --file $FILE_NAME --account-key $STORAGE_KEY --auth-mode key
    echo "uploaded"
    }

CheckFile2(){
    # Azure Storage Account and Container information
    echo "filename: $FILE_NAME_2"
    # Check if the blob exists
    az storage blob show -c $Container -n $FILE_NAME_2 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "File already exists in Azure Storage."
    else
        echo "Name not taken"
    fi
}

UploadFile2(){
    #upload file
echo "connection_string: $connection_string"
    export STORAGE_KEY=$(az storage account keys list --resource-group $resource_group --account-name $storageaccountname | jq -r '.[0].value')
    az storage blob upload --account-name $storageaccountname --container-name $Container --name $FILE_NAME_2 --file $FILE_NAME_2 --account-key $STORAGE_KEY --auth-mode key
    echo "uploaded"
    }

#non-function script below

Option=$1  # The 1st filename passed as an argument
FILE_NAME=$2  # The 2nd filename passed as an argument
FILE_NAME_2=$3  # The 2nd filename passed as an argument

#Authentication

# Prompt User
    echo "Would you like to create a new resource GRP? (Y/N)"
    read answer

    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then 
        check_region
        check_resource_group
        create_resource_group
        list_resource_groups
    else
        echo "What is the name of the premade resource group you would like to use?"
        read resource_group
    fi
    
     #Create Storage account
    echo "Would you like to create a new storage account? (Y/N)"
    read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
    CreateStorageAccount
    else
        echo "What is the name of the premade storageaccount you would like to use?"
        read storageaccountname
    fi
    
    #Create Container 
    echo "Would you like to create a new Container? (Y/N)"
    read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
    CreateContainer
      else
        echo "What is the name of the premade container you would like to use?"
        read Container
    fi

   if [ "$Option" == "-m" ] || [ "$Option" == "-s" ]; then
    # ... (other parts of your script)

    CheckFile
    UploadFile

    if [ "$Option" == "-m" ]; then
        CheckFile2
        UploadFile2
    else
        echo "no second file"
    fi
else
    echo "Incorrect use of command"
fi
