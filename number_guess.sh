#!/bin/bash

#############################################
#SECRET
GUESS_IT=$((1+RANDOM%1000));
##############################################
 
#####################################
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c";

#####################################

###############################################
#       MAIN FUNCTION
#############################################
echo "Enter your username:";
read username;

USER_DATA=$($PSQL "SELECT * FROM users WHERE username='$username';");

if [[ $USER_DATA ]]
then

IFS="|"; read username games_played best_game <<< $USER_DATA

echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."

else

($PSQL "INSERT INTO users VALUES('$username')") >> /dev/null

echo "Welcome, $username! It looks like this is your first time here."

fi

################################################

################################################

################################################
#             NUMBER GUSSING GAME
################################################


echo "Guess the secret number between 1 and 1000:"
read  USER_INPUT

TRY=1 # try with 0

while [[ $USER_INPUT -ne $GUESS_IT ]]
do

    ##############################
    # ensure that input is a number
    ##############################

    while [[ ! $USER_INPUT =~ ^[0-9]+$ ]]
    do
      echo "That is not an integer, guess again:"
      read USER_INPUT
    done


    #####################################
    # Assist user with high/low guess hint
    ######################################

    if [[ $USER_INPUT -gt $GUESS_IT ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo  "It's higher than that, guess again:"
    fi

    read USER_INPUT
    ((TRY=TRY+1))

done

################################################
#       NUMBER GUSSING GAME END
################################################
echo "You guessed it in $TRY tries. The secret number was $GUESS_IT. Nice job!"

########### UPDATION QUERY ###############
X=$(psql --username=freecodecamp --dbname=number_guess -t --no-align -c "update users set no_of_games=no_of_games+1 where username='$username'")
X=$(psql --username=freecodecamp --dbname=number_guess -t --no-align -c "update users set best_gaame=$TRY where username='$username' AND (best_gaame>$TRY)")
