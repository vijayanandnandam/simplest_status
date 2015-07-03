module SimplestStatus
  module ModelMethods
    def self.included(base)
      Configurator.new(base).configure
    end

    private

    class Configurator < Struct.new(:model)
      def configure
        model.all_statuses.each do |status|
          set_constant_for status
          define_class_methods_for status
          define_instance_methods_for status
        end

        define_status_label_method
        set_validations
      end

      private

      def set_constant_for(status_info)
        model.send :const_set, status_info.constant_name, status_info.value
      end

      def define_class_methods_for(status_info)
        model.send :define_singleton_method, status_info.symbol do
          where(status_column_name => status_info.value)
        end
      end

      def define_instance_methods_for(status_info)
        define_predicate(status_info)
        define_status_setter(status_info)
      end

      def define_predicate(status_info)
        model.send :define_method, "#{status_info.symbol}?" do
          send(self.class.status_column_name) == status_info.value
        end
      end

      def define_status_setter(status_info)
        model.send :define_method, status_info.symbol do
          update_attributes(self.class.status_column_name => status_info.value)
        end
      end

      def define_status_label_method
        model.send :define_method, :status_label do
          self.class.all_statuses.label_for(status)
        end
      end

      def set_validations
        model.send :validates, model.status_column_name, :presence => true, :inclusion => { :in => proc { model.all_statuses.values } }
      end
    end
  end
end
