#!/usr/bin/expect

set timeout -1

# Get the response parameter from the command line
set mod [lindex $argv 0]

# Run your command with multiple prompts
spawn ./dodsserver mods-install

expect "or exit to abort" {
    send "$mod\r"
}

expect eof