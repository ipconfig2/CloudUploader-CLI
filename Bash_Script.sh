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
      az storage blob show --account-name $storageaccountname --account-key "$STORAGE_KEY" --container-name $Container --name $FILE_NAME
    if [ $? -eq 0 ]; then
        echo "File already exists in Azure Storage."
        read -p "Do you want to (O)verwrite, (S)kip, or (R)ename the file? [O/S/R]: " user_decision
        case $user_decision in
            O|o)
                echo "Overwriting the existing file..."
                UploadFile
                ;;
            S|s)
                echo "Skipping the upload..."
                ;;
            R|r)
                read -p "Enter a new name for the file: " new_file_name
                # Rename the file in the shell
                mv "$FILE_NAME" "$new_file_name"
                # Update the FILE_NAME variable
                FILE_NAME="$new_file_name"
                echo "File renamed to: $FILE_NAME"
                UploadFile
                ;;
            *)
                echo "Invalid option. Skipping the upload."
                ;;
        esac
    else
        echo "File does not exist in Azure Storage."
        UploadFile
    fi
}

UploadFile(){
    #upload file
    export STORAGE_KEY=$(az storage account keys list --resource-group $resource_group --account-name $storageaccountname | jq -r '.[0].value')
        #upload command 
    az storage blob upload --account-name $storageaccountname --container-name $Container --name $FILE_NAME --file $FILE_NAME --account-key $STORAGE_KEY --auth-mode key 
    echo "uploaded"
    Link1
    }

CheckFile2(){
    # Azure Storage Account and Container information
    echo "filename: $FILE_NAME_2"
    export STORAGE_KEY=$(az storage account keys list --resource-group $resource_group --account-name $storageaccountname | jq -r '.[0].value')
    # Check if the blob exists
    az storage blob show --account-name $storageaccountname --account-key "$STORAGE_KEY" --container-name $Container --name $FILE_NAME_2
    if [ $? -eq 0 ]; then
        echo "File already exists in Azure Storage."
        read -p "Do you want to (O)verwrite, (S)kip, or (R)ename the file? [O/S/R]: " user_decision
        case $user_decision in
            O|o)
                echo "Overwriting the existing file..."
                UploadFile2
                ;;
            S|s)
                echo "Skipping the upload..."
                ;;
            R|r)
                read -p "Enter a new name for the file: " new_file_name_2
                # Rename the file in the shell
                mv "$FILE_NAME_2" "$new_file_name_2"
                # Update the FILE_NAME variable
                FILE_NAME_2="$new_file_name_2"
                echo "File renamed to: $FILE_NAME_2"
                UploadFile2
                ;;
            *)
                echo "Invalid option. Skipping the upload."
                ;;
        esac
    else
        echo "File does not exist in Azure Storage."
        UploadFile2
    fi
}

UploadFile2(){
    #upload file
echo "connection_string: $connection_string"
    export STORAGE_KEY=$(az storage account keys list --resource-group $resource_group --account-name $storageaccountname | jq -r '.[0].value')
    #upload command
    az storage blob upload --account-name $storageaccountname --container-name $Container --name $FILE_NAME_2 --file $FILE_NAME_2 --account-key $STORAGE_KEY --auth-mode key 
    echo "uploaded"
    Link1
    Link2
    }

Link1(){
     # Generate a SAS token for a blob
    sas_token=$(az storage blob generate-sas --account-name $storageaccountname --container-name $Container --name $FILE_NAME --permissions acdrw --expiry $(date -u -d "1 week" '+%Y-%m-%dT%H:%MZ') --output tsv)
    #Check if the sas token works
 if [ -z  "$sas_token" ] || [[  $sas_token == *"ERROR"* ]];then
        echo "Failed to generate a shareable link for $blob_name.Error: $sas_token"        
	return 1
    fi

    blob_url="https://${storageaccountname}.blob.core.windows.net/${Container}/${FILE_NAME}?${sas_token}"
    echo $blob_url
}

Link2(){
     # Generate a SAS token for a blob
    sas_token=$(az storage blob generate-sas --account-name $storageaccountname --container-name $Container --name $FILE_NAME_2 --permissions acdrw --expiry $(date -u -d "1 week" '+%Y-%m-%dT%H:%MZ') --output tsv)
    #Check if the sas token works
 if [ -z  "$sas_token" ] || [[  $sas_token == *"ERROR"* ]];then
        echo "Failed to generate a shareable link for $blob_name.Error: $sas_token"        
	return 1
    fi
    # Construct the URL with the SAS token
    blob_url="https://${storageaccountname}.blob.core.windows.net/${Container}/${FILE_NAME_2}?${sas_token}"
    echo $blob_url
}
#non-function script below

Option=$1  # The 1st filename passed as an argument
FILE_NAME=$2  # The 2nd filename passed as an argument
FILE_NAME_2=$3  # The 2nd filename passed as an argument

Authentication

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

    CheckFile

    if [ "$Option" == "-m" ]; then
        CheckFile2
    else
        echo "Single file"
    fi

else
    echo "Incorrect use of command"
fi
