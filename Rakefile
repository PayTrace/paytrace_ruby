require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
   t.libs << "paytrace_ruby"
   t.test_files = FileList['test/test*.rb']
   t.verbose = true
end

task :default => :test
