# SRP: Model with implementation on how to store each collection in a data store
require 'singleton'
require 'digest'

require_relative 'connection'

module MinceDynamoDb
  class DataStore
    include Singleton

    # Returns the primary key identifier for records.  This is necessary because not all databases use the same
    # primary key.
    def self.primary_key_identifier
      'id'
    end

    # Returns a unique id
    #
    # To ensure uniqueness, provide a salt.  The salt can be any ruby object that responds to +to_s+
    #
    #   some_model = MyModel.new extra_spicy: true
    #   MinceDynamoDb.generate_unique_id some_model
    #
    # This is necessary because different databases use different types of primary key values. Thus, each mince
    # implementation must define how to generate a unique id.
    def self.generate_unique_id(salt)
      Digest::SHA256.hexdigest("#{Time.current.utc}#{salt}")[0..6]
    end

    # Inserts one record into a collection.
    #
    #   MinceDynamoDb::DataStore.instance.add 'fruits', id: '1', name: 'Shnawzberry', color: 'redish', quantity: '20'
    #
    # This will add the hash into the fruits data store collection.
    def add(collection_name, hash)
      hash.delete_if{|k,v| v.nil? }
      collection(collection_name).items.create(hash)
    end


    # Replaces a record in the collection based on the primary key's value.  The hash must contain a key, defined
    # by the +primary_key_identifier+ method, with a value.  If a record in the data store is found with that key and
    # value, the entire record will be replaced with the given hash.
    #
    #   MinceDynamoDb::DataStore.instance.replace 'fruits', id: '1', name: 'Snazzyberry', color: 'redlike', quantity: '23'
    #
    # Replaces the fruit record with a primary key of 1, in the fruits collection, with the new hash.
    def replace(collection_name, hash)
      collection(collection_name).items.put(hash)
    end

    # Gets all records that have the value for a given key.
    #
    #   MinceDynamoDb::DataStore.instance.get_all_for_key_with_value 'fruits', :color, 'redish'
    #
    # Gets all fruit records where the color is redish
    def get_all_for_key_with_value(collection_name, key, value)
      get_by_params(collection_name, key => value)
    end

    # Gets the first record that has the value for a given key.
    #
    #   MinceDynamoDb::DataStore.instance.get_for_key_with_value 'fruits', :color, 'redish'
    #
    # Gets the first fruit record where the color is redish
    def get_for_key_with_value(collection_name, key, value)
      get_all_for_key_with_value(collection_name, key.to_s, value).first
    end

    # Gets all records that have all of the keys and values in the given hash.
    #
    #   MinceDynamoDb::DataStore.instance.get_by_params 'fruits', color: 'redish', quantity: 20
    #
    # Gets all fruit records that have a quantity of 20 and a redish color.
    def get_by_params(collection_name, hash)
      hash = HashWithIndifferentAccess.new(hash)
      array_to_hash(collection(collection_name).items.where(hash))
    end

    # Gets all records
    #
    #   MinceDynamoDb::DataStore.instance.find_all 'fruits'
    #
    # Gets all fruit records
    def find_all(collection_name)
      array_to_hash(collection(collection_name).items)
    end

    # Gets a record
    #
    #   MinceDynamoDb::DataStore.instance.find 'fruits', 'id', '1'
    #
    # Gets the fruit record with an id of 1
    #
    # Todo: make this only receive 2 arguments: collection name and value, use the +primary_key_identifier+
    def find(collection_name, key, value)
      get_for_key_with_value(collection_name, key, value)
    end

    # Pushes a value to a record's key that is an array
    #
    #   MinceDynamoDb::DataStore.instance.push_to_array 'posts', :id, 1, :comment_ids, 4
    #
    # Adds the comment with an id of 4 to the comments array for the post with an id of 1.
    def push_to_array(collection_name, identifying_key, identifying_value, array_key, value_to_push)
      item = get_for_key_with_value(collection_name, identifying_key, identifying_value)
      item.attributes.add(array_key => [value_to_push])
    end

    # Removes a value from a record's key that is an array
    #
    #   MinceDynamoDb::DataStore.instance.remove_from_array 'posts', :id, 1, :comment_ids, 4
    #
    # Removes the comment with an id of 4 from the comments array for the post with an id of 1.
    def remove_from_array(collection_name, identifying_key, identifying_value, array_key, value_to_remove)
      item = get_for_key_with_value(collection_name, identifying_key, identifying_value)
      item.attributes.delete(array_key => [value_to_remove])
    end

    # Returns all records where the given key contains any of the values provided
    #
    #   MinceDynamoDb::DataStore.instance.containing_any 'posts', :tags, ['helpful','new','rails','mince']
    #
    # Returns all posts that have a tag helpful, new, rails, or mince.
    def containing_any(collection_name, key, values)
      array_to_hash collection(collection_name).items.where(key.to_sym).in(values)
    end

    # Returns all records where the given key contains the given value
    #
    #   MinceDynamoDb::DataStore.instance.array_contains 'posts', :tags, 'new'
    #
    # Returns all posts tagged as new.
    #
    # todo: why use key.to_s here?
    def array_contains(collection_name, key, value)
      array_to_hash collection(collection_name).items.where(key.to_sym).contains(value)
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

    # Returns the collection
    def collection(collection_name)
      db.tables[collection_name.to_s].tap do |c|
        c.hash_key unless c.schema_loaded? # to load the schema
      end
    end

    # Returns the database object
    def db
      MinceDynamoDb::Connection.instance.connection
    end

    def to_hash(item)
      item.attributes.to_h if item
    end

    def array_to_hash(array)
      array.map{|a| to_hash(a) }
    end
  end
end
