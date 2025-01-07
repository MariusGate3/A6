#!/usr/bin/env bash

set -e
make clean

GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
RED='\033[31m'
BOLD='\033[1m'
RESET='\033[0m'

PROGRAM_OG="./sim-linux radix.riscv --"
PROGRAM_OPT="./sim-linux radix_new.riscv --"

DATASET_DIR="datasets"

mkdir -p "$DATASET_DIR"

echo -e "${BLUE}${BOLD}Compiling RISC-V programs...${RESET}"
make radix.riscv
echo -e "${GREEN}Original program (radix.riscv) compiled.${RESET}"
make radix_new.riscv
echo -e "${GREEN}Optimized program (radix_new.riscv) compiled.${RESET}"

echo -e "${BLUE}${BOLD}Generating datasets...${RESET}"
./generate-linux "$DATASET_DIR/a" 500 10000 20000 100 5000
echo -e "${CYAN}Dataset a generated.${RESET}"
./generate-linux "$DATASET_DIR/b" 25000 100 600 10 400
echo -e "${CYAN}Dataset b generated.${RESET}"
./generate-linux "$DATASET_DIR/c" 10000 10 2000 50 250
echo -e "${CYAN}Dataset c generated.${RESET}"

echo ""
echo -e "${BLUE}${BOLD}Running tests...${RESET}"

total_improvement=0
test_count=0

for dataset in a b c; do
  INPUT_FILE="$DATASET_DIR/$dataset.in"
  REF_OUTPUT="$DATASET_DIR/$dataset.out"
  TEST_OUTPUT="$DATASET_DIR/$dataset.new.out"

  echo -e "${BLUE}Testing with Dataset $dataset...${RESET}"

  echo -e "${YELLOW}Running original program...${RESET}"
  result_og=$($PROGRAM_OG "$INPUT_FILE" "$REF_OUTPUT")
  cycles_og=$(echo "$result_og" | grep "simulated clock cycles" | sed -E 's/.* ([0-9]+) simulated clock cycles.*/\1/')
  echo -e "${CYAN}Original program clock cycles: $cycles_og${RESET}"

  echo -e "${YELLOW}Running optimized program...${RESET}"
  result_opt=$($PROGRAM_OPT "$INPUT_FILE" "$TEST_OUTPUT")
  cycles_opt=$(echo "$result_opt" | grep "simulated clock cycles" | sed -E 's/.* ([0-9]+) simulated clock cycles.*/\1/')
  echo -e "${CYAN}Optimized program clock cycles: $cycles_opt${RESET}"

  if diff -q "$TEST_OUTPUT" "$REF_OUTPUT" > /dev/null; then
    echo -e "${GREEN}Output matches the reference!${RESET}"
  else
    echo -e "${RED}Output differs from reference!${RESET}"
  fi

  improvement=$(echo "scale=4; (1 - $cycles_opt / $cycles_og) * 100" | bc)
  echo -e "${GREEN}Percentage improvement: ${improvement}%${RESET}"
  total_improvement=$(echo "$total_improvement + $improvement" | bc)
  test_count=$((test_count + 1))
  echo ""
done

average_improvement=$(echo "scale=4; $total_improvement / $test_count" | bc)
echo -e "${CYAN}${BOLD}Average Percentage Improvement: ${average_improvement}%${RESET}"

exit 0
