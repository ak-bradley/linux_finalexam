#!/bin/bash

# create a backup of the /srv/shared folder with current date in the filename 
bkupdate=$(date +%d-%m-%y_%H-%M)
bkupdir=~/srv/backups
mkdir -p "$bkupdir"

# save locally
bkupfile="$bkupdir"/backup_"$bkupdate".tar.gz 
tar -czf "$bkupfile"  ~/srv/shared

# save remotely
rclone copy "$bkupfile" gdrive:server_backups/

# append action to the file 
echo "$bkupdate Backup created: $bkupfile" >>  "$bkupdir"/backuplog.txt

# delete  backups over 7 days old locally and log
find "$bkupdir"  -name  "backup_*.tar.gz" -type f -mtime +7 -exec sh -c '
for f in "$@"; do
rm "$f"
echo "Old backup ($f) deleted on $1" >> "$2/backuplog.txt"
done
' sh "$bkupdate" "$bkupdir" {} +

# delete backups remotely and log
rclone delete gdrive:server_backups --min-age 7d --verbose --log-file "$bkupdir/backuplog.txt"
