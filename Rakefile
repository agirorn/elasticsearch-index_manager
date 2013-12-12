require "bundler/gem_tasks"
require 'rake/testtask'

namespace :esi do
  desc "Reinstall elasticsearch"
  task :reinstall do
    if Dir.exists?('elasticsearch')
      sh "rm -Rf elasticsearch"
    end
    Rake::Task["es:install"].invoke
  end

  desc "Install elasticsearch"
  task :install do
    base = 'elasticsearch-0.90.7'
    elasticsearch_url = "https://download.elasticsearch.org/elasticsearch/elasticsearch/#{base}.tar.gz"

    sh "curl -L -# -o #{base}.tar.gz #{elasticsearch_url}" and
    sh "tar -zxf #{base}.tar.gz" and
    sh "rm -f #{base}.tar.gz" and
    sh "mv #{base} elasticsearch"
  end

  desc "Start elasticsearch"
  task :start, [:count] do |t, args|
    count = (args[:count] || 1).to_i
    from = Dir['elasticsearch/elasticsearch.*.pid'].length + 1

    to = (from + count - 1)
    (from..to).each do |index|
      index = "%03d" % index
      sh "cd elasticsearch && bin/elasticsearch -p elasticsearch.#{index}.pid"
    end
  end

  desc "Start elasticsearch"
  task :stop do |t, args|
    pid_files = Dir['elasticsearch/elasticsearch.*.pid']
    if pid_files.length < 1
      raise <<-MESSGE.gsub(/^\s+/, '')
        ###########################################
        No server is running......
        ###########################################
        MESSGE
    end
    sh "kill `cat #{pid_files.last}`"
  end

  namespace :stop do
    task :all do
      Dir['elasticsearch/elasticsearch.*.pid'].each do |pid_file|
        sh "kill `cat #{pid_file}`"
      end
    end
  end
end

desc 'Start Elasticsearch'
task :esi => ["es:start"]

desc "MiniTest Spec"
Rake::TestTask.new do |t|
  # t.libs    << 'lib' << 'test'
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = true
end

desc "Runa all specs for the project same as :test"
task :spec => :test

task :default => :test

