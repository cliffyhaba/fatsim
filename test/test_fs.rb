#!/usr/bin/ruby

# =A test harness for a (simple) File System simulator
# Version: 1v0
# Author: Cliff
#

$LOAD_PATH <<'.'<<'../lib'

require 'logger'
require 'filehandler'
require 'record'
require 'toc'
require 'part'
require 'utils'

# we will try and log to some other terminal if we can
if RUBY_PLATFORM.include? "linux"

  my_tty_num = `tty | sed 's,/dev/pts/,,g'`
  them = `who | awk '{print $2}' | grep pts | sed 's,pts/,,g'`

  tty_ary = them.split(/\n/)

  $log_op = $stderr

  tty_ary.each { |t|
    if my_tty_num.to_i != t.to_i
      $log_op = '/dev/pts/' + t
    end
  }
else
  $log_op = $stderr
end

# Globals and Constants
$LOG_FMT = 'brief'
$REQ_FILE_SIZE = 192

$show_dump = true                      # Show hex dumps
$r = nil                                # return value
$run_record = false

big_string = <<EOS
abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnop
EOS


# set up the logging, utils currently has its own logger 
# but uses the globals above
$LOG = Logger.new($log_op).tap do |log|
  log.progname = 'Test'
  log.level = Logger::DEBUG
  if $LOG_FMT == 'brief'
    log.formatter = proc do |severity, datetime, progname, msg| 
      "#{progname}: #{msg}\n"
    end
  end
end

# Hex dump
def show_hex ary, pos = 0
  if $show_dump
    puts "\n#{pos}] Disk Dump"
    dump ary
  end
end

#
############# Test Code Main
#

$LOG.info "START"
print "\nStart\n"
print "=====\n\n"

# Maybe run the record test
if $run_record == true
  record_test
end

# Create an instance of the FileHandler
begin
  $LOG.info ""
  $LOG.info "Making a FileHandler instance..."
  fhi = FileHandler.new $REQ_FILE_SIZE
rescue Exception => msg
  $LOG.info "!! " + msg.message
  fhi = nil                           # we have failed
  exit 1
end

# If we got a FileHandler instance the do the tests
if fhi                                
  begin  
    fhi.format
        
    # 2. Do a write
    fhi.writeFile "FILE1", "11111"   
    puts ""
    color(BLUE) { fhi.lst }
    show_hex fhi.get_bytes, 2  
      
    # 5. Add another file and list
    fhi.writeFile("FILE2", "222222")
    puts ""
    color(BLUE) { fhi.lst }
    show_hex fhi.get_bytes, 5

    # 6. Delete FILE1
    fhi.delFile "FILE1"
    puts ""
    color(BLUE) { fhi.lst }
    show_hex fhi.get_bytes, 6
    
    # 7. Add FILE3 this should use the freed space at the beginning of part
    fhi.writeFile("FILE3", "3333333333")
    puts ""
    color(BLUE) { fhi.lst }
    show_hex fhi.get_bytes, 7

    # 8. Add FILE4 this should use the freed space at the beginning of part
    fhi.writeFile("FILE4", "444444444444444444444444444444")
    puts ""
    color(BLUE) { fhi.lst }
    show_hex fhi.get_bytes, 8


=begin

    # 9. 
    fhi.delFile "FILE2"
    fhi.delFile "FILE3"
    fhi.writeFile("FILE5", "55555")
    puts ""
    color(BLUE) { fhi.lst }
    show_hex fhi.get_bytes, 9

    # 10.
    fhi.writeFile("FILE6", "666666")
    puts ""
    color(BLUE) { fhi.lst }
    show_hex fhi.get_bytes, 10
=end
  
  puts "FINALLY LOOKS LIKE THIS..."
  fhi.pretty_display

  fhi.delFile "FILE3"

  puts "AFTER DELETING FILE3 IT LOOKS LIKE THIS..."
  fhi.pretty_display
  show_hex fhi.get_bytes, 9

  puts "Write file10"
  fhi.writeFile("file10", "!!!!!!!!!!")
  fhi.pretty_display
  show_hex fhi.get_bytes, 10


  rescue Exception => e
    print "TEST FAILED: " + e.message
  end
  
else         # failed to get file handler instance
  print "Cannot create new FileHandler\n"
end
