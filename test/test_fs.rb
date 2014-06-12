#!/usr/bin/ruby

# =A test harness for a (simple) File System simulator
# Version: 1v0
# Author: Cliff
#

$LOAD_PATH <<'.'<<'../lib'

require 'logger'
require 'filehandler'
require 'utils'
require 'test/unit/assertions'
include Test::Unit::Assertions

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
    fhi.writeFile "1111", "ONE"   
    puts ""
    color(BLUE) { fhi.lst }
    fhi.get_bytes  2  
      
    # 5. Add another file and list
    fhi.writeFile("2222", "TWOTWO")
    puts ""
    color(BLUE) { fhi.lst }
    fhi.get_bytes 5

    # 6. Delete FILE1
    fhi.delFile "1111"
    puts ""
    color(BLUE) { fhi.lst }
    fhi.get_bytes 6
    
    # 7. Add FILE3 this should use the freed space at the beginning of part
    fhi.writeFile("3333", "THREE3THREE")
    puts ""
    color(BLUE) { fhi.lst }
    fhi.get_bytes 7

    # 8. Add FILE4 this should use the freed space at the beginning of part
    fhi.writeFile("4444", "FOURFOURFOURFOUR")
    puts ""
    color(BLUE) { fhi.lst }
    fhi.get_bytes 8


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
  # fhi.pretty_display

  fhi.delFile "3333"

  puts "AFTER DELETING FILE3 IT LOOKS LIKE THIS..."
  # fhi.pretty_display
  fhi.get_bytes 9

  puts "Write 5555"
  fhi.writeFile("5555", "FIVE5FIVE5FIVE")
  # fhi.pretty_display
  fhi.get_bytes 10

  puts "Write 6666"
  fhi.writeFile("6666", "SIXSIXSIXSIXSIXSIX")
  # fhi.pretty_display
  fhi.get_bytes 11

  puts "delete 5555"
  fhi.delFile "5555"
  # fhi.pretty_display
  fhi.get_bytes 12

  puts "Write 7777"
  fhi.writeFile("7777", "SEVENSEVENSEVENSEVENSEVENSEVENSEVEN")
  # fhi.pretty_display
  fhi.get_bytes 13

  fhi.lst

  puts "Read file 2222"
  fc = fhi.readFile "2222"
  puts "raw = #{fc}"
  # str = fc[0...-2].pack('c*')

  str = fc.map {|x| x.chr}.join

  puts "Contents of 2222: - #{str}"

  # puts "Read file 4444"
  # puts "Read file 6666"

  puts "Read file 7777"
  fc = fhi.readFile "7777"
  # puts "raw = #{fc}"
  str = fc.map {|x| x.chr}.join
  puts "Contents of 7777: - #{str}"

  fhi.delFile "7777"
  fhi.lst

  fhi.get_bytes 14

  puts "Write 8888"
  fhi.writeFile("8888", "EIGHTEIGHTEIGHTEIGHTEIGHTEIGHTEIGHTEIGHTEIGHTEIGHT")
  # fhi.pretty_display
  fhi.get_bytes 15

  fhi.lst

  puts "Read file 8888"
  fc = fhi.readFile "8888"
  # puts "raw = #{fc}"
  # str = fc[0...-2].pack('c*')

  str = fc.map {|x| x.chr}.join

  puts "Contents of 8888: - #{str}"

  puts "Write 9999"
  fhi.writeFile("9999", "NINENINENINENINENINE")
  # fhi.pretty_display
  fhi.get_bytes 16
  fhi.lst
  puts "Read file 9999"
  fc = fhi.readFile "9999"
  str = fc.map {|x| x.chr}.join
  puts "Contents of 9999: - #{str}"

  puts "Write AAAA"
  fhi.writeFile("AAAA", "AAAAAAAAAAAAAAAAAA")
  fhi.pretty_display

  fhi.get_bytes 17
  fhi.lst
  puts "Read file AAAA"
  fc = fhi.readFile "AAAA"
  if nil != fc
    str = fc.map {|x| x.chr}.join
    puts "Contents of AAAA: - #{str}"
  end

  fhi.delFile "AAAA"
  ts = "HelloWorld"
  puts "Write AAAA"
  fhi.writeFile("AAAA", ts)
  fhi.pretty_display
  fhi.get_bytes 17
  fhi.lst
  puts "Read file AAAA"
  fc = fhi.readFile "AAAA"
  if nil != fc
    str = fc.map {|x| x.chr}.join
    puts "Contents of AAAA: - #{str}"
  end

  assert str == ts, "File AAAA write/read failed"

  fhi.writeFile("file1", "abcdef1111111111")
  rrr = fhi.readFile "file1"
  rr = rrr.map { |x| x.chr}.join

  assert "abcdef1111111111" == rr, "File file1 write/read failed"
  fhi.pretty_display
  fhi.get_bytes 20

  fhi.writeFile("file2", "qwqq")
  rrr = fhi.readFile "file2"
  rr = rrr.map { |x| x.chr}.join
  assert "qwqq" == rr, "File file2 write/read failed"

  fhi.get_bytes 21

  fhi.writeFile("file3", "rtaa")
  rrr = fhi.readFile "file3"
  rr = rrr.map { |x| x.chr}.join
  fhi.get_bytes 22

  assert "rtaa" == rr, "File file3 write/read failed"
  
  fhi.delFile "6666"

  fhi.writeFile("file4", "asdf")
  rrr = fhi.readFile "file4"
  rr = rrr.map { |x| x.chr}.join
  fhi.get_bytes 23

  puts "free - #{fhi.get_free} bytes"


  gee = fhi.readFile "8888"
  ge = gee.map { |x| x.chr}.join
  assert ge == "EIGHTEIGHTEIGHTEIGHTEIGHTEIGHTEIGHTEIGHTEIGHTEIGHT"

  rescue Exception => e
    print "TEST FAILED: " + e.message
  end
  
else         # failed to get file handler instance
  print "Cannot create new FileHandler\n"
end
