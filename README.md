# Elite Trader

Elite Trader is a command line utility that parses the daily csv and json dumps
from eddb. Currently it searches for the most profitable trade deal in the
bubble, disregarding the actual distance between the buy and sell station.

## Usage

Usage is very simple, just initialize the ruby environment using bundle and
execute the run script.

    bundle install
    ruby trader.rb COMMAND

A list of the various options can be found by executing the help task.

    ruby trader.rb help
