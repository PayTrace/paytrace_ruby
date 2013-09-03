require "bundler/gem_tasks"
require 'rake/testtask'
require 'paytrace_ruby/version'

Rake::TestTask.new do |t|
   t.libs << "paytrace_ruby"
   t.test_files = FileList['test/test*.rb']
   t.verbose = true
end

task :build do 
  system "gem build paytrace_ruby.gemspec"
end

task :release => :build do
  system "gem push paytrace-#{PayTrace::VERSION}"
end

task :default => :test
