#!/bin/sh

# Updates etc at: https://github.com/woxxy/MySQL-backup-to-Amazon-S3
# Under a MIT license

# change these variables to what you need
S3BUCKET=my-db-backup-bucket
BACKUP_DIR=/sites
PERIOD=${1-day}

echo "Selected period: $PERIOD."

echo "Starting compression..."

tar czf ~/all-sites.tar.gz ${BACKUP_DIR}

echo "Done compressing the backup file."

# we want at least two backups, two months, two weeks, and two days
echo "Removing old backup (2 ${PERIOD}s ago)..."
s3cmd del --recursive s3://${S3BUCKET}/previous_${PERIOD}/
echo "Old backup removed."

echo "Moving the backup from past $PERIOD to another folder..."
s3cmd mv --recursive s3://${S3BUCKET}/${PERIOD}/ s3://${S3BUCKET}/previous_${PERIOD}/
echo "Past backup moved."

# upload all databases
echo "Uploading the new backup..."
s3cmd put -f ~/all-sites.tar.gz s3://${S3BUCKET}/${PERIOD}/
echo "New backup uploaded."

echo "Removing the cache files..."
# remove databases dump
rm ~/all-sites.tar.gz
echo "Files removed."
echo "All done."