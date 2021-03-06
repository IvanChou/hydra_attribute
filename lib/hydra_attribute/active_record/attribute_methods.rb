module HydraAttribute
  module ActiveRecord
    module AttributeMethods
      extend ActiveSupport::Concern

      # Returns type casted attributes
      #
      # @return [Hash]
      def attributes
        super.merge(hydra_attributes)
      end

      # Returns attributes before type casting
      #
      # @return [Hash]
      def attributes_before_type_cast
        super.merge(hydra_attributes_before_type_cast)
      end

      # Read type cast attribute value by its name
      #
      # @param [String,Symbol] name
      # @return [Hash]
      def read_attribute(name)
        name = name.to_s
        if hydra_attributes.has_key?(name)
          hydra_attributes[name]
        else
          super
        end
      end

      # Assigns attributes to the model
      #
      # @param [Hash] new_attributes
      # @param [Hash] options
      # @return [NilClass]
      def assign_attributes(new_attributes, options = {})
        if new_attributes[:hydra_set_id]
          # set :hydra_set_id attribute as a last attribute to avoid HydraAttribute::HydraSet::MissingAttributeInHydraSetError error
          new_attributes[:hydra_set_id] = new_attributes.delete(:hydra_set_id)
        end
        super
      end

      # Returns the column object for the named attribute.
      #
      # @param [String, Symbol] name
      # @return [ActiveRecord::ConnectionAdapters::Column]
      def column_for_attribute(name)
        hydra_attribute = self.class.hydra_attributes.find { |hydra_attribute| hydra_attribute.name == name.to_s } # TODO should be cached
        if hydra_attribute
          HydraValue.column(hydra_attribute.id)
        else
          super
        end
      end
    end
  end
end