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

  def add haction, data
    next_frag = 0
    # $LOG.debug "Setting partition at offset " + offset.to_s + " To " + data
    len = data.length

    puts "In part add data length is #{data.length}"
    cnt = 1
    idx = haction.length
    dindex = 0

    # we have to work out the forward links
    flidx = 0
    fl = []
      haction.each { |a|
      if flidx > 0
        fl << a[0]
      end  
      flidx += 1    
    }
    fl << 0

    haction.each { |a|
      dary = [data[dindex, (a[1] - 2)]]
      @part[a[0], (a[1] - 2)] = dary.pack("a*").unpack("C*")
      puts "fl[cnt - 1] = #{fl[cnt - 1]}"
      if cnt < idx
        @part[a[0] + (a[1] - 2), 2] = [fl[cnt - 1]].pack("n").unpack("C2")
      else
        @part[a[0] + (a[1] - 2), 2] = [0].pack("n").unpack("C2")
      end
      dindex += (a[1] - 2)
      cnt += 1
    }
    @rem -= (len + (FileSystem::get_link_size * idx))
  end

=begin
    dary = [data].pack("a*").unpack("C*")
    @part[offset, dary.length] = dary

    @part[(offset + dary.length), 2] = [next_frag].pack("n").unpack("C2")
    
    @rem -= (dary.length + FileSystem::get_link_size)
  end
  

  def get_rem
    @rem
  end
=end
  
  def take fd
    # puts "TAKE - #{fd}"
    r = []
    fd.each { |a|
      r << @part[a[0], a[1]]
    }
    r.flatten
  end
  
end
