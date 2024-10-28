#!/bin/bash

# Create Database function
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

    if [[ ! -f "$db_name" ]]; then
        echo "Error: Database $1 does not exist."
        exit 1
    fi

    if grep -q "TABLE $table_name" "$db_name"; then
        echo "Error: Table $table_name already exists in $1."
        exit 1
    fi

    echo "TABLE $table_name" >> "$db_name"
    echo "** $(printf '%-8s' "${fields[@]}") **" >> "$db_name"
    echo "Table $table_name created successfully with fields: ${fields[*]}"
}

# Insert Data function
insert_data() {
    db_name="$1.txt"
    table_name="$2"
    shift 2
    data=("$@")

    if [[ ! -f "$db_name" ]]; then
        echo "Error: Database $1 does not exist."
        exit 1
    fi

    if ! grep -q "TABLE $table_name" "$db_name"; then
        echo "Error: Table $table_name does not exist."
        exit 1
    fi

    echo "** $(printf '%-8s' "${data[@]}") **" >> "$db_name"
    echo "Data inserted into table $table_name."
}

# Select Data function
select_data() {
    db_name="$1.txt"
    table_name="$2"

    if [[ ! -f "$db_name" ]]; then
        echo "Error: Database $1 does not exist."
        exit 1
    fi

    if ! grep -q "TABLE $table_name" "$db_name"; then
        echo "Error: Table $table_name does not exist."
        exit 1
    fi

    echo "Displaying data from table $table_name:"
    awk "/TABLE $table_name/{flag=1; next} /TABLE/{flag=0} flag" "$db_name"
}

# Delete Data function
delete_data() {
    db_name="$1.txt"
    table_name="$2"
    condition="$3"

    if [[ ! -f "$db_name" ]]; then
        echo "Error: Database $1 does not exist."
        exit 1
    fi

    if ! grep -q "TABLE $table_name" "$db_name"; then
        echo "Error: Table $table_name does not exist."
        exit 1
    fi

    # Extract the field and value from the condition (e.g., id=1)
    field=$(echo "$condition" | cut -d'=' -f1)
    value=$(echo "$condition" | cut -d'=' -f2)

    # Delete rows matching the condition
    awk -v field="$field" -v value="$value" '
    BEGIN { FS=" " }
    /TABLE '"$table_name"'/{flag=1; next} /TABLE/{flag=0}
    flag && $2 == value { next }
    { print }
    ' "$db_name" > tmpfile && mv tmpfile "$db_name"

    echo "Deleted data where $condition from $table_name."
}

# Main function to handle commands
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
        echo "Usage: $0 {create_db <database_name>} {create_table <database_name> <table_name> <fields...>} {insert_data <database_name> <table_name> <data...>} {select_data <database_name> <table_name>} {delete_data <database_name> <table_name> <condition>}"
        ;;
esac

