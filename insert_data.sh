#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

GetTeamId() {

  TEAM_NAME=$1
  TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM_NAME'")"


  if [[ -z $TEAM_ID ]] # if team_id is empty, team doesn't exist.
  then 
    # insert a new team
    insert_team_query="INSERT INTO teams(name) VALUES('$TEAM_NAME')"
    insert_team_result="$($PSQL "$insert_team_query")"

    if [[ $insert_team_result = "INSERT 0 1" ]]
    then
      # new team inserted
      TEAM_ID="$($PSQL "$get_team_query")"
    fi
  fi
  # return $1;
}

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

    winner=${game[2]}

    echo "    Year: ${game[0]}"
    echo "    Round: ${game[1]}"
    echo "    Winner: $winner"
    echo "    Opponent: ${game[3]}"
    echo "    Score: ${game[4]}:${game[5]}"    
  fi
done

# skip_headers=1
# while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
# do
#     if ((skip_headers))
#     then
#         ((skip_headers--))
#     else
#         GetTeamId $WINNER
#         WINNER_ID=$TEAM_ID

#         GetTeamId $OPPONENT
#         OPP_ID=$TEAM_ID
#         echo "I got:$YEAR|$ROUND|$WINNER|$OPPONENT"
#     fi
# done < games.csv
