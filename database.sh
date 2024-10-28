#!/bin/bash

# Create Database function (already implemented)
create_db() {
    db_name="$1.txt"
    if [[ -z "$1" ]]; then
        echo "Error: Database name required."
        exit 1
    fi

    if [[ -f "$db_name" ]]; then
        echo "Error: Database $1 already exists."
    else
        touch "$db_name"
        echo "***************************************" > "$db_name"
        echo "$1" >> "$db_name"
        echo "***************************************" >> "$db_name"
        echo "Database $1 created successfully."
    fi
}

# Create Table function
create_table() {
    db_name="$1.txt"
    table_name="$2"
    shift 2
    fields=("$@")

    # Check if database exists
    if [[ ! -f "$db_name" ]]; then
        echo "Error: Database $1 does not exist."
        exit 1
    fi

    # Ensure table doesn't already exist
    if grep -q "TABLE $table_name" "$db_name"; then
        echo "Error: Table $table_name already exists in $1."
        exit 1
    fi

    # Create the table with the specified fields
    echo "TABLE $table_name" >> "$db_name"
    echo "** $(printf '%-8s' "${fields[@]}") **" >> "$db_name"
    echo "Table $table_name created successfully with fields: ${fields[*]}"
}

# Main function to handle commands
case "$1" in
    create_db)
        create_db "$2"
        ;;
    create_table)
        create_table "$2" "$3" "${@:4}"
        ;;
    *)
        echo "Usage: $0 {create_db <database_name>} {create_table <database_name> <table_name> <fields...>}"
        ;;
esac

