#!/bin/bash

# Configuration
DB_NAME="wordpress_db"
DB_USER="wordpress_user"
DB_PASS="secure_password"
BACKUP_DIR="/path/to/backup"
RETENTION_DAYS=7

# Timestamp
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Create Backup Directory
mkdir -p "$BACKUP_DIR"

# Backup Database
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_DIR/db_backup_$TIMESTAMP.sql"

# Compress Backup
gzip "$BACKUP_DIR/db_backup_$TIMESTAMP.sql"

# Remove Old Backups
find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -exec rm {} \;

# Log
echo "Backup completed at $TIMESTAMP" >> "$BACKUP_DIR/backup.log"
