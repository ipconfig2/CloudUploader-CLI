# File Upload Script for Azure Storage

This Bash script facilitates the upload of files to Azure Storage using the Command Line Interface (CLI). It includes functions for authentication, region selection, resource group creation, storage account creation, container creation, and file upload.

## Prerequisites

1. **Azure Account**: You need an active Azure account. If you don't have one, you can [create a free account](https://azure.microsoft.com/free/) before using this script.

## Installation

1. Clone the repository to your local machine:

    ```bash
    git clone https://github.com/yourusername/azure-file-upload-script.git
    ```

2. Navigate to the script directory:

    ```bash
    cd azure-file-upload-script
    ```

3. Make the script executable:

    ```bash
    chmod +x upload_script.sh
    ```

## Usage

1. Run the script for multiple files using the `-m` option:

    ```bash
    ./upload_script.sh -m <file1> <file2>
    ```

    - Replace `<file1>` and `<file2>` with the actual file names.

2. Run the script for a single file using the `-s` option:

    ```bash
    ./upload_script.sh -s <single_file>
    ```

    - Replace `<single_file>` with the actual file name.

3. Follow the prompts to authenticate, select a region, and configure resource groups and storage accounts.

4. Choose whether to create new resource groups, storage accounts, and containers or use existing ones.

5. The script will guide you through the file upload, handling overwriting, skipping, renaming, and generating shareable links.

## Functions

- **Authentication**: Installs Azure CLI and logs in using device code authentication.

- **Region Selection**: Asks the user to select a region from the recommended list.

- **Resource Group Handling**: Checks for existing resource groups, creates a new one, and lists resource groups.

- **Storage Account Handling**: Creates or uses a storage account and lists storage accounts.

- **Container Handling**: Creates or uses a container and lists containers.

- **File Handling**: Checks for file existence, handles overwriting, skipping, renaming, and generates shareable links.

## Troubleshooting

- If you encounter issues while using the Azure File Upload Script, follow these steps to troubleshoot and resolve common problems:

1. Check Error Messages:

- Review any error messages displayed during script execution. These messages often provide valuable information about the nature of the issue.

2. Review Log Files:

- If logging is enabled (consider adding a logging feature to your script), review log files for details on each step performed by the script. This can help identify where an error occurred.

3. Verify Azure CLI Installation:

- Ensure that the Azure CLI is correctly installed on your machine and that you have the necessary permissions to run it. Check the version compatibility with the script requirements.
 ```bash az --version```

4. Check Azure Account Permissions:

- Confirm that your Azure account has the required permissions to create and manage resources. If in doubt, refer to the Azure documentation on role-based access control (RBAC).

5. Inspect Azure Resource Status:

- Manually check the status of the resource groups, storage accounts, and containers created or used by the script. You can use the Azure Portal or the Azure CLI for this.
```bash
az group list
az storage account list
az storage container list --account-name <your-storage-account>
```

6. Verify File Existence:

- If you are experiencing issues with file uploads, double-check that the specified files exist in the given paths. Ensure you have read permissions for those files.

7. Update the Script:

- Ensure you are using the latest version of the script. Check for updates in the script repository and update your local copy if needed.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgments

- The script utilizes the Azure CLI for Azure interactions.
