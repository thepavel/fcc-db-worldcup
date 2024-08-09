#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "----- Clear Existing Data -----"
echo $($PSQL "TRUNCATE games, teams")

TEAM_NAME="France"
query="INSERT INTO teams(name) VALUES('${TEAM_NAME}')"
insert_command_france=$($PSQL "${query}")
echo $insert_command_france
echo $PSQL "INSERT INTO teams(name) VALUES('${TEAM_NAME}')"
#echo $($PSQL $query)

exit

skip_headers=1
IFS=$'\n'
for row in $(cat games.csv)
do
  if ((skip_headers))
  then
    ((skip_headers--))
  else
    echo '=============================================='
    echo "Game Row: $row"
    echo '----------------------------------------------'

    IFS=','
    read -r -a game <<< $row

    year=${game[0]}
    round=${game[1]}
    winner=${game[2]}
    opp=${game[3]}
    goals_w=${game[4]}
    goals_o=${game[5]}

    echo "    Year: $year"
    echo "    Round: $round"
    echo "    Winner: $winner"
    echo "    Opponent: $opp"
    echo "    Score: $goals_w:$goals_o"    

    query="INSERT INTO teams(name) VALUES('${winner}')"
    insert_command_result=$($PSQL "${query}")
    
    
    # echo $($PSQL "SELECT team_id FROM teams")psql --username=freecodecamp --dbname=worldcup -t --no-align -c "SELECT team_id FROM teams"
    # echo $TEAM_ID
    # psql --username=freecodecamp --dbname=worldcup -t --no-align -c "SELECT team_id FROM teams"
    # echo "${PSQL}"
    # echo $PSQL "SELECT team_id FROM teams"
    # echo $($PSQL "SELECT team_id FROM teams where name='France'")
    # winner_id=$($PSQL SELECT team_id FROM teams)
    # echo $winner_id
    
    
    exit
  fi
done

# IFS=$'\n'
# skip_headers=1
# while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
# do
#     if ((skip_headers))
#     then
#         ((skip_headers--))
#     else
#         GetOrCreateTeamIdFromTeamName $WINNER
#         WINNER_ID=$TEAM_ID

#         GetOrCreateTeamIdFromTeamName $OPPONENT
#         OPP_ID=$TEAM_ID
#         echo "I got:$YEAR|$ROUND|$WINNER|$OPPONENT"
#     fi
# done < games.csv
