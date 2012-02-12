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
    args = update_args(id, args.shift) + args
    args = args.compact.reject(&:blank?)
    
    @xml.send(id, *args, &block) if args.present? || block.present?
  end
  
  private
  
  def update_args(id, first_arg)
    default = @overwrite[id.to_sym]
    return [first_arg] unless default.present?
    first_arg.kind_of?(Hash) ? [default, first_arg] : [default]
  end
end