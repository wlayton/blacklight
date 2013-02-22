class Blacklight::Service

  include Blacklight::Configurable
  include Blacklight::SolrHelper

  def initialize controller_context = nil, params = {}, &block
  	@context = controller_context
    @params = params
    configure_blacklight &block if block_given?
  end

  def config
    blacklight_config
  end

  def solr
    @solr ||= RSolr.connect(solr_config)
  end
  alias_method :blacklight_solr, :solr

  def solr_config
    Blacklight.solr_config
  end

  protected
  def context
  	@context
  end

  def params
    @params
  end
end