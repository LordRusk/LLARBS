#!/bin/bash


### FUNCTIONS ###

error() { printf "Something went wrong, maybe it was the script, maybe it was you, who knows"; exit;}

prescript() { \
	PS3='LPI needs install; dialog for menus and vim for text editing, before the rest of the script can run. Would you like to install dialog and vim, or quit LPI?: '
	options=("Install Dialog and vim" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"Install Dialog and vim")
				pacman -Sy --noconfirm dialog vim
				break
			;;
			"Quit")
				echo "User Exited."
				exit
				break
			;;
			*) echo "invalid option $REPLY";;
		esac
	done
}

welcomemsg() { \
	dialog --title "Welcome" --msgbox "Welcome to LPI! (Lazy Pre Install)\\n\\nThis script is a tool to help you get Arch installed. (LPI will also ask if you would like to use LARBS (Luke's Automatic Bootstrapping Scripts) as a graphical interface, or let you install and configure your own!" 10 60
	}

partitiondrive() { \
	dialog --title "Partitioning and formating" --yesno "First we need to partition the drive, but first we have to choose the drive and wipe it, it will usually be /dev/sda, but it is still good to check. All the current connected drives will be listed, identify which one you want to install Arch and type out the name. DISCLAIMER: WHATEVER DRIVE YOU CHOISE WILL BE WIPED, ARE YOU SURE YOU WANT TO CONTINUE?" 10 60

	PS3='Choose a drive: '
	options=("/dev/sda/" "/dev/sdb/" "/dev/sdc/" "/dev/sdd/" "/dev/sd0")
	select opt in "${options[@]}"
	do
		case $opt in
			"/dev/sda/")
				drive="/dev/sda"
				break
			;;
			"/deb/sdb/")
				drive="/dev/sdb"
				break
			;;
			"/dev/sdc/")
				drive="/dev/sdc"
				break
			;;
			"/dev/sdd/")
				drive="/dev/sdd"
				break
			;;
			"/dev/sd0/")
				drive="/dev/sd0/"
				break
			;;
			"Exit")
				echo "User Exited."
				exit
				break
			;;
			*) echo "invalid option $REPLY";;
		esac
	done

	dialog --title "DISCLAIMER" --msgbox "If you are reinstalling using LPI on a partition scheme similar to the one LPI makes, it may ask you if you want to continue with the formatting. If it does ask you, just accept and continue." 17 40

	rps=$(dialog --inputbox "How big big do you want your root partition with extension? (i.E 30gb) The lowest you want to go is 5gb for a VERY small harddrive. Anything with over 250gb you should make it 30gb." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
	hps=$(dialog --inputbox "If you want your home partition to be something other than the rest of the drive (maybe you are duel booting) put it bewlow, if not, leave it blank." 10 60 3>&1 1>&2 2>&3 3>&1)

	echo -e "g\nn\np\n1\n\n+500mb\nn\np\n2\n\n+"$rps"\nn\np\n3\n\n"$hps"\nw" | fdisk /dev/"$drive"

	mkfs.fat -F32 /dev/sda1
	mkfs.ext4 /dev/sda2
	mkfs.ext4 /dev/sda3

	mount /dev/sda2 /mnt
	mkdir /mnt/home
	mount /dev/sda3 /mnt/home

	echo "done"
}

mirrorlist() {
	mle=$(dialog --inputbox "First, please enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1)
	if [[ "$mle" == "Yes" ]]; then
		echo "it work"
	elif [[ "$mle" == "yes" ]]; then
		echo "it work lowcase"
	fi
	echo $yay
}

installbase() {
	sudo pacman -S base git dialog
}

### THE ACTUAL SCRIPT ###

### This is how everything happens in an intuitive format and order.

# Install dialog, at the same time making sure everything else is good for the install
prescript || error "User Exited."

# Welcome user
welcomemsg || error "User Exited."

# Get sizes for drives, make the partitions, and format the partitions
partitiondrive || error "User Exited."

# Ask to edit mirror list
mirrorlist || error "User Exited."
