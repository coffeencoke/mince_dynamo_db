require 'singleton'
require 'digest'
require 'active_support/hash_with_indifferent_access'

require_relative 'connection'

module MinceDynamoDb # :nodoc:
  # = Mince DynamoDb Data Store
  #
  # Mince DynamoDb Data Store stores and retrieves data from a DynamoDB table. It supports the same methods
  # as the following libraries:
  #
  # Mince::
  #   A lightweight ruby library to store and retrieve data from MongoDB (https://github.com/asynchrony/mince)
  # HashyDb:: 
  #   A lightweight ruby library to store and retrieve data from a hash in-memory. (https://github.com/asynchrony/hashy_db)
  #
  # Using this library offers more extensibility and growth for your application.  If at any point in time
  # you want to support a different database for all, or even one, of your classes, you only need to implement
  # the few methods defined in this class.
  #
  # You can use the {https://github.com/asynchrony/mince_data_model Mince Data Model} as a helper library to 
  # provide support in writing an application using these data persistance libraries.
  # 
  # To use the Data Store, define your DynamoDB access_key_id and secret_access_key.  If you are using rails
  # you can do this by creating a file at config/aws.yml with the following contents:
  #
  #   development:
  #     access_key_id: REPLACE_WITH_ACCESS_KEY_ID
  #     secret_access_key: REPLACE_WITH_SECRET_ACCESS_KEY
  #    
  # Otherwise, you can set the configurations like so:
  #
  #   require 'aws'
  #
  #   AWS.config.access_key_id = REPLACE_WITH_ACCESS_KEY_ID
  #   AWS.config.secret_access_key = REPLACE_WITH_SECRET_ACCESS_KEY
  #
  # View the aws documentation for more details at http://docs.amazonwebservices.com/AWSRubySDK/latest/frames.html
  #
  # Once you have the settings configured, you can start storing and retrieving data:
  #
  #   data_store = MinceDynamoDb::DataStore.instance
  #   data_store.add 'fruits', id: '1', name: 'Shnawzberry', color: 'redish', quantity: '20'
  #   data_store.get_for_key_with_value 'fruits', :color, 'redish'
  #
  # @author Matt Simpson
  class DataStore
    include Singleton

    # Returns the primary key identifier for records.  This is necessary because not all databases use the same
    # primary key.
    #
    # @return [String] the name of the primary key field.
    def self.primary_key_identifier
      'id'
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
    def add(collection_name, hash)
      hash.delete_if{|k,v| v.nil? }
      items(collection_name).create(hash)
    end

    # Replaces a record in the collection based on the primary key's value.  The hash must contain a key, defined
    # by the +primary_key_identifier+ method, with a value.  If a record in the data store is found with that key and
    # value, the entire record will be replaced with the given hash.
    #
    # @param [String] collection_name the name of the collection
    # @param [Hash] hash a hash to replace the record in the collection with
    def replace(collection_name, hash)
      items(collection_name).put(hash)
    end

    # Not yet implemented
    def update_field_with_value(*args)
      raise %(The method `MinceDynamoDb::DataStore.singleton.update_field_with_value` is not implemented, you should implement it for us!)
    end

    # Gets all records that have the value for a given key.
    #
    # @param [String] collection_name the name of the collection
    # @param [String] key the key, or field, to get a record for
    # @param [*] value the value to get a record for
    # @return [Array] an array of records that match the key and value
    def get_all_for_key_with_value(collection_name, key, value)
      get_by_params(collection_name, key => value)
    end

    # Gets the first record that has the value for a given key.
    #
    # @param [String] collection_name the name of the collection
    # @param [String] key the key to find a record by
    # @param [String] value the value to find a record by
    # @return [Hash] a hash for the record found by the key and value in the collection
    def get_for_key_with_value(collection_name, key, value)
      get_all_for_key_with_value(collection_name, key.to_s, value).first
    end

    # Gets all records that have all of the keys and values in the given hash.
    #
    # @param [String] collection_name the name of the collection
    # @param [Hash] hash a hash to get a record for
    # @return [Array] an array of all records matching the given hash for the collection
    def get_by_params(collection_name, hash)
      hash = HashWithIndifferentAccess.new(hash)
      array_to_hash(items(collection_name).where(hash))
    end

    # Gets all records for a collection
    #
    # @param [String] collection_name the name of the collection
    # @return [Array] all records for the given collection name
    def find_all(collection_name)
      array_to_hash(items(collection_name))
    end

    # Gets a record matching a key and value
    #
    # @param [String] collection_name the name of the collection
    # @param [String] key the key to find a record by
    # @param [*] value a value the find a record by
    # @return [Hash] a record that matches the given key and value
    def find(collection_name, key, value)
      get_for_key_with_value(collection_name, key, value)
    end

    # Pushes a value to a record's key that is an array
    #
    # @param [String] collection_name the name of the collection
    # @param [String] identifying_key the field used to find the record
    # @param [*] identifying_value the value used to find the record
    # @param [String] array_key the field to push an array to
    # @param [*] value_to_push the value to push to the array
    def push_to_array(collection_name, identifying_key, identifying_value, array_key, value_to_push)
      item = items(collection_name).where(identifying_key.to_s => identifying_value).first
      item.attributes.add(array_key => [value_to_push])
    end

    # Removes a value from a record's key that is an array
    #
    # @param [String] collection_name the name of the collection
    # @param [String] identifying_key the field used to find the record
    # @param [*] identifying_value the value used to find the record
    # @param [String] array_key the field to push an array from
    # @param [*] value_to_remove the value to remove from the array
    def remove_from_array(collection_name, identifying_key, identifying_value, array_key, value_to_remove)
      item = items(collection_name).where(identifying_key.to_s => identifying_value).first      
      item.attributes.delete(array_key => [value_to_remove])
    end

    # Returns all records where the given key contains any of the values provided
    #
    # @param [String] collection_name the name of the collection
    # @param [String] key the key to find the record by
    # @param [Array] values an array of values that the record could contain
    # @return [Array] all records that contain any of the values given
    def containing_any(collection_name, key, values)
      array_to_hash items(collection_name).where(key.to_sym).in(values)
    end

    # Returns all records where the given key contains the given value
    #
    # @param [String] collection_name the name of the collection
    # @param [String] key the key to find records by
    # @param [*] value the value to find a record by
    # @return [Array] all records where the key contains the given value
    def array_contains(collection_name, key, value)
      array_to_hash items(collection_name).where(key.to_sym).contains(value)
    end

    # Clears the data store.
    # Mainly used for rolling back the data store in tests.
    def clear
      db.tables.each do |t|
        t.hash_key unless t.schema_loaded? # to load the schema
        t.items.each do |i|
          i.delete
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
    def collection(collection_name)
      db.tables[collection_name.to_s].tap do |c|
        c.hash_key unless c.schema_loaded?
      end
    end

    private

    # Takes a DynamoDB item and returns the attributes of that item as a hash
    def to_hash(item)
      item.attributes.to_h if item
    end

    # Takes an array of DynamoDB items and returns the attributes of each item as a hash.
    # calls 
    def array_to_hash(array)
      array.map{|a| to_hash(a) }
    end

    # Returns the database object which comes from MinceDynamoDb::Connection
    def db
      MinceDynamoDb::Connection.instance.connection
    end

    def collections
      db.tables
    end

    def items(collection_name)
      collection(collection_name).items
    end
  end
end
