
$LOAD_PATH <<'.'<<'lib'

require 'rake/testtask'
require 'utils'

desc  "Run Unit Tests on FatSim"

Rake::TestTask.new(name=:test) do |t|
	  t.libs << "test"
	  t.test_files = FileList['test/test*.rb'].exclude('test/test_record.rb')
	  t.verbose = true
end

Rake::TestTask.new(name=:all) do |t|
    t.libs << "test"
    t.test_files = FileList['test/test*.rb']
    t.verbose = true
end

Rake::TestTask.new(name=:quiet) do |t|
	  t.libs << "test"
	  t.test_files = FileList['test/test*.rb'].exclude('test/test_record.rb')
	  t.verbose = false
end

task  :default => :what

task :q  => [:header, :quiet, :footer]

# Do everything, including the record test
task :full => :all

task  :what => [:header, :test, :footer]

# Not used
task  :build do
  (0..5).each { |i|
    puts"=> Build What?"
  } 
end

# Cosmetics
task  :header do
  if RUBY_PLATFORM.include?("linux")
    color(RED) { puts "\n=~=~=~=~=~=~=~=~=~=~=~=~ Start of Test =~=~=~=~=~=~=~=~=~=~=~=~" }
  else
    puts "\n\n=~=~=~=~=~=~=~=~=~=~=~=~ Start of Test =~=~=~=~=~=~=~=~=~=~=~=~\n" 	
  end
end

task  :footer do
  if RUBY_PLATFORM.include?("linux") == true
    color(GREEN) { puts "\n=~=~=~=~=~=~=~=~=~=~=~=~ End of Test =~=~=~=~=~=~=~=~=~=~=~=~" }
  else
    puts "\n=~=~=~=~=~=~=~=~=~=~=~=~ End of Test =~=~=~=~=~=~=~=~=~=~=~=~\n"
  end
end
