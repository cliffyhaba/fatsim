#!/usr/bin/ruby

# Author:: Cliff
# Version:: 1v0

require 'logger'
require 'filesystem'

# =The Interface for the File System
# =To simulate a very simple FAT like file system in RAM
# ==A top level class for simple read/write to some abstracted file system
class FileHandler

  def initialize size
    @disk = MemFileSystem.new size
  end

  def get_free
    @disk.get_free
  end

  def format
    @disk.format
  end

  # list files to STDOUT
  def lst
    puts "\n==>"
    color(GREEN) {
      @disk.lst
    }
    puts "#{@disk.get_free} Bytes free\n"
  end

  def readFile(name)
    begin
      r = @disk.readFile name
    rescue Exception => e
      $LOG.warn e.message
      throw e
    end
    # puts "fhi returning #{r}"
    r
  end

  # Write/create a new file
  def writeFile(name, data)
    begin
      @disk.writeFile name, data
    rescue Exception => e
      $LOG.warn e.message
      throw e
    end  
  end

  def delFile name
    @disk.delFile name
  end
  
  def dump_toc
    dump @disk.dump_toc
  end
  
  def dump_part
    dump @disk.dump_part
  end

  # method to show TOC records as hex and hex dump the partition
  def get_bytes_all
    @disk.get_byte_disk
  end

  def get_bytes n
    puts "DUMP #{n}"

    dump_toc
    dump_part
  end

  def pretty_display
    @disk.pretty_display
  end
end

