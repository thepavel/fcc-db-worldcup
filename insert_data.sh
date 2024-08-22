#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "----- Clear Existing Data -----"
echo $($PSQL "TRUNCATE games")
echo $($PSQL "TRUNCATE teams")

echo "----- Seed Data -----"
skip_headers=1
games=()
cat games.csv | while IFS="," read YEAR ROUND WINNER OPP W_GOALS O_GOALS
do
  if ((skip_headers))
  then
    ((skip_headers--))
  else
    echo $YEAR $ROUND: $WINNER $W_GOALS - $O_GOALS $OPP
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '${WINNER}'")
    opp_id=$($PSQL "SELECT team_id FROM teams WHERE name = '${OPP}'")

    # create winner if they don't exist
    if [[ -z $winner_id ]]
    then
      insert_result=$($PSQL "INSERT INTO teams(name) VALUES('${WINNER}')")
      if [[ $insert_result = 'INSERT 0 1' ]]
      then 
        winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '${WINNER}'")
        echo inserted team: $WINNER
      fi
    fi

    # create opponent if they don't exist
    if [[ -z $opp_id ]]
    then
      insert_result=$($PSQL "INSERT INTO teams(name) VALUES('${OPP}')")
      if [[ $insert_result = 'INSERT 0 1' ]]
      then 
        opp_id=$($PSQL "SELECT team_id FROM teams WHERE name = '${OPP}'")
        echo inserted team: $OPP
      fi
    fi

    # insert game 
    insert_game_result=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES (${YEAR}, '${ROUND}', ${winner_id}, ${opp_id}, ${W_GOALS}, ${O_GOALS})")
    if [[ $insert_game_result = "INSERT 0 1" ]] 
    then
      echo added game $YEAR $ROUND: $WINNER $W_GOALS - $O_GOALS $OPP
    fi
  fi
done

echo DONE!
