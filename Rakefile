require "rake/testtask"
require "rdoc/task"
require "yard"

Rake::TestTask.new do |t|
  t.test_files = FileList.new("test/test_*.rb") do |fl|
      fl.exclude(/.*blackbox.*/)
  end
  t.verbose = true
end

RDoc::Task.new do |rdoc|
    rdoc.rdoc_files.include("lib/*.rb")
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/*.rb']   # optional
  t.options = ['--any', '--extra', '--opts'] # optional
  t.stats_options = ['--list-undoc']         # optional
end

task :flog do |t|
  puts "== Flog =="
  puts `flog lib/*.rb`
  puts "=========="
end

task :default => :test
task :test
