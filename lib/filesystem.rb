#!/usr/bin/ruby

# Author:: Cliff
# Version:: 1v1

require 'logger'
require 'toc'
require 'part'

# Do we automatically fit new files into available locations
# at the start of the disk, or do we try to keep files un-fragmented
# if possible. A value of yes means the former.
FRAG_ALWAYS = "yes"

# =A template FileSystem class
# - Can derive from this to implement file systems in RAM, flash etc.
class FileSystem

  # LINK_SIZE = 2

  # def self.get_link_size
  #  LINK_SIZE
  # end

  # do any parent initialising
  def initialize size
    # print "Parent of " + self.class.name + " Initialising...\n"
  end

  def format
    @toc.reset
    @part.get_part.fill(0xff)
  end
  
  # Read a file from FS
  def readFile name
  end

  # Write a file to FS
  def writeFile name, data
  end
  
  # print table of contents in hex
  def dump_toc
  end

  # print data portion of disk in hex
  def dump_data
  end

  # print all disk partition in hex
  def dump_all
  end
end

# =A specific FileSystem class, uses RAM as disk
class MemFileSystem < FileSystem

  private
  attr_accessor :toc, :part
  
  public
  
  def initialize size
    # print "Initialising child\n"
    if 0 != size % 64
      raise "Please use a size which is a multiple of 16" + " - " + __FILE__ + " " + __LINE__.to_s
    elsif size < 128
      raise "Minimum disk size is 128 bytes" + " - " + __FILE__ + " " + __LINE__.to_s
    else
      super
      @size = size
      @toc = Toc.new @size / 4
      @part = Partition.new (@size / 4) * 3
    end
    $LOG.info "Initialised MemFileSystem Instance"
  end

  # Format the media
  def format
    @toc.reset
    @part.get_part.fill(0xff)
  end
  
  def readFile name
    fd = @toc.get_file_details name

    if [] == fd
      puts "<#{name}> File not Found"
      raise "<" + name + "> File Not Found" + " - " + __FILE__ + " " + __LINE__.to_s
    else
      # puts "readFile - file details are #{fd}"
      fb = @part.take fd
    end
    # puts "fs returning #{fb}"
    fb
  end
  
  def writeFile name, data
    # Add name to TOC
    req = data.length # + FileSystem::get_link_size
    rem = @toc.get_available
    puts "avail = #{rem} required = #{req}"
    if req > rem
      raise "Out of Disk Space" + " - " + __FILE__ + " " + __LINE__.to_s
    end
    
    @toc.get_toc.each { |i|
      # print "!!!!! get_toc " + i.get_fname + "\n"
      if i.get_fname == name
        raise "File Already Exists: " + name + " - " + __FILE__ + " " + __LINE__.to_s
      end      
    }
    
    # Check we have the space available
#    offset = @toc.add name, req #  + FileSystem::get_link_size
    haction = @toc.add name, req #  + FileSystem::get_link_size

    # print "WRITE] size available is: " + rem.to_s + "\n"
    # print "WRITE] size required  is: " + req.to_s + "\n"

    # puts "haction is #{haction}"
    # puts "you are here"
    
    @part.add haction, data

  end

  def delFile name
    @toc.del name
  end

  def lst
    @toc.list.each { |l|
      print l + "\n"
    }    
  end
  
  # Display Table of Contents in hex
  def dump_toc
    ary = Array.new
    @toc.get_toc.each { |t|
      ary << t.get_byte_rec
    }    
    ary.flatten
  end

  # Display data in hex
  def dump_part
    @part.get_part
  end

  # Return all disk as binary array
  def get_byte_disk
    ary = Array.new
    @toc.get_toc.each { |t|
      ary << t.get_byte_rec
    }
    ary << @part.get_part    
    ary.flatten
  end
  
  def pretty_display
    @toc.pretty_display
  end

  private

end
