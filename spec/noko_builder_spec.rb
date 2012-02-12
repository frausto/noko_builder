require 'spec_helper'

describe NokoBuilder do
  it "should builder xml using the default values" do
    builder = NokoBuilder.new do |xml|
      xml.Sup :default => "yo dawg"
    end
    
    builder.doc.xpath("//Sup").text.should == "yo dawg"
  end
  
  it "should overwrite defaults if specified" do
    builder = NokoBuilder.new(:Sup => "cool story") do |xml|
      xml.Sup :default => "yo dawg"
    end
    
    builder.doc.xpath("//Sup").text.should == "cool story"
  end
  
  it "should use tag value even if there is no default specified" do
    builder = NokoBuilder.new(:Sup => "what up") do |xml|
      xml.Sup
    end
    
    builder.doc.xpath("//Sup").text.should == "what up"
  end
  
  it "should work with nested xml" do
    builder = NokoBuilder.new(:Two => "what up") do |xml|
      xml.Outside do
        xml.One :default => "first"
        xml.Two :default => "second"
      end
    end
    
    builder.doc.xpath("//One").text.should == "first"
    builder.doc.xpath("//Two").text.should == "what up"
  end
  
  it "should work normally like nokogiri builder if given a value no defaults" do
    builder = NokoBuilder.new do |xml|
      xml.Outside do
        xml.One "no def"
      end
    end
    
    builder.doc.xpath("//One").text.should == "no def"
  end
  
  it "should not include tag if not set and no defaults" do
    builder = NokoBuilder.new do |xml|
      xml.One
    end
    
    builder.to_xml.should_not =~ /One/
  end
  
  it "should work with namespacing" do
    builder = NokoBuilder.new do |xml|
      xml.One('xmlns' => 'http://stuff') do
        xml.Inside :default => "namey"
      end
    end
    
    builder.doc.xpath("//ns:Inside", "ns" => "http://stuff").text.should == "namey"
  end
end
