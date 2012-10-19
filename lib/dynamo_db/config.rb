module Mince # :nodoc:
  module DynamoDb # :nodoc:
    require 'singleton'
    require 'aws'

    # = DynamoDb Config
    #
    # Config specifies the configuration settings
    #
    # @author Matt Simpson
    class Config
      include Singleton

      # Returns the primary key identifier for records.  This is necessary because not all databases use the same
      # primary key.
      #
      # @return [Symbol] the name of the primary key field.
      def self.primary_key
        instance.primary_key
      end

      # Returns the secret access key used for authenticating with Amazon's DynamoDB service
      #
      # Can either be set explicitely, or uses AWS.config by default
      def self.secret_access_key
        instance.secret_access_key
      end

      def self.access_key_id
        instance.access_key_id
      end

      attr_reader :primary_key

      def initialize
        @primary_key = :id
      end

      def access_key_id
        AWS.config.access_key_id
      end

      def access_key_id=(id)
        AWS.config.access_key_id = id
      end

      def secret_access_key
        AWS.config.secret_access_key
      end

      def secret_access_key=(key)
        AWS.config.secret_access_key = key
      end
    end
  end
end
