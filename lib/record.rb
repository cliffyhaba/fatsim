#!/usr/bin/ruby

$LOAD_PATH <<'.'

require 'utils'

# The implementation of an individual entry
class Record < Array
  TOC_ENTRY_SIZE = 16
  TOC_NAME_SIZE  = 10
  
  attr_accessor :offset
  
  def initialize                                    # can we overide this in Ruby??
    @offset = 0
    @length = 0
    @status = 0
    @fname  = ""
  end

  def set_offset i
    if i > 0xfffe 
      print "offset = %d\n" % i
      $LOG.fatal "Offset Exceeded System Boundries"
      raise "Offset is Beyond File System Boundries" + " - " + __FILE__ + " " + __LINE__.to_s
      exit(1)
    end
    @offset = i
  end

  def set_length i
    if i > 0xfffe 
      print "length = %d\n" % i
      $LOG.fatal "Length Exceeded System Boundries"
      raise "Length Extends Beyond File System Boundries" + " - " + __FILE__ + " " + __LINE__.to_s
      exit(1)
    end
    @length = i
  end

  def set_status i
    if i > 0xfffe 
      print "status = %d\n" % i
      $LOG.fatal "Status Exceeded System Boundries"
      raise "Status Extends Beyond File System Boundries" + " - " + __FILE__ + " " + __LINE__.to_s
      exit(1)
    end
    @status = i
  end

  def set_fname s
    if s.length > TOC_NAME_SIZE
      print "name length = %d\n" % s.length
      $LOG.fatal "Name Size Exceeded System Boundries"
      raise "Name Size Extends Beyond File System Boundries" + " - " + __FILE__ + " " + __LINE__.to_s
      exit(1)
    end  
    @fname = s
  end
  
  def get_offset
    @offset
  end

  def get_length
    @length
  end
  
  def get_status
    @status
  end
  
  def get_fname
    @fname
  end
                                                      # the binary versions of the above methods
  def set_byte_offset i
    @offset = i.pack("C2").unpack("n")
  end

  def set_byte_length i
    @length = i.pack("C2").unpack("n")
  end

  def set_byte_status i
    @status = i.pack("C2").unpack("n")
  end

  def set_byte_fname s
    @fname = s.pack("C10").unpack("A10")
  end
  
  def get_byte_offset
    offset_ary = [@offset].pack("n").unpack("C2")   # make a byte array from offset
    offset_ary
  end

  def get_byte_length
    length_ary = [@length].pack("n").unpack("C2")   # make a byte array from length
    length_ary
  end

  def get_byte_status
    status_ary = [@status].pack("n").unpack("C2")   # make a byte array from status
    status_ary
  end
  
  def get_byte_fname
    fname_ary = [@fname].pack("A12").unpack("C10")  # make byte array from fname
    fname_ary
  end

  def get_byte_rec
    offset_ary = [@offset].pack("n").unpack("C2")   # make a byte array from offset
    length_ary = [@length].pack("n").unpack("C2")   # make a byte array from length
    status_ary = [@status].pack("n").unpack("C2")   # make a byte array from status
    fname_ary = [@fname].pack("A10").unpack("C10")  # make byte array from fname
    offset_ary + length_ary + status_ary + fname_ary
  end
  
  # Make it sortable on the @offset attribute
  def <=> (p)
    # @a + @b <=> p.a + p.b
    @offset <=> p.offset
  end

end
