#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "$($PSQL "truncate teams, games")"
echo "$($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")"
echo "$($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")"

cat <(tail -n +2 games.csv) | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS
do
  WINNER_ID="$($PSQL "select team_id from teams where name='$WINNER';")"
  if [[ -z $WINNER_ID ]]
  then 
  echo "$($PSQL "insert into teams(name) values('$WINNER');")"
  WINNER_ID="$($PSQL "select team_id from teams where name='$WINNER';")"
  echo Inserted into teams: $WINNER
  fi
  OPPONENT_ID="$($PSQL "select team_id from teams where name='$OPPONENT';")"
  if [[ -z $OPPONENT_ID ]]
  then 
  echo "$($PSQL "insert into teams(name) values('$OPPONENT');")"
  OPPONENT_ID="$($PSQL "select team_id from teams where name='$OPPONENT';")"
  echo Inserted into teams: $OPPONENT
  fi
  echo "$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WIN_GOALS, $OPP_GOALS);")"
  echo Inserted into games: $YEAR, $ROUND, $WINNER vs $OPPONENT, score $WIN_GOALS:$OPP_GOALS
done
