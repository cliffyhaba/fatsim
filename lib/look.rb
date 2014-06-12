#!/usr/bin/ruby -W0

require 'rubygems'
require 'mkgraph'

me = File::basename($0)

if ARGV.size > 0
  file_pattern = ARGV[0]
	if ! File.exist?(ARGV[0])
	  print "Cannot find file " + ARGV[0] + "\n"
	  exit 1
  end
else
  file_pattern = "**/*.rb"
end

a = Mkgraph.new file_pattern

a.run

a.make_image

a.show_image

exit 0

