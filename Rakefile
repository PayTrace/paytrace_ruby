require "bundler/gem_tasks"
require 'rake/testtask'
require 'paytrace/version'

Rake::TestTask.new do |t|
   t.libs << "lib/paytrace_ruby"
   t.test_files = FileList['test/**/*_spec.rb']
   t.verbose = true
end

task :build do 
  system "gem build paytrace.gemspec"
end

task :release => :build do
  system "gem push paytrace-#{PayTrace::VERSION}"
end

task :default => :test
