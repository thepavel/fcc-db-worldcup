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
  get_team_query="SELECT team_id FROM teams WHERE name='$TEAM_NAME'"
  echo $get_team_query
  TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM_NAME'")"
  echo $TEAM_ID

  if [[ -z $TEAM_ID ]] # if team_id is empty, team doesn't exist.
  then 
    # insert a new team
    insert_team_query="INSERT INTO teams(name) VALUES('$TEAM_NAME')"
    insert_team_result="$($PSQL $insert_team_query)"
    echo $insert_team_result

    if [[ $insert_team_result="INSERT 0 1" ]]
    then
      echo inserted, querying
      TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM_NAME'")"
    else 
      echo $insert_team_result
    fi

  fi
  # return $1;
}

skip_headers=1
while IFS=, read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    if ((skip_headers))
    then
        ((skip_headers--))
    else
        GetTeamId $WINNER
        echo $TEAM_ID
        echo "I got:$YEAR|$ROUND|$WINNER|$OPPONENT"
        

    fi
done < games.csv
