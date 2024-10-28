#!/bin/bash

# Create Database function
create_db() {
    db_name="$1.txt"
    
    # Check if database name is provided
    if [[ -z "$1" ]]; then
        echo "Error: Database name required."
        exit 1
    fi

    # Check if database already exists
    if [[ -f "$db_name" ]]; then
        echo "Error: Database $1 already exists."
    else
        # Create the database file with required structure
        touch "$db_name"
        echo "***************************************" > "$db_name"
        echo "$1" >> "$db_name"
        echo "***************************************" >> "$db_name"
        echo "Database $1 created successfully."
    fi
}

# Main function to handle commands
case "$1" in
    create_db)
        create_db "$2"
        ;;
    *)
        echo "Usage: $0 {create_db <database_name>}"
        ;;
esac

