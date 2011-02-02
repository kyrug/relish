require File.dirname(__FILE__) + '/../spec_helper'

describe Url do
  
  describe "Creating a new url" do
    before(:each) do 
      @url = Url.new(
          :url=>"http://test.com",
          :total_saves => 3,
          :created_at => Time.now
       )
       @url.generate_hotness
    end
   
    it "should be valid" do
      @url.should be_valid
    end
    
    it "should have total saves count" do
      @url.total_saves.should be > 0
    end
    
    it "should have a hotness score" do
      @url.hotness.should be > 0
    end
    
    after(:each) do
      Url.delete_all
    end
  
  end

  
end