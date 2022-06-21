#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

COMPARE(){

 # 2 will be the STDIN and 1 will be the secret

  if [ $1 -gt $2 ]
  then
    echo -e "\nIt's higher than that, guess again:" 
  else
    echo -e "\nIt's lower than that, guess again:" 
  fi

}

UPDATE_DB(){
# GAME_PLAYED OLD $2
GP=$(($2+1))
LG=$4
# if lowest guess / best score is 0 tie not played 
if [[ $3 -ne 0 ]]
then
  if [[ $4 -ge $3 ]]
  then
    LG=$3
  fi
fi

($PSQL "update user_info set  game_played = $GP ,lowest_guess = $LG where username = '$USERNAME';") >> /dev/null 
}

GUESS_GAME(){

# TBG
SECRET=$((1 + $RANDOM % 1000))

echo -e "THE SECRET TESTING: $SECRET"

echo -e "\nGuess the secret number between 1 and 1000:"

TRY=1
###############################
read VAL

####################
while [[ ! $VAL =~ ^[0-9]+$ ]]
do
 echo -e "\nThat is not an integer, guess again:"
 read VAL
done
####################
if [[ $SECRET -ne $VAL ]]
then

    COMPARE $SECRET $VAL
    ###############################
    while [ $VAL -ne $SECRET ]
    do
    ((TRY=TRY+1))
    ###############################
    read VAL

    ####################
    while [[ ! $VAL =~ ^[0-9]+$ ]]
    do
    echo -e "\nThat is not an integer, guess again:"
    read VAL
    done
    ####################

    COMPARE $SECRET $VAL
    ###############################
    done
fi
UPDATE_DB $1 $2 $3 $TRY
echo -e "You guessed it in $TRY tries. The secret number was $SECRET. Nice job!"
}



MAIN(){

echo -e "\nEnter your username:"

# ask for username 
read USERNAME 

# get data for this particular username
USER_NAME=$($PSQL "select username from user_info where username='$USERNAME'")
GAME_PLAYED=$($PSQL "select game_played from user_info where username='$USERNAME'")
LOWEST_GUESS=$($PSQL "select lowest_guess from user_info where username='$USERNAME'")

#if users data is null then
if [[ -z $USER_NAME ]]
then

  ($PSQL "insert into user_info values('$USERNAME');") >> /dev/null
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  GUESS_GAME $USERNAME 0 0

else

  echo -e "\nWelcome back, $USER_NAME! You have played $GAME_PLAYED games, and your best game took $LOWEST_GUESS guesses."    
  GUESS_GAME $USER_NAME $GAME_PLAYED $LOWEST_GUESS

fi

}


MAIN
