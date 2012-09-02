module HydraAttribute
  module HydraAttributeMethods
    extend ActiveSupport::Concern

    module ClassMethods
      extend Memoize

      def hydra_attributes
        HydraAttribute.where(entity_type: base_class.model_name)
      end
      hydra_memoize :hydra_attributes

      def hydra_attribute(identifier)
        hydra_attributes.find do |hydra_attribute|
          hydra_attribute.id == identifier || hydra_attribute.name == identifier
        end
      end
      hydra_memoize :hydra_attribute

      def hydra_attribute_backend_types
        hydra_attributes.map(&:backend_type).uniq
      end
      hydra_memoize :hydra_attribute_backend_types

      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_attribute_#{prefix}s
            hydra_attributes.map(&:#{prefix})
          end
          hydra_memoize :hydra_attribute_#{prefix}s
        EOS
      end

      def hydra_attributes_by_backend_type
        hydra_attributes.group_by(&:backend_type)
      end
      hydra_memoize :hydra_attributes_by_backend_type

      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_attribute_#{prefix}s_by_backend_type
            hydra_attributes.each_with_object({}) do |hydra_attribute, object|
              object[hydra_attribute.backend_type] ||= []
              object[hydra_attribute.backend_type] << hydra_attribute.#{prefix}
            end
          end
          hydra_memoize :hydra_attribute_#{prefix}s_by_backend_type
        EOS
      end

      def hydra_attributes_for_backend_type(backend_type)
        hydra_attributes = hydra_attributes_by_backend_type[backend_type]
        hydra_attributes.nil? ? [] : hydra_attributes
      end

      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_attribute_#{prefix}s_for_backend_type(backend_type)
            values = hydra_attribute_#{prefix}s_by_backend_type[backend_type]
            values.nil? ? [] : values
          end
        EOS
      end

      def clear_hydra_attribute_cache!
        [
          :@hydra_attributes,
          :@hydra_attribute,
          :@hydra_attribute_ids,
          :@hydra_attribute_names,
          :@hydra_attribute_backend_types,
          :@hydra_attributes_by_backend_type,
          :@hydra_attribute_ids_by_backend_type,
          :@hydra_attribute_names_by_backend_type,
        ].each do |variable|
          remove_instance_variable(variable) if instance_variable_defined?(variable)
        end
      end
    end

    def hydra_attribute?(name)
      self.class.hydra_attribute_names.include?(name.to_s)
    end
  end
end