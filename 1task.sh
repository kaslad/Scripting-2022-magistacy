# This function checks if the given input is a valid number (i.e. a digit between 0 and 9).
function is_valid() {
  if [[ ${#1} != 1 ]]; then
    return 1
  fi

  # Check for valid characters (digits)
  if [[ ! $1 =~ ^[[:digit:]]$ ]]; then
    return 1
  fi

  return 0
}

function start_game() {
  # Generate a random number between 0 and 9.
  local random=$(( RANDOM % 10 ))

  if [[ $1 == $random ]]; then
    ((guessed++))

    # Add the successful guess to the history.
    history+=("$1+")

    echo "Вы угадали!"
  else
    ((not_guessed++))

    # Add the failed guess to the history.
    history+=("$1")

    echo "Вы не угадали :("
  fi

  # If the history has more than 10 entries, remove the oldest entry.
  if [[ ${#history[*]} -gt 10 ]]; then
    history=("${history[@]:1}")
  fi

  # Calculate the total number of guesses (successful and failed
  local total_count=$((guessed + not_guessed))

  # Print the statistics (percentage of successful and failed guesses
  echo "Статистика (угадано/не угадано):" $((guessed * 100 / total_count))% $((not_guessed * 100 / total_count))%

  # Print the history of guesses.
  echo "Введенные числа:" ${history[@]}
}

# Initialize the number of successful and failed guesses to 0, history.
guessed=0
not_guessed=0

history=()

while true; do
  # Read the users guess
  read -p "Какое число от 0 до 9 загадано сейчас (q - выход)? " guess

  # Check if the user wants to exit
  if [[ $guess == "q" ]]; then
    break
  fi

  # Check if the users input is valid
  if is_valid $guess; then
    start_game $guess
  else
    echo "Недопустимое значение!"
  fi
done