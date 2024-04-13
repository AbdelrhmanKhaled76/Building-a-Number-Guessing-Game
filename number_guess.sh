#!/bin/bash
min() {
    if (( $1 < $2 )); then
        echo $1
    else
        echo $2
    fi
}

echo "Enter your username:"
read NAME

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$((RANDOM % (1000 - 1 + 1) + 1))
echo "$NUMBER"
BEST_NUM=0
GAMES_NUM=0
USERNAME=$($PSQL "select username from users where username='$NAME';")
if [[ -z $USERNAME ]]
then 
  INSERT_USERNAME=$($PSQL "insert into users(username,games_played) values('$NAME',1);")
  echo "Welcome, $NAME! It looks like this is your first time here."
else
 OLDUSER=$($PSQL "select * from users where username='$NAME';")
while IFS='|' read -r OLD_USERNAME GAMES_PLAYED BEST_GAME; do
  echo "Welcome back, $OLD_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  ((BEST_NUM+=BEST_GAME))
  ((GAMES_NUM+=GAMES_PLAYED+1))
  UPDATING_GAMES_NUM=$($PSQL "update users set games_played="$GAMES_NUM" where username='$NAME';")
done <<< "$OLDUSER"
fi
 
echo "Guess the secret number between 1 and 1000:"
read GUESS
GUESS_NUM=1
integer_pattern='^[0-9]+$'
while ! [[ $GUESS =~ $integer_pattern ]]; do
  echo "That is not an integer, guess again:"
  read GUESS
done

while [ "$GUESS" -ne "$NUMBER" ]; do 
  if [[ $GUESS -gt $NUMBER ]]; then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $NUMBER ]]; then 
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  ((GUESS_NUM++))
done
if [[ $BEST_NUM -eq 0 ]]
then 
  ((THE_BEST+=GUESS_NUM))
else
  THE_BEST=$(min $GUESS_NUM $BEST_NUM)
fi
UPDATING_GUESS_NUM=$($PSQL "update users set best_game="$THE_BEST" where username='$NAME';")
echo "You guessed it in $GUESS_NUM tries. The secret number was $NUMBER. Nice job!"