require 'spec_helper'

describe NokoBuilder do
  describe "element value" do
    it "should builder xml using the default values" do
      builder = NokoBuilder.new do |xml|
        xml.Sup "yo dawg"
      end
    
      builder.doc.xpath("//Sup").text.should == "yo dawg"
    end
  
    it "should overwrite defaults if specified" do
      builder = NokoBuilder.new(:Sup => "cool story") do |xml|
        xml.Sup "yo dawg"
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
          xml.One "first"
          xml.Two "second"
        end
      end
    
      builder.doc.xpath("//One").text.should == "first"
      builder.doc.xpath("//Two").text.should == "what up"
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
          xml.Inside "namey"
        end
      end
    
      builder.doc.xpath("//ns:Inside", "ns" => "http://stuff").text.should == "namey"
    end
  
    it "should be able to pass options to nokogiri builder" do
      builder = NokoBuilder.new({},{:encoding => 'UTF-8'}) do |xml|
        xml.One('xmlns' => 'http://stuff') do
          xml.Inside "namey"
        end
      end

      builder.to_xml.should =~ /\<\?xml version="1.0" encoding="UTF-8"\?\>/
    end
  end
  
  describe "attributes" do
    it "should work normally like nokogiri builder with attributes" do
      builder = NokoBuilder.new do |xml|
        xml.Outside do
          xml.One "no def", :attr => "cool"
        end
      end

      builder.doc.xpath("//One").attr('attr').text.should == "cool"
    end

    it "should keep attributes even if text value is being overwritten" do
      builder = NokoBuilder.new(:One => "over") do |xml|
        xml.Outside do
          xml.One "no def", :attr => "cool"
        end
      end

      builder.doc.xpath("//One").text.should == "over"
      builder.doc.xpath("//One").attr('attr').text.should == "cool"
    end
    
    it "should keep attributes even if text value is being overwritten from blank" do
      builder = NokoBuilder.new(:One => "over") do |xml|
        xml.Outside do
          xml.One :attr => "cool"
        end
      end

      builder.doc.xpath("//One").text.should == "over"
      builder.doc.xpath("//One").attr('attr').text.should == "cool"
    end
    
    it "should overwrite attributes" do
      builder = NokoBuilder.new(:One_nattr => {:another => 'awesome'}) do |xml|
        xml.Outside do
          xml.One :attr => "cool", :another => "beans"
        end
      end

      builder.doc.xpath("//One").attr('attr').text.should == "cool"
      builder.doc.xpath("//One").attr('another').text.should == "awesome"
    end
    
    it "should add attributes" do
      builder = NokoBuilder.new(:One_nattr => {:another => 'awesome', :newone => 'new'}) do |xml|
        xml.Outside do
          xml.One :another => "beans"
        end
      end

      builder.doc.xpath("//One").attr('newone').text.should == "new"
      builder.doc.xpath("//One").attr('another').text.should == "awesome"
    end
    
    it "should overwrite attributes and value" do
      builder = NokoBuilder.new(:One => "test", :One_nattr => {:another => 'awesome'}) do |xml|
        xml.Outside do
          xml.One :attr => "cool", :another => "beans"
        end
      end

      builder.doc.xpath("//One").attr('attr').text.should == "cool"
      builder.doc.xpath("//One").attr('another').text.should == "awesome"
      builder.doc.xpath("//One").text.should == "test"
    end
    
    it "should overwrite attributes and value when having a default value" do
      builder = NokoBuilder.new(:One => "test", :One_nattr => {:another => 'awesome'}) do |xml|
        xml.Outside do
          xml.One "testinit", :attr => "cool", :another => "beans"
        end
      end

      builder.doc.xpath("//One").attr('attr').text.should == "cool"
      builder.doc.xpath("//One").attr('another').text.should == "awesome"
      builder.doc.xpath("//One").text.should == "test"
    end

    it "should overwrite attributes when having a default value" do
      builder = NokoBuilder.new(:One_nattr => {:another => 'awesome'}) do |xml|
        xml.Outside do
          xml.One "def", :attr => "cool", :another => "beans"
        end
      end

      builder.doc.xpath("//One").attr('attr').text.should == "cool"
      builder.doc.xpath("//One").attr('another').text.should == "awesome"
      builder.doc.xpath("//One").text.should == "def"
    end
  end
end
