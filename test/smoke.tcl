#!/usr/bin/expect

puts "smoke test"
cd ..

set timeout -1
spawn make run
expect {
  timeout {
    send_user "Got unexpected timeout from make run"
  }
  eof {
    send_user "Got EOF from make run"
  }
  "launch*app\$ $" {
    send "simulator infra create\r"
  }
}

expect {
  "Apply complete!" {
    send_user "Infra created!"
  }
}

exp_internal 1
expect {
  "*" {
    send_user "End of simulator infra create output"
    send "simulator ssh config --write\r"
  }
}

expect {
  "*" {
    send_user "Written SSH config"
    send "simulator scenario launch database_compromise\r"
  }
}

# BUG (rem): why is the known hosts file not working?
expect {
  "yes/no" {
    send "yes\r"
  }
}

expect {
  "launch*app" {
    send_user "Scenario launched"
    send "simulator ssh attack"
  }
}

expect {
  "bash-5.0#" {
    send "attack_master 0"
  }
}

# BUG (rem): why is the known hosts file not working?
expect {
  "yes/no" {
    send "yes\r"
  }
}

expect "Last login:"
