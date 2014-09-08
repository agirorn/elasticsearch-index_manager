require 'active_support/core_ext/hash/deep_merge'
require 'elasticsearch/index_manager/ext/hash'

module Elasticsearch
  module IndexManager
    class Manager
      attr_reader :indices
      attr_reader :timestamp
      attr_reader  :scroll_timeout

      def initialize(options = {})
        @timestamp = options[:timestamp] || DateTime.now
        @indices = Hash.new {|hash, key| hash[key] = Hash.new }
        @scroll_timeout = '10m'
      end

      # Defines the index and mappings.
      def index(name, options)
        options.stringify_keys_and_symbol_values_recursively!
        indices[name].deep_merge! options
      end

      def migrate
        indices.keys.each do |read_alias|
          write_alias = "#{read_alias}_write"
          options = indices[read_alias]
          new_index = timestamped_index_name(read_alias)

          if alias_exists?(read_alias)
            old_index = get_alias_index_name(read_alias)

            old_options = get_old_options_for(old_index)
            if with_missing_defaults(options) != with_out_garbage( old_options )
              create_index(new_index, options)

              swap_alias write_alias, old_index, new_index
              reindex_data read_alias, write_alias
              swap_alias read_alias, old_index, new_index

              delete_index old_index
            end
          else
            create_index new_index, options
            add_alias read_alias, new_index
            add_alias write_alias, new_index
          end
        end
      end

      private

      def client
        @client ||= Elasticsearch::Client.new
      end

      def timestamped_index_name(name)
        name.to_s + timestamp.strftime('__%Y-%m-%d__%H-%M-%S')
      end

      def get_settings_for(index)
        if client.indices.exists index: index
          client.indices.get_settings[index]
        else
          {}
        end
      end

      def create_index(name, options)
        client.indices.create index: name, body: options
      end

      def swap_alias(name, old_index, new_index)
        client.indices.update_aliases body: {
          actions: [
            { remove: { index: old_index, alias:  name } },
            { add:    { index: new_index, alias:  name } }
          ]
        }
      end

      def add_alias(alias_name, index_name)
        client.indices.update_aliases body: {
          actions: [
            { add:    { index: index_name, alias:  alias_name } }
          ]
        }
      end

      def delete_index(index)
         client.indices.delete index: index
      end

      def get_mapping
        client.indices.get_mapping
      end

      def get_alias_index_name(name)
        client.indices.get_alias(name: name).keys.first
      end

      def get_old_options_for(index)
        options = {
          "mappings" => get_mapping[index]
        }.merge( get_settings_for index )

        # Cleanupt missing things
        settings = options["settings"]
        if settings
          settings.delete "index.version.created"
          settings.delete "index.uuid"
        end

        return options
      end

      def alias_exists?(name)
        client.indices.exists_alias name: name
      end

      def with_out_garbage( options )
        if options.include? "settings"
          settings = options["settings"]
          if settings.include? "index"
            index = settings["index"]
            if index.include? "version"
              index.delete "version"
            end
            if index.include? "uuid"
              index.delete "uuid"
            end
          end
        end

        options
      end

      def with_missing_defaults( options )
        options = options.dup
        settings = options["settings"] ||= Hash.new

        index = settings["index"] ||= Hash.new

        index["number_of_shards"] ||= "5"
        index["number_of_replicas"] ||= "1"

        options["mappings"] = { "mappings" => options["mappings"] }
        return options
      end

      def reindex_data(read_alias, write_alias)
        client.indices.refresh index: read_alias
        result = client.search index: read_alias, size: 2, scroll: scroll_timeout , q: '*'
        until result['hits']['hits'].empty?
          body = result["hits"]["hits"].collect do |item|
            { create:  {
                _index: write_alias,
                _type:  item['_type'],
                _id:    item['_id'],
                data:   item['_source']
              }
            }
          end
          client.bulk body: body

          result = client.scroll scroll: scroll_timeout, scroll_id: result['_scroll_id']
        end
      end

    end
  end
end
