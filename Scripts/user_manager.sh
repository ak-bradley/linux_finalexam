#!/bin/bash

# sort actual human user from system users and cretae an array
# cut private user groups from shared groups 

humanusers() { awk -F: '($3>=1000) && ($3!=65534) {print $1}' /etc/passwd; }
humangroups() { awk -F: '($3 >= 1000) && ($3 != 65534) {print $1}' /etc/group | grep -v -Ff <(humanusers); }

# create a loop  for the entire menu

while true; do

echo "Welcome to user management system. Choose from between the following options"
echo ""
echo "1. Create a user"
echo "2. Delete a user"
echo "3. List all users"
echo "4. Add user to user group"
echo "5. Exit"
read -rp "Choose an option: " option

# create another loop for user creation

case "$option" in
1) while true; do
   read -rp "Enter new username or press Enter to cancel " name

# if  action cancelled
     if [[ -z "$name" ]]; then 
     echo "Action cancelled"
     break 
     fi

# if user  exists
     if id "$name" &>/dev/null; then
     echo "User $name already exists. Choose a different username" 
   else 
     sudo  adduser "$name"   # create the user if non-existent
     echo "$name created successfully"
     break
   fi
done ;;

# select a user to delete from the pool of all human users
2) echo "Select a user to delete or press any key to cancel"
   select user in $(humanusers); do

# if user exists ask for confirmation and delete if confirmed
   if [[ -n "$user" ]]; then
      read -rp "Are you sure you want to delete $user? y/n " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
         sudo deluser --remove-home "$user"
         echo "$user deleted"
         break

#  cancel deletion
   elif [[ "$confirm" =~ ^[Nn]$ ]]; then 
      echo "No action taken"
      break
   else
     echo  "Invalid action"
     fi

#  random error message or cancellation and return to menu
else 
     echo "Action cancelled or invalid selection. Returning to main menu"
     break
fi
done;;

# list all  human users
3) echo "Users: "
   echo "$(humanusers)";;

# chose a user to add to a group
4) echo  "Select a user to add to group or press any key to cancel " 
   select user in $(humanusers); do
   if [[ -n "$user"  ]]; then

# further select the group from the pool o fshared groups
    echo "Select the group you'd like to add $user to: "
   select  group in $(humangroups); do
    if [[ -n "$group" ]]; then

# add user to selected group
    sudo  usermod -aG "$group" "$user"
    echo "$user added to $group"
    break 2
   else echo "No group selected"
   break 2
  fi 
  done

# print error or cancellation message and return to menu
else echo "Invalid user selection or invalid choice. Returning to main menu"
break
fi
done;;

# exit process
5) 
break ;;

# random error
*) echo "Invalid option";;
esac
done
