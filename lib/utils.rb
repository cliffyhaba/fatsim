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
  
  asky = []

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
      if i > 0
        print "  "
        dsp asky
      end
      asky.clear
      print "\n"
      printf("%02X ", ia)
      asky << ia
    else
      printf("%02X ", ia)
      asky << ia
    end
  }
  print "  "
  dsp asky
  
  # print "\n**************************************************\n"
  print "\n"
end

def dsp a
  idx = 0
  a.each { |e|
    if idx == 8
      print " "
    end

    if e > 32 && e < 128
      print e.chr
    else
      print "."
    end
    idx += 1
    if idx == 16
      idx = 0
    end
  }
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

