#!/bin/bash

# Helper function to check if a database exists and is not empty
check_database_exists() {
    if [[ ! -f "$1.txt" ]]; then
        echo "Error: Database '$1' does not exist."
        exit 1
    elif [[ ! -s "$1.txt" ]]; then
        echo "Error: Database '$1' is empty or corrupted."
        exit 1
    fi
}

# Helper function to check if a table exists in the database
check_table_exists() {
    db_name="$1.txt"
    table_name="$2"
    if ! grep -q "TABLE $table_name" "$db_name"; then
        echo "Error: Table '$table_name' does not exist in '$1'."
        exit 1
    fi
}

# Create Database function
create_db() {
    if [[ -z "$1" ]]; then
        echo "Error: Missing database name."
        echo "Usage: $0 create_db <database_name>"
        exit 1
    fi

    db_name="$1.txt"
    if [[ -f "$db_name" ]]; then
        echo "Error: Database '$1' already exists."
        exit 1
    else
        touch "$db_name"
        echo "***************************************" > "$db_name"
        echo "$1" >> "$db_name"
        echo "***************************************" >> "$db_name"
        echo "Database '$1' created successfully."
    fi
}

# Create Table function
create_table() {
    if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
        echo "Error: Missing arguments for creating table."
        echo "Usage: $0 create_table <database_name> <table_name> <fields...>"
        exit 1
    fi

    db_name="$1.txt"
    table_name="$2"

    check_database_exists "$1"
    fields=("${@:3}")

    for field in "${fields[@]}"; do
        if [[ -z "$field" ]]; then
            echo "Error: Field names cannot be empty."
            exit 1
        fi
    done

    if grep -q "TABLE $table_name" "$db_name"; then
        echo "Error: Table '$table_name' already exists in '$1'."
        exit 1
    fi

    echo "TABLE $table_name" >> "$db_name"
    echo "** $(printf '%-8s' "${fields[@]}") **" >> "$db_name"
    echo "Table '$table_name' created with fields: ${fields[*]}"
}

# Insert Data function with data length check and duplicate prevention
insert_data() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Error: Missing arguments for inserting data."
        echo "Usage: $0 insert_data <database_name> <table_name> <data...>"
        exit 1
    fi

    db_name="$1.txt"
    table_name="$2"

    check_database_exists "$1"
    check_table_exists "$1" "$table_name"
    shift 2
    data=("$@")

    for value in "${data[@]}"; do
        if [[ -z "$value" ]]; then
            echo "Error: Data values cannot be empty."
            exit 1
        elif [[ ${#value} -gt 8 ]]; then
            echo "Error: Data value '$value' exceeds 8 characters."
            exit 1
        fi
    done

    id_value="${data[0]}"
    if grep -q " $id_value " "$db_name"; then
        echo "Error: Duplicate entry for ID '$id_value'."
        exit 1
    fi

    echo "** $(printf '%-8s' "${data[@]}") **" >> "$db_name"
    echo "Data inserted into table '$table_name'."
}

# Select Data function
select_data() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Error: Missing arguments for selecting data."
        echo "Usage: $0 select_data <database_name> <table_name>"
        exit 1
    fi

    db_name="$1.txt"
    table_name="$2"

    check_database_exists "$1"
    check_table_exists "$1" "$2"

    echo "Displaying data from table '$table_name':"
    awk "/TABLE $table_name/{flag=1; next} /TABLE/{flag=0} flag" "$db_name"
}

# Updated Delete Data function with validation
delete_data() {
    if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
        echo "Error: Missing arguments for deleting data."
        echo "Usage: $0 delete_data <database_name> <table_name> <condition>"
        exit 1
    fi

    db_name="$1.txt"
    table_name="$2"
    condition="$3"

    check_database_exists "$1"
    check_table_exists "$1" "$table_name"

    # Validate that the condition is in the correct format "field=value"
    if ! [[ "$condition" =~ ^[a-zA-Z0-9_]+=[a-zA-Z0-9_]+$ ]]; then
        echo "Error: Condition must be in the format 'field=value'."
        exit 1
    fi

    # Extract the field and value from the condition
    field=$(echo "$condition" | cut -d'=' -f1)
    value=$(echo "$condition" | cut -d'=' -f2)

    # Find the index of the field (e.g., "id") in the table header
    field_index=$(awk -v table="$table_name" -v field="$field" '
    BEGIN { found_table=0; field_index=-1 }
    /TABLE/ { if ($2 == table) { found_table=1; next } }
    found_table && /TABLE/ { exit }
    found_table { 
        for (i=2; i<=NF; i++) {
            if ($i == field) {
                field_index=i;
                exit
            }
        }
    }
    END { print field_index }
    ' "$db_name")

    if [[ "$field_index" -eq -1 ]]; then
        echo "Error: Field '$field' not found in table '$table_name'."
        exit 1
    fi

    # Delete rows where the value in the field column matches
    awk -v table="$table_name" -v field_index="$field_index" -v value="$value" '
    BEGIN { inside_table=0 }
    /TABLE/ { inside_table=($2 == table) }
    inside_table && ($field_index == value) { next }
    { print }
    ' "$db_name" > tmpfile && mv tmpfile "$db_name"

    echo "Deleted data where $condition from table '$table_name'."
}

# Main function to handle commands and provide usage information
case "$1" in
    create_db)
        create_db "$2"
        ;;
    create_table)
        create_table "$2" "$3" "${@:4}"
        ;;
    insert_data)
        insert_data "$2" "$3" "${@:4}"
        ;;
    select_data)
        select_data "$2" "$3"
        ;;
    delete_data)
        delete_data "$2" "$3" "$4"
        ;;
    *)
        echo "Error: Invalid command '$1'."
        echo "Usage: $0 {create_db <database_name>} {create_table <database_name> <table_name> <fields...>} {insert_data <database_name> <table_name> <data...>} {select_data <database_name> <table_name>} {delete_data <database_name> <table_name> <condition>}"
        exit 1
        ;;
esac

