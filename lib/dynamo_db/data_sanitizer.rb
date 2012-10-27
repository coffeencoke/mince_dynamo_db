module Mince
  module DynamoDb
    module DataSanitizer
      def self.prepare_field_for_storage(field)
        field.is_a?(Numeric) ? field : field.to_s
      end

      def self.prepare_hash_for_storage(hash)
        hash.each{|key, value| hash[key] = prepare_field_for_storage(value) }
      end
    end
  end
end
