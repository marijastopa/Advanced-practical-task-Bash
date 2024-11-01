# Database Service in Bash

This repository contains database.sh, a Bash script that implements a lightweight database service. The script provides basic database functionalities, including creating databases and tables, inserting data, retrieving data, and deleting data based on conditions. It also includes comprehensive error handling to ensure reliable and clear feedback for incorrect usage.

## Features
- **Database Creation:** Creates a new database file with a specified name.
- **Table Creation:** Creates tables within a database with field length validation.
- **Data Insertion:** Inserts rows into a table with checks for field length and duplicate IDs.
- **Data Retrieval:** Selects and displays data from a specified table.
- **Data Deletion:** Deletes rows from a table based on specified conditions.
- **Error Handling:** Provides meaningful error messages for incorrect inputs, ensuring smooth user experience.
  
## Usage
Each function is triggered by a command-line argument. Below is a detailed list of commands supported by database.sh.

### 1. Create a Database
Creates a new database file with the specified name.

```./database.sh create_db <database_name>```

Example:

```./database.sh create_db test_db```

Error Handling:
- If no database name is provided, an error message is shown.
- If the database already exists, an error message is shown.

  
### 2. Create a Table
Creates a table within an existing database. Field names are limited to 8 characters each.

```./database.sh create_table <database_name> <table_name> <fields...>```

Example:

```./database.sh create_table test_db persons id name height age```

Error Handling:
- If the database does not exist, an error message is shown.
- If the table already exists, an error message is shown.
- If any field name exceeds 8 characters or is empty, an error message is shown.

### 3. Insert Data
Inserts a row of data into a specified table within an existing database. Each data value is limited to 8 characters, and duplicate IDs are not allowed.

```./database.sh insert_data <database_name> <table_name> <data...>```

Example:

```./database.sh insert_data test_db persons 1 John 180 25```

Error Handling:
- If the database or table does not exist, an error message is shown.
- If any data value exceeds 8 characters or is empty, an error message is shown.
- If the ID (first value in the data) is a duplicate, an error message is shown.
  
### 4. Select Data
Displays all data from a specified table in a database.

```./database.sh select_data <database_name> <table_name>```

Example:

```./database.sh select_data test_db persons```

Error Handling:
- If the database or table does not exist, an error message is shown.

### 5. Delete Data
Deletes rows from a table based on a specified condition in the format field=value.

```./database.sh delete_data <database_name> <table_name> <condition>```

Example:

```./database.sh delete_data test_db persons "id=1"```

Error Handling:
- If the database or table does not exist, an error message is shown.
- If the condition format is incorrect (e.g., missing =), an error message is shown.
- If the specified field does not exist in the table, an error message is shown.

## Error Handling Summary
The script includes robust error handling for each function to ensure user-friendly feedback. Below are some common error checks:

### Database Errors:
- Missing database name during creation.
- Attempting to create an existing database.
- Attempting operations on a non-existent or empty database.
  
### Table Errors:
- Missing arguments during table creation.
- Attempting to create a table that already exists.
- Attempting operations on a non-existent table.

### Field and Data Errors:
- Field names and data values must be 8 characters or fewer.
- Empty field names or data values are not allowed.
- Duplicate ID entries are not allowed during data insertion.

### Condition Format Errors:
- Conditions for data deletion must be in field=value format.
- Conditions must reference a valid field in the table.

## Examples
### Creating a Database and Table
```./database.sh create_db employees_db```

```./database.sh create_table employees_db employees id name position salary```

### Inserting and Selecting Data
```./database.sh insert_data employees_db employees 1 Alice Manager 70000```

```./database.sh insert_data employees_db employees 2 Bob Developer 60000```

```./database.sh select_data employees_db employees```

### Deleting Data
```./database.sh delete_data employees_db employees "id=2"```

```./database.sh select_data employees_db employees```

## Script Structure
```create_db```: Function to create a new database.

```create_table```: Function to create a new table within an existing database.

```insert_data```: Function to insert data into an existing table.

```select_data```: Function to select and display data from a table.

```delete_data```: Function to delete data from a table based on a condition.

```check_database_exists``` and ```check_table_exists```: Helper functions for validating database and table existence.

## Notes
- The script creates database files with a ```.txt``` extension.
- Each row in the table must conform to the formatting requirements (two stars at the beginning and end).
- Only valid commands will be executed; any other input will display usage instructions.


