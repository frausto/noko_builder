require 'nokogiri'
require 'active_support/all'

class NokoBuilder
  attr_reader :noko
  delegate *(Nokogiri::XML::Builder.new.methods - Object.new.methods), :to => :noko
  
  def initialize(overwrite={}, noko_options={})
    @overwrite = overwrite
    @noko = Nokogiri::XML::Builder.new(noko_options) do |xml|
      @xml = xml
      yield self
    end
  end
  
  def method_missing(id, *args, &block)
    first_arg = args.shift
    
    default = @overwrite[id.to_sym] || first_arg
    default = args.unshift(default).compact.reject(&:blank?)
    @xml.send(id, *default, &block) if default.present? || block.present?
  end
end