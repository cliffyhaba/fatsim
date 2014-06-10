#!/usr/bin/ruby -w

require 'logger'

#
## A utility file
##
#

# set up another logger for utils
$UTIL_LOG = Logger.new($log_op).tap do |log|  # $log_op from test_fs
  log.progname = 'Utils'
  log.level = Logger::INFO
  if $LOG_FMT == 'brief'
    log.formatter = proc do |severity, datetime, progname, msg| 
      "#{progname}: #{msg}\n"
    end
  end
end

def dump what
  # print "Dump size = " + what.length.to_s

  what.each_index { |i|
    
    if nil == what.at(i)
      ia = 0
    else
      ia = what.at(i)
    end
    
    if 0 == i % 8 and 0 != i % 16
      print "- "
    end

    if 0 == (i % 16)
      print "\n"
      printf("%02X ", ia)
    else
      printf("%02X ", ia)
    end
  }
  
  # print "\n**************************************************\n"
  print "\n"
end

class MyString < String
  @@size=10
  
  def self.set_size size
    @@size = size
  end
  
  def initialize a
    a = a.ljust(@@size, padstr=' ')
    super a[0...@@size]
  end
      
end

RED     = 31
GREEN   = 32
BLUE    = 34

def color (color)
  if RUBY_PLATFORM.include? "linux"
    printf "\033[#{color}m"
    yield
    printf "\033[0m"
  else
    nil
  end
end
{}

