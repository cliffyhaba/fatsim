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

  def getcount
  end

  def format
    @disk.format
  end

  # list files to STDOUT
  def lst
    @disk.lst
  end

  def readFile(name)
    begin
      @disk.readFile name
    rescue Exception => e
      $LOG.warn e.message
      nil
    end
  end

  # Write/create a new file
  def writeFile(name, data)
    begin
      @disk.writeFile name, data
    rescue Exception => e
      $LOG.warn e.message
      nil  
    end  
  end

  def delFile name
    @disk.delFile name
  end
  
  def dump_toc
    @disk.dump_toc
  end
  
  # method to show TOC records as hex and hex dump the partition
  def get_bytes
    @disk.get_byte_disk
  end

end

