require "simplest_status/version"

module SimplestStatus
  autoload :StatusCollection, 'simplest_status/status_collection'
  autoload :ModelMethods,     'simplest_status/model_methods'

  def statuses(*status_list)
    if status_list.last.is_a?(Hash)
      options = status_list.pop
      @status_column_name = options[:column_name]
      @start_index = options[:index_start]
    end

    @status_column_name ||= :status
    @statuses ||= status_list.reduce(StatusCollection.new) do |collection, status|
      collection.add(status)
    end

    send :define_singleton_method, :all_statuses do
      @statuses
    end

    send :define_singleton_method, :status_column_name do
      @status_column_name
    end

    send(:include, ModelMethods) unless ancestors.include? ModelMethods

    @statuses
  end
end
