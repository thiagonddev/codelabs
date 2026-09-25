#!/usr/bin/env bash

echo "=== ATM Withdrawal ==="

balance=1000

read -rp "Enter amount to withdraw: " amount

if ! [[ "$amount" =~ ^[0-9]+$ ]]; then
    echo "Invalid input. Please enter a whole number."
elif [ "$amount" -le 0 ]; then
    echo "Invalid withdrawal amount."
elif [ "$amount" -gt "$balance" ]; then
    echo "Insufficient funds."
else
    balance=$((balance - amount))
    echo "Withdrawal successful!"
    echo "Remaining balance: R$ $balance"
fi