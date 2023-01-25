#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "~~ My Salon ~~"

MENU() {

echo "Welcome to My Salon, how can I help you?"

CHOOSING_SERVICES=$($PSQL "SELECT service_id,name FROM services")
if [[ -z $CHOOSING_SERVICES ]]
  then
  MENU "I could not find that service. What would you like today?"
  else
  echo "$CHOOSING_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
  if [[ -z $SERVICE_NAME  ]]
  then
     MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
  
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
      if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
      then
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/ //g'), $CUSTOMER_NAME?"
        read SERVICE_TIME

        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      fi  
        
      INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      if [[ $INSERT_RESULT == "INSERT 0 1" ]]
      then
        echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/ //g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ //g')."
      fi
    fi
  fi
fi

}

MENU


