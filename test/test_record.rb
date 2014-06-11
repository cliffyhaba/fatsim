#!/usr/bin/ruby

# =A test harness for a (simple) File System simulator
# Version: 1v0
# Author: Cliff
#


require 'logger'
require 'filehandler'
require 'record'
require 'toc'
require 'part'
require 'utils'

$LOAD_PATH <<'.'<<'../lib'

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
  log.progname = 'Test Record'
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

# Test the Record class
def record_test
  print "***** Record Test\n"
  r = Record.new

  # create a new record and initialise with standard values
  r.set_fname "abcd"
  r.set_offset 123
  
  # check all OK
  $LOG.info "offset = [%d]" % r.get_offset
  $LOG.info "fname = [%s]" % r.get_fname

  # get byte representation of the record

  res = r.get_byte_offset
  # Then check the dump is OK
  dump res

  res = r.get_byte_fname
  # Then check the dump is OK
  dump res

  res = r.get_byte_rec
  # Then check the dump is OK
  dump res

  newr = Record.new

  # Set up new record with byte data
  newr.set_byte_offset r.get_byte_offset
  newr.set_byte_fname r.get_byte_fname

  # check all OK
  $LOG.info "NEW offset = [%d]" % newr.get_offset
  $LOG.info "NEW fname = [%s]" % newr.get_fname
  print "***** Record Test\n"
end

record_test
