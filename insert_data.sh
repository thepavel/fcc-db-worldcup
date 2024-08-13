#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "----- Clear Existing Data -----"
truncate_command="$PSQL \"TRUNCATE games, teams\""
truncate_result=$($PSQL "TRUNCATE games, teams")
echo $($PSQL "TRUNCATE games, teams")

TEAM_NAME="France"
query="INSERT INTO teams(name) VALUES('${TEAM_NAME}')"
insert_command_france=$($PSQL "${query}")
echo $insert_command_france

query="SELECT team_id FROM teams WHERE name = '${TEAM_NAME}'"
echo $($PSQL "${query}")

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

    echo "        Year: $year"
    echo "       Round: $round"
    echo "      Winner: $winner"
    echo "    Opponent: $opp"
    echo "       Score: $goals_w:$goals_o"    
  
    winner_id=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c "SELECT team_id FROM teams WHERE name = '$winner'")
    winner_id=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c "SELECT team_id FROM teams WHERE name = '${winner}'")
    query="SELECT team_id FROM teams WHERE name = '${winner}'"
    echo $query
    # insert_query_test=$($PSQL "${query}")
    # echo $insert_query_test

    opp_id=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c "SELECT team_id FROM teams WHERE name = '$opp'")

    if [[ -z $winner_id ]]
    then
      echo $winner is a new team
      
      insert_team_result=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c " INSERT INTO teams(name) VALUES('$winner')")
      if [[ $insert_team_result = "INSERT 0 1" ]]
      then
        echo inserted new team

        winner_id=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c "SELECT team_id FROM teams WHERE name = '$winner'")
        echo $winner has id:$winner_id
      else 
        echo error inserting new team
        echo $insert_team_result  
      fi
    else
      echo $winner has id:$winner_id
    fi
    
    # add opponent team if it doesn't exist
    if [[ -z $opp_id ]]
    then
      echo $opp is a new team

      opp_insert_result=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c " INSERT INTO teams(name) VALUES('$opp')")
      if [[ $opp_insert_result = "INSERT 0 1" ]]
      then
        echo inserted new team

        opp_id=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c "SELECT team_id FROM teams WHERE name = '$opp'")
        echo $opp has id: $opp_id
      else 
        echo error inserting new team
        echo $opp_insert_result  
      fi
    else
        echo $opp has id: $opp_id
    fi
    
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
