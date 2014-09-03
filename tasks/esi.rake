require 'active_support/core_ext/string/inflections'

def install_elasticsearch_plugin(plugin, dir)
  dir = dir.to_s
  name = dir.titlecase

  unless Dir.exists?("elasticsearch")
    raise "Can't install Inquisitor when ther is no elasticsearch server"
  end

  if Dir.exists?("elasticsearch/plugins/" + dir )
    raise "#{name} in allready installed."
  end

  puts "Installing #{name}...."
  sh "elasticsearch/bin/plugin -install #{plugin}"
end

def open_plugin(plugin)
  if !Dir.exists?("elasticsearch/plugins/" + plugin )
    raise "Can't open #{plugin} sins it dose not exits"
  end

  system "open http://localhost:9200/_plugin/#{plugin}/"
end

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


  namespace :plugin do
    namespace :inquisitor do
      desc "Install the Inquisitor plugin"
      task :install do
        install_elasticsearch_plugin 'polyfractal/elasticsearch-inquisitor', :inquisitor
      end

      task :open do
        open_plugin('inquisitor')
      end
    end
    desc "Open the Inquisitor plugin in browser"
    task :inquisitor => ["esi:plugin:inquisitor:open"]

    namespace :bigdesk do
      desc "Install the BigDesk plugin"
      task :install do
        install_elasticsearch_plugin 'lukas-vlcek/bigdesk', :bigdesk
      end

      task :open do
        open_plugin('bigdesks')
      end
    end
    desc "Open the BigDesk plugin in browser"
    task :bigdesk => ["esi:plugin:bigdesk:open"]

    namespace :head do
      desc "Install the Head plugin"
      task :install do
        install_elasticsearch_plugin 'mobz/elasticsearch-head', :head
      end

      task :open do
        open_plugin('head')
      end
    end
    desc "Open the Head plugin in browser"
    task :head => ["esi:plugin:head:open"]

    namespace :hammer do
      desc "Install the Hammer plugin"
      task :install do
        install_elasticsearch_plugin 'andrewvc/elastic-hammer', 'elastic-hammer'
      end

      task :open do
        open_plugin('elastic-hammer')
      end
    end
    desc "Open the Hammer plugin in browser"
    task :hammer => ["esi:plugin:hammer:open"]


  end
end


desc 'Start Elasticsearch'
task :esi => ["esi:start"]


