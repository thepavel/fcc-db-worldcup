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
    echo $YEAR $ROUND : $WINNER $W_GOALS - $O_GOALS $OPP
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '${WINNER}'")
    opp_id=$($PSQL "SELECT team_id FROM teams WHERE name = '${OPP}'")
    
    echo winner_id: $winner_id
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
        winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '${OPP}'")
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


# skip_headers=1
# IFS=$'\n'
# for row in $(cat games.csv)
# do

#   if ((skip_headers))
#   then
#     ((skip_headers--))
#   else
#     echo '=============================================='
#     echo "Game Row: $row"
#     echo '----------------------------------------------'

#     IFS=','
#     read -r -a game <<< $row

#     year=${game[0]}
#     round=${game[1]}
#     winner=${game[2]}
#     opp=${game[3]}
#     goals_w=${game[4]}
#     goals_o=${game[5]}

#     echo "        Year: $year"
#     echo "       Round: $round"
#     echo "      Winner: $winner"
#     echo "    Opponent: $opp"
#     echo "       Score: $goals_w:$goals_o"    
  
#     winner_id=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c "SELECT team_id FROM teams WHERE name = '$winner'")
#     # query="SELECT team_id FROM teams WHERE name = '${TEAM_NAME}'"
#     # echo $($PSQL "${query}")
#     winner_result=$PSQL
#     winner_result+=" 'SELECT team_id FROM teams WHERE name = '$winner''" 
#     echo $($winner_result)
#     exit

#     # winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner'")
#     query="SELECT team_id FROM teams WHERE name = '${winner}'"
#     echo $query
#     # insert_query_test=$($PSQL "${query}")
#     # echo $insert_query_test

#     opp_id=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c "SELECT team_id FROM teams WHERE name = '$opp'")
#     if [[ -z $winner_id ]]
#     then
#       echo $winner is a new team
      
#       insert_team_result=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c " INSERT INTO teams(name) VALUES('$winner')")
#       if [[ $insert_team_result = "INSERT 0 1" ]]
#       then
#         echo inserted new team

#         winner_id=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c "SELECT team_id FROM teams WHERE name = '$winner'")
#         echo $winner has id:$winner_id
#       else 
#         echo error inserting new team
#         echo $insert_team_result  
#       fi
#     else
#       echo $winner has id:$winner_id
#     fi
    
#     # add opponent team if it doesn't exist
#     if [[ -z $opp_id ]]
#     then
#       echo $opp is a new team

#       opp_insert_result=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c " INSERT INTO teams(name) VALUES('$opp')")
#       if [[ $opp_insert_result = "INSERT 0 1" ]]
#       then
#         echo inserted new team

#         opp_id=$(psql --username=freecodecamp --dbname=worldcup -t --no-align -c "SELECT team_id FROM teams WHERE name = '$opp'")
#         echo $opp has id: $opp_id
#       else 
#         echo error inserting new team
#         echo $opp_insert_result  
#       fi
#     else
#         echo $opp has id: $opp_id
#     fi
    
#   fi
# done

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
