require 'nokogiri'
require 'active_support/all'

class NokoBuilder
  attr_reader :noko
  delegate *((Nokogiri::XML::Builder.new.methods - Object.new.methods).push(:to => :noko))
  
  def initialize(overwrite={}, noko_options={})
    @overwrite = overwrite
    @noko = Nokogiri::XML::Builder.new(noko_options) do |xml|
      @xml = xml
      yield self
    end
  end
  
  def method_missing(id, *args, &block)
    args = update_value(id, args)
    args = update_attributes(id, args)
    args = args.compact.reject(&:blank?)
    
    @xml.send(id, *args, &block) if args.present? || block.present?
  end
  
  private
  
  def update_value(id, args)
    first_arg = args.shift
    value = @overwrite[id.to_sym]
    
    if value.present?
      first_arg = first_arg.kind_of?(Hash) ? [value, first_arg] : [value]
    end
    
    [first_arg].flatten + args
  end
  
  def update_attributes(id, args)
    attributes = @overwrite["#{id}_nattr".to_sym]
    return args unless attributes.present?
    
    args.map do |arg|
      arg.kind_of?(Hash) ? arg.merge(attributes) : arg
    end
  end
end