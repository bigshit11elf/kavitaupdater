#!/bin/bash

service_name="kavita"
folder_to_kavita="/opt/Kavita"

# Function to display a confirmation prompt
confirm_action() {
    read -p "Do you want to perform this action? (yes/no): " answer
    case "$answer" in
        [Yy]*)
            return 0  # User agrees
            ;;
        [Nn]*)
            return 1  # User disagrees
            ;;
        *)
            echo "Please enter 'yes' or 'no'."
            confirm_action  # Recursively ask for confirmation until valid input
            ;;
    esac
}

clear
# Intro Graphics
echo "    __ __            _ __                       "
echo "   / //_/___ __   __(_) /_____ _                "
echo "  / ,< / __ \`/ | / / / __/ __ \`/                "
echo " / /| / /_/ /| |/ / / /_/ /_/ /                 "
echo "/_/ |_\\__,_/ |___/_/\\__/\\__,_/                  "
echo "           __  __          __      __           "
echo "          / / / /___  ____/ /___ _/ /____  _____"
echo "         / / / / __ \\/ __  / __ \`/ __/ _ \\/ ___/"
echo "        / /_/ / /_/ / /_/ / /_/ / /_/  __/ /    "
echo "        \\____/ .___/\\__,_/\\__,_/\\__/\\___/_/     "
echo "            /_/                                 "
echo ""
echo ""
echo "Kavita updater script v0.2"
echo "written by BarnacleB0y"
echo ""
echo "Kavita updater script © 2023 by BarnacleB0y is licensed under CC BY-SA 4.0. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/"
echo ""
echo ""
echo "++ Usage note: You can also provide a release version to update to via CLI."
echo "++ Example: $0 v0.7.10.2"
echo ""
echo ""
echo ""
echo ""
	  
