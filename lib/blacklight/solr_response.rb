class Blacklight::SolrResponse < HashWithIndifferentAccess

  require  'blacklight/solr_response/pagination_methods'

  require 'blacklight/solr_response/response'
  require 'blacklight/solr_response/spelling'
  require 'blacklight/solr_response/facets'
  require 'blacklight/solr_response/more_like_this'
  autoload :GroupResponse, 'blacklight/solr_response/group_response'
  autoload :Group, 'blacklight/solr_response/group'

  include PaginationMethods
  include Spelling
  include Facets
  include Response
  include MoreLikeThis

  attr_reader :request_params
  attr_accessor :document_model

  def initialize(data, request_params, options = {})
    super(force_to_utf8(data))
    @request_params = request_params
    self.document_model = options[:solr_document_model] || options[:document_model] || SolrDocument
  end

  def header
    self['responseHeader']
  end
  
  def update(other_hash) 
    other_hash.each_pair { |key, value| self[key] = value } 
    self 
  end 

  def params
      (header and header['params']) ? header['params'] : request_params
  end

  def rows
      params[:rows].to_i
  end

  def sort
    params[:sort]
  end

  def docs
    @docs ||= begin
      response['docs'] || []
    end
  end
  
  def documents
    docs.collect{|doc| document_model.new(doc, self) }
  end

  def grouped
    @groups ||= self["grouped"].map do |field, group|
      # grouped responses can either be grouped by:
      #   - field, where this key is the field name, and there will be a list
      #        of documents grouped by field value, or:
      #   - function, where the key is the function, and the documents will be
      #        further grouped by function value, or:
      #   - query, where the key is the query, and the matching documents will be
      #        in the doclist on THIS object
      if group["groups"] # field or function
        GroupResponse.new field, group, self
      else # query
        Group.new field, group, self
      end
    end
  end

  def group key
    grouped.select { |x| x.key == key }.first
  end

  def grouped?
    self.has_key? "grouped"
  end

  def export_formats
    documents.map { |x| x.export_formats.keys }.flatten.uniq
  end

  private

    def force_to_utf8(value)
      case value
      when Hash
        value.each { |k, v| value[k] = force_to_utf8(v) }
      when Array
        value.each { |v| force_to_utf8(v) }
      when String
        value.force_encoding("utf-8")  if value.respond_to?(:force_encoding) 
      end
      value
    end
end
