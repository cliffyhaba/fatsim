#!/usr/bin/ruby

# =TOC format:
# - One 16 byte block, for global information
# - (0...n) blocks of 16 bytes - index for one file entry
# -   - 4 bytes offset in partition
# -   - 12 bytes name

require 'record'

# Table of Contents class
# @toc_ary is the array of Records
class Toc
  
  def initialize size
    @size = size
    $LOG.info "Initialising TOC: Size is " + @size.to_s + " bytes"
    @max_tocs = (@size / Record::TOC_ENTRY_SIZE)
    print "So we can have %d TOC entries\n" % @max_tocs
    @toc_ary = Array.new
    @offset = 0
    @part_used = 0
    @part_size = @size * 3
  end

  # Return the TOC data array
  def get_toc
    @toc_ary
  end

  # Like a format
  def reset
    @toc_ary = Array.new
  end
  
  # Add an entry to TOC
  # params: filename
  # returns: nil for fail
  # TODO      a list of offsets and lengths to place in part
  def add name, len
    $LOG.info "Adding an entry to TOC, length is %d" % len
        
    if @toc_ary.size >= @max_tocs
      $LOG.warn "TOC entry limit reached"
      ret = -1    
    elsif @part_used + len > @part_size
      $LOG.warn "TOC No More Space: Used = " \
        + @part_used.to_s + " Len = "        \
        + len.to_s + " Total size = " + @part_size.to_s
      ret = -1        
    else
  
      print "TOC_ARY SIZE = " + @toc_ary.size.to_s + "\n"

      # Sort the array of records
      sort

######################## WORK OUT THE FRAGMENTING HERE, THE TOC RECORS ARE NOW SORTED
# RETURN ret
      # h = Hash.new


                            # Get the lowest offset value or zero
      if @toc_ary.empty?    # || @toc_ary[0].get_offset > 0
        @offset = 0         # Let part take care of the fragmenting
        print "***** INITIALISING TOC RECORD\n"
      else
         disk_details
      end

      # add the record to the TOC table
      r = Record.new
      r.set_fname name
      r.set_offset @offset
      r.set_length len  
      r.set_status 0
      @toc_ary << r   

      ret = @offset
      @offset += len 
      @part_used += len
    end    

    ret           # return details
  end
  
  def get_offset name
    ret = nil
    @toc_ary.each { |r|
      if name == r.get_fname
        ret = r.get_offset
        break
      end
    }
    ret
  end
  
  def get_length name
    ret = nil
    @toc_ary.each { |r|
      if name == r.get_fname
        ret = r.get_length
        break
      end
    }
    ret
  end
  
  def list
    ret = Array.new
    @toc_ary.each { |i|
      ret << i.get_fname
    }
    ret
  end
  
  # Delete file if present, else just fail silently  
  def del name
    @toc_ary.delete_if { |x| x.get_fname == name }
  end
  
  def sort
    @toc_ary.sort!
  end

  def pretty_display
    puts "#{disk_details}"
  end

  private

  def disk_details
    h           = Hash.new
    old_pos     = 0

    sort
   
    for i in (0..@toc_ary.size - 1) 
      # insert 0 to start unused bits
      # print "***** START OF TOC RECORD IS " + @toc_ary[i].get_offset.to_s + "\n"
      # print "***** LENGTH OF DATA IS " + @toc_ary[i].get_length.to_s + "\n"
      
      # insert gap detail
      if old_pos < @toc_ary[i].get_offset
        h.store(old_pos, [:gap, @toc_ary[i].get_offset - old_pos])
        # puts("MIDDLE GAP start - #{old_pos} length - #{@toc_ary[i].get_offset - old_pos}")
        old_pos = @toc_ary[i].get_offset
      end

      h.store(@toc_ary[i].get_offset, [:file, @toc_ary[i].get_length])

      if old_pos > 0 && old_pos < @toc_ary[i].offset
        @offset = old_pos
        break
      end
      old_pos = @toc_ary[i].get_offset + @toc_ary[i].get_length
    end
    # puts "partition size is #{@part_size}"
    
    if old_pos < @part_size
      h.store(old_pos, [:gap, @part_size])
      # puts("END GAP start - #{old_pos} length - #{@part_size}")
    end
    h
  end

end
