#!/usr/bin/ruby

# Inner disk Data class
class Partition
  def initialize size
    # print "Initialising Partition\n"
    @size = size
    @rem = size
    # print "Partition size is " + @size.to_s + "\n"
    @part = Array(0..(@size - 1))
  end

  # Return the partition data array
  def get_part
    @part
  end

  def get_size
    @size
  end
  
  # Add the data to the partition
  # offset is the first bit of part that we can use.
  # This is the FILE WRITE!!
  # called from line 115  (writeFile) in filesystem, after getting details from toc.add 

  def add data, offset
    next_frag = 0
    $LOG.debug "Setting partition at offset " + offset.to_s + " To " + data
    len = data.length

    # can we fit it in??
    # lets say no. so we have to create a ????? and use that as
    # an enumerator
    #

    

    dary = [data].pack("a*").unpack("C*")
    @part[offset, dary.length] = dary

    @part[(offset + dary.length), 2] = [next_frag].pack("n").unpack("C2")
    
    @rem -= (dary.length + FileSystem::get_link_size)
  end
  
=begin
  def get_rem
    @rem
  end
=end
  
  def take offset, length
    @part[offset, length]
  end
  
end
