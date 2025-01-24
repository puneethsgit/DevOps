#!/bin/bash

# single line for loop
for item in apple banana cherry; do echo "Fruit: $item"; done

for i in {1..5}; do echo "Number: $i"; done

# Example 2: Iterating over a range of numbers
for i in {1..5}
do
  echo "Number: $i"
done

# Example 3: Using a C-style for loop
for ((i = 1; i <= 5; i++))
do
  echo "Counter: $i"
done
