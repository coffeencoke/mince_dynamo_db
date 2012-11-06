module MinceDynamoDb # :nodoc:
  require 'digest'
  require 'active_support/hash_with_indifferent_access'
  require_relative 'data_store'
  require_relative 'data_sanitizer'
  require_relative 'config'

  module Interface
    # Not yet implemented
    def self.update_field_with_value(collection_name, primary_key_value, field_name, new_value)
      item = find(collection_name, primary_key_identifier, primary_key_value)
      item.set(field_name => new_value)
    end

    def self.delete_field(collection_name, field)
      raise %(The method `MinceDynamoDb::DataStore.singleton.delete_field` is not implemented, you should implement it for us!)
    end

    def self.delete_collection(collection_name)
      raise %(The method `MinceDynamoDb::DataStore.singleton.delete_collection` is not implemented, you should implement it for us!)
    end

    def self.increment_field_by_amount(collection_name, id, field_name, amount)
      raise %(The method `MinceDynamoDb::DataStore.singleton.increment_field_by_amount` is not implemented, you should implement it for us!)
    end

    def self.create_collection(collection_name, read_rate=10, write_rate=5)
      collections.create(collection_name, read_rate, write_rate)
    end

    def self.collection_status(collection_name)
      collection(collection_name).status
    end

    # Returns the primary key identifier for records.  This is necessary because not all databases use the same
    # primary key.
    #
    # @return [String] the name of the primary key field.
    def self.primary_key_identifier
      Config.primary_key
    end

    # Generates a unique ID for a database record
    #
    # @note This is necessary because different databases use different types of primary key values. Thus, each mince
    #       implementation must define how to generate a unique id.
    #
    # @param [#to_s] salt any object that responds to #to_s
    # @return [String] A unique id based on the salt and the current time
    def self.generate_unique_id(salt)
      Digest::SHA256.hexdigest("#{Time.current.utc}#{salt}")[0..6]
    end

    # Inserts one record into a collection.
    #
    # @param [String] collection_name the name of the collection
    # @param [Hash] hash a hash of data to be added to the collection
    def self.add(collection_name, hash)
      hash.delete_if{|k,v| v.nil? }
      items(collection_name).create(sanitized_hash(hash))
    end

    # Replaces a record in the collection based on the primary key's value.  The hash must contain a key, defined
    # by the +primary_key_identifier+ method, with a value.  If a record in the data store is found with that key and
    # value, the entire record will be replaced with the given hash.
    #
    # @param [String] collection_name the name of the collection
    # @param [Hash] hash a hash to replace the record in the collection with
    def self.replace(collection_name, hash)
      items(collection_name).put(sanitized_hash(hash))
    end

    # Gets all records that have the value for a given key.
    #
    # @param [String] collection_name the name of the collection
    # @param [String] key the key, or field, to get a record for
    # @param [*] value the value to get a record for
    # @return [Array] an array of records that match the key and value
    def self.get_all_for_key_with_value(collection_name, key, value)
      get_by_params(collection_name, key => value)
    end

    # Gets the first record that has the value for a given key.
    #
    # @param [String] collection_name the name of the collection
    # @param [String] key the key to find a record by
    # @param [String] value the value to find a record by
    # @return [Hash] a hash for the record found by the key and value in the collection
    def self.get_for_key_with_value(collection_name, key, value)
      get_all_for_key_with_value(collection_name, key.to_s, value).first
    end

    # Gets all records that have all of the keys and values in the given hash.
    #
    # @param [String] collection_name the name of the collection
    # @param [Hash] hash a hash to get a record for
    # @return [Array] an array of all records matching the given hash for the collection
    def self.get_by_params(collection_name, hash)
      hash = HashWithIndifferentAccess.new(hash)
      array_to_hash(items(collection_name).where(hash).select)
    end

    # Gets all records for a collection
    #
    # @param [String] collection_name the name of the collection
    # @return [Array] all records for the given collection name
    def self.find_all(collection_name)
      array_to_hash(items(collection_name).select)
    end

    # Gets a record matching a key and value
    #
    # @param [String] collection_name the name of the collection
    # @param [String] key the key to find a record by
    # @param [*] value a value the find a record by
    # @return [Hash] a record that matches the given key and value
    def self.find(collection_name, key, value)
      get_for_key_with_value(collection_name, key, value)
    end

    # Pushes a value to a record's key that is an array
    #
    # @param [String] collection_name the name of the collection
    # @param [String] identifying_key the field used to find the record
    # @param [*] identifying_value the value used to find the record
    # @param [String] array_key the field to push an array to
    # @param [*] value_to_push the value to push to the array
    def self.push_to_array(collection_name, identifying_key, identifying_value, array_key, value_to_push)
      item = items(collection_name).where(identifying_key.to_s => identifying_value).first
      item.attributes.add(array_key => [sanitized_field(value_to_push)])
    end

    # Removes a value from a record's key that is an array
    #
    # @param [String] collection_name the name of the collection
    # @param [String] identifying_key the field used to find the record
    # @param [*] identifying_value the value used to find the record
    # @param [String] array_key the field to push an array from
    # @param [*] value_to_remove the value to remove from the array
    def self.remove_from_array(collection_name, identifying_key, identifying_value, array_key, value_to_remove)
      item = items(collection_name).where(identifying_key.to_s => identifying_value).select.first      
      item.attributes.delete(array_key => [value_to_remove])
    end

    # Returns all records where the given key contains any of the values provided
    #
    # @param [String] collection_name the name of the collection
    # @param [String] key the key to find the record by
    # @param [Array] values an array of values that the record could contain
    # @return [Array] all records that contain any of the values given
    def self.containing_any(collection_name, key, values)
      array_to_hash items(collection_name).where(key.to_sym).in(values).select
    end

    # Returns all records where the given key contains the given value
    #
    # @param [String] collection_name the name of the collection
    # @param [String] key the key to find records by
    # @param [*] value the value to find a record by
    # @return [Array] all records where the key contains the given value
    def self.array_contains(collection_name, key, value)
      array_to_hash items(collection_name).where(key.to_sym).contains(value).select
    end

    # Deletes a record that matches the given criteria from the data store.
    def self.delete_by_params(collection_name, params)
      item = items(collection_name).where(params).select.first
      item.delete
    end

    # Clears the data store.
    # Mainly used for rolling back the data store in tests.
    def self.clear
      db.tables.each do |t|
        t.hash_key unless t.schema_loaded? # to load the schema
        t.items.each do |i|
          i.delete
        end
      end
    end

    def self.set_data(data)
      clear

      data.each do |key, records|
        records.each do |record|
          add key, record
        end
      end
    end

    # Returns the collection, or table, for a given collection name
    # 
    # The schema must be loaded before any queries are made against a collection
    # There are a couple ways to do this, from digging in their documentation about
    # this topic.  One is to have the schema loaded in memory, which is not recommended
    # for production code, the other way is to call hash_key :) not sure why this works.
    #
    # @param [String] collection_name the name of the collection
    # @return [AWS::DynamoDB::Table] the AWS::DynamoDB::Table for the given collection_name
    def self.collection(collection_name)
      DataStore.collection(collection_name)
    end

    def self.sanitized_field(field)
      DataSanitizer.prepare_field_for_storage(field)
    end

    def self.sanitized_hash(hash)
      DataSanitizer.prepare_hash_for_storage(hash)
    end

    # Takes a DynamoDB item and returns the attributes of that item as a hash
    def self.to_hash(item)
      item.attributes if item
    end

    # Takes an array of DynamoDB items and returns the attributes of each item as a hash.
    # calls 
    def self.array_to_hash(array)
      array.map{|a| to_hash(a) }
    end

    # Returns the database object which comes from MinceDynamoDb::Connection
    def self.db
      DataStore.db
    end

    def self.collections
      DataStore.collections
    end

    def self.items(collection_name)
      DataStore.items(collection_name)
    end
  end
end
