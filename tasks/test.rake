require 'rake/testtask'

desc "MiniTest Spec"
Rake::TestTask.new do |t|
  # t.libs    << 'lib' << 'test'
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = true
end

desc "Runa all specs for the project same as :test"
task :spec => :test
