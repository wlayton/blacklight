module Blacklight::ServiceControllerShim

  extend ActiveSupport::Concern
    def blacklight_service
      @service ||= begin
        s = Blacklight::Service.new self, params
    
        self.class.blacklight_service_configuration.each do |(args, block)| 
          s.configure_blacklight *args, &block
        end
        s
      end
    end

    def blacklight_service= blacklight_service
      @service = blacklight_service
    end

    def blacklight_config
      blacklight_service.config
    end

    def get_search_results *args
      blacklight_service.get_search_results *args
    end

    def get_solr_response_for_doc_id *args
      blacklight_service.get_solr_response_for_doc_id *args
    end

    def get_facet_pagination *args
      blacklight_service.get_facet_pagination *args
    end

    def get_solr_response_for_field_values *args
      blacklight_service.get_solr_response_for_field_values *args
    end

    def get_opensearch_response *args
      blacklight_service.get_opensearch_response *args
    end

    def facet_limit_for *args
      blacklight_service.facet_limit_for *args
    end

    def configure_blacklight(*args, &block)
      blacklight_service.configure(*args, &block)
    end

    included do
      class_attribute :blacklight_service_configuration

      self.blacklight_service_configuration = []

      helper_method :facet_limit_for if respond_to? :helper_method
    end

    module ClassMethods

      def configure_blacklight(*args, &block)
        self.blacklight_service_configuration << [args, block]
        @service = nil
      end

      def copy_blacklight_config_from controller
        self.blacklight_service_configuration = controller.blacklight_service_configuration.dup
        @service = nil
      end

      def blacklight_service
        @service ||= begin
          s = Blacklight::Service.new nil

          self.blacklight_service_configuration.each do |(args, block)| 
            s.configure_blacklight *args, &block
          end
          s
        end
      end

      def blacklight_config
        blacklight_service.config
      end

    end

    def blacklight_solr
      blacklight_service.solr
    end

    def blacklight_solr_config
      blacklight_service.solr_config
    end
end