# Check if a release version parameter is provided
if [ $# -ne 0 ]; then
  chosen_release=$1
else

	echo "The script will provide you with a list of Kavita release versions from Github now." 

	if confirm_action; then
	  clear      
	else
	  echo "You did not want to proceed... Exiting."
	  exit 0
	fi


	# Set Kavita GitHub repository and user/organization
	USER_ORG="Kareadita"
	REPO="Kavita"

	# Check if 'jq' is installed
	if ! command -v jq &>/dev/null; then
		echo " "
		echo "Error: 'jq' is not installed."
		echo "Please install 'jq' to run this script."
		echo " "
		echo "You can instal it via: apt install -y jq"
		echo "Exiting..."
		exit 1
	fi

	# Check if 'curl' is installed
	if ! command -v curl &>/dev/null; then
		echo " "
		echo "Error: 'curl' is not installed."
		echo "Please install 'curl' to run this script."
		echo " "
		echo "You can instal it via: apt install -y curl"
		echo "Exiting..."
		exit 1
	fi

	# Initialize variables
	page=1
	all_releases=""

	echo "Retrieving Kavita release information from Github..."
	echo "Waiting..."
	echo ""
	echo ""
	while true; do
		# Make an API request to get releases for the current page
		response=$(curl -s "https://api.github.com/repos/$USER_ORG/$REPO/releases?page=$page")

		# Check if the request was successful
		if [ $? -ne 0 ]; then
			echo "Failed to retrieve Kavita release information. This should not be happening ..."
			exit 1
		fi

		# Extract release information for the current page
		releases=$(echo "$response" | jq -r '.[] | "\(.name)"')

		# Append the releases to the list of all releases
		all_releases="${all_releases}${releases}"

		# Check if there are more pages of releases
		if [ -z "$releases" ]; then
			break
		fi

		# Increment the page number for the next request
		((page++))
	done

	# Complete the list and put it into $releases
	releases=$all_releases

	# Number the lines and get user input
	numbered_string=$(echo -e "$releases" | nl)
	echo -e "$numbered_string"

	# Prompt the user to choose a release
	echo ""
	echo "Choose the release version you want to update to. They are sorted from the most recent to the oldest version."
	echo ""
	echo "e.g. type [1] and press [ENTER]"
	echo ""
	echo ""
	read -p "Your choice: " choice

	# Extract the selected line
	selected_line=$(echo "$numbered_string" | grep "^ *$choice[[:space:]]")
	if [ -z "$selected_line" ]; then
	  echo "Invalid release choice. Please restart and enter a valid release number."
	  exit 1
	else
	  line_text=$(echo "$selected_line" | sed 's/^[0-9]*[[:space:]]*//')
	  release_string=$(echo "$releases" | head -n $choice | tail -n 1)
	  echo "You have Selected release: "
	  
	  # result_string="${line_text:8}"
	  result_string=$(echo "$release_string" | sed 's/^[^0-9]*//')
	  result_string=$(echo "$result_string" | cut -d' ' -f1)
	  result_string="v$result_string"
	  chosen_release=$result_string
	  
	  echo "$choice: $chosen_release"
	  echo ""
	  echo ""
	  echo "The script will continue to the update process with the information you provided." 

	  if confirm_action; then
		  clear      
	  else
		  echo "You did not want to proceed... Exiting."
		  exit 0
	  fi

	fi
fi

# Options for different release types
options=("kavita-linux-x64.tar.gz" "kavita-linux-arm64.tar.gz" "kavita-linux-arm.tar.gz" "kavita-linux-musl-x64.tar.gz" "kavita-osx-x64.tar.gz")

# Prompt the user to choose one of the options
echo "Choose a release type:"
select choice in "${options[@]}"; do
    if [[ " ${options[*]} " == *" $choice "* ]]; then
        break
    else
        echo "Invalid choice. Please select a valid release type."
    fi
done

# Extract the provided release version from the command line arguments
filename="$choice"

# Construct the full URL using the provided filename
file_url="https://github.com/Kareadita/Kavita/releases/download/$chosen_release/$filename"

# Check if the file exists on the server
if wget --spider "$file_url" 2>/dev/null; then
    # File exists, so download it
    echo "Release $chosen_release successfully located... attempting download."
    wget "$file_url"

    if [ ! -e "$filename" ]; then
        echo "File could not be downloaded. This should not be happening ..."
        exit 1
    else
        echo "Release $chosen_release downloaded successfully."
    fi

else
    # File does not exist
    echo "Release $chosen_release - specifically file $filename - was not found on the server."
    exit 1
fi

echo "Proceeding to update the release currently installed ..."
if confirm_action; then
    # User agrees to proceed with update
    echo "Beginning update."



############## SCRIPT THAT UPDATES - BEGIN
clear

if systemctl is-active --quiet "$service_name"; then
    echo "Kavita service found. Stopping it ..."
    systemctl stop kavita.service
    if systemctl is-active --quiet "$service_name"; then
        echo "Kavita service could not be stopped. This should not be happening ..."
        exit 1
    else
        echo "Kavita service stopped."
    fi
else
    echo "Kavita does not seem to be running as a service."
fi


if [ -d "$folder_to_kavita/../Kavita_new" ]; then
    echo "Kavita temporary folder already exists. This should not be happening ..."
    exit 1
else
    echo "Creating Kavita temporary folder..."
    mkdir $folder_to_kavita/../Kavita_new
    if [ -d "$folder_to_kavita/../Kavita_new" ]; then
        echo "Kavita temporary folder successfully created."
    else
        echo "Could not create Kavita temporary folder."
        exit 1
    fi
fi

echo "Extracting the new Kavita release..."
tar -xzf kavita-linux-x64.tar.gz -C $folder_to_kavita/../Kavita_new --no-same-owner
anzahl_dateien=$(find "$folder_to_kavita/../Kavita_new/Kavita" -maxdepth 1 -type f | wc -l)
if [ "$anzahl_dateien" -eq 0 ]; then
    echo "Extraction failed. This should not be happening ..."
    exit 1
else
    echo "Extraction successful."
fi

echo "Removing config folder from new release..."
rm -r $folder_to_kavita/../Kavita_new/Kavita/config

if [ -d "$folder_to_kavita/../Kavita_new/Kavita/config" ]; then
    echo "Could not remove config folder. This should not be happening."
    exit 1
else
    echo "Config folder successfully removed."
fi

echo "Copying new release to install folder ..."
cp -rf $folder_to_kavita/../Kavita_new/Kavita/. $folder_to_kavita/
echo "Completed."

echo "This script can remove the downloaded file."
if confirm_action; then
    # User wishes cleanup
    echo "Removing $filename..."
    if [ ! -e "$filename" ]; then
        echo "File does not exist. This should not be happening while the script is running..."
        exit 1
    else
        rm $filename
    fi
    if [ ! -e "$filename" ]; then
        echo "File successfully removed."
    else
        echo "File could not be deleted."
        exit 1
    fi
    
else
    # No cleanup
    echo "The file $filename ist left untouched in the target folder."
fi

echo "Removing Kavita temporary folder..."
rm -r $folder_to_kavita/../Kavita_new
if [ -d "$folder_to_kavita/../Kavita_new" ]; then
    echo "Could not remove temporary folder. This should not be happening ..."
    exit 1
else
    echo "Folder successfully removed."
fi

if systemctl list-units --full --all | grep -q " $service_name.service "; then
    echo "Starting Kavita service..."
    systemctl start $service_name

    if systemctl is-active --quiet "$service_name"; then
        echo "Kavita service running."
    else
        echo "It seems the Kavita service could not be loaded. You should check for errors..."
    fi
else
    echo "No Kavita service found. Not attempting to start it."
fi


echo " "
echo " "
echo " "
echo "Done. The update should be successful."
############## SCRIPT THAT UPDATES - END



else
    # User disagrees. Update cancelled
    echo "Exiting without writing changes to the currently installed release."
    echo
    echo "This script can remove the downloaded file."
    if confirm_action; then
        # User wishes cleanup
        echo "Removing $filename..."
        if [ ! -e "$filename" ]; then
            echo "File does not exist. This should not be happening while the script is running..."
            exit 1
        else
            rm $filename
        fi
        if [ ! -e "$filename" ]; then
            echo "File successfully removed."
        else
            echo "File could not be deleted."
            exit 1
        fi
        
    else
        # No cleanup
        echo "The file $filename ist left untouched in the target folder."
    fi

    echo "Exiting the script."
    exit 0
fi

