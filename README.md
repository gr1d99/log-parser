## LogParser
A simple ruby script that processes this [log file](https://github.com/gr1d99/log-parser/blob/master/log_parser.rb) and outputs **most visited pages** and **unique page visits** and, they are all ordered by **visit(s) count**.

# Technologies
1. Install [RVM(Ruby Version Manager)](https://rvm.io/rvm/install).
2. Install ruby v3+ with this command `$  rvm install 3.0.0`

# Installation and Execution
```bash
$ git clone git@github.com:gr1d99/log-parser.git
$ cd log-parser
$ bundle install
$ ruby log_parser.rb webserver.log --verbose
```

# Tests
```bash
$ ruby tests/log_parser_test.rb
```
