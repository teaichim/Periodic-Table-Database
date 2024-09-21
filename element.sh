#!/bin/bash

# Command to access the periodic_table database
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Ensure an argument was provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Function to display element details
output_element_info() {
  IFS='|' read ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS TYPE <<< $($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER;")
  
  if [[ -n "$TYPE" ]]; then
    IFS='|' read ELEMENT_TYPE <<< $($PSQL "SELECT type FROM types WHERE type_id=$TYPE;")
  fi

  if [[ -n "$ATOMIC_MASS" && -n "$MELTING_POINT_CELSIUS" && -n "$BOILING_POINT_CELSIUS" && -n "$ELEMENT_TYPE" ]]; then
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $ELEMENT_TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  else
    echo "I could not find that element in the database."
  fi
}

# Handle numeric atomic number input
if [[ "$1" =~ ^[0-9]+$ ]]; then
  ATOMIC_NUMBER=$1
  IFS='|' read SYMBOL NAME <<< $($PSQL "SELECT symbol, name FROM elements WHERE atomic_number=$ATOMIC_NUMBER;")

# Handle atomic symbol input (1 or 2 letters)
elif [[ "$1" =~ ^[a-zA-Z]{1,2}$ ]]; then
  SYMBOL=$1
  IFS='|' read ATOMIC_NUMBER NAME <<< $($PSQL "SELECT atomic_number, name FROM elements WHERE symbol='$SYMBOL';")

# Handle full element name input
elif [[ "$1" =~ ^[a-zA-Z]+$ ]]; then
  NAME=$1
  IFS='|' read ATOMIC_NUMBER SYMBOL <<< $($PSQL "SELECT atomic_number, symbol FROM elements WHERE name='$NAME';")

# Invalid input case
else
  echo "I could not find that element in the database."
  exit 0
fi

# If atomic number is found, display element info
if [[ -n "$ATOMIC_NUMBER" ]]; then
  output_element_info
else
  echo "I could not find that element in the database."
fi
