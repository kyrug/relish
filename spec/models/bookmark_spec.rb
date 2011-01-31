require File.dirname(__FILE__) + '/../spec_helper'

describe Bookmark do
  
    before(:each) do
      @user = User.new(:email=>'creighton.medley@gmail.com', :display_name=>'cmed')
      @bookmark = Bookmark.new(
        :title => "Sample title",
        :url => "http://www.mercurygrove.com",
        :tags => ["consulting", "development"]
      )
      @user.bookmarks << @bookmark
    end
  
    it "should be valid" do
      @bookmark.should be_valid
    end
    
    it "should be associated to a master url" do
      @bookmark.master.should be_valid
    end
    
    it "should have the same url as the master url" do
      @bookmark.url.should == @bookmark.master.url
    end
  
    it "should push tags to the master" do
      @bookmark.tags.should == @bookmark.master.tags
    end
        
    it "should generate a hotness score on the url" do
      @bookmark.master.hotness.should be > 0
    end
    
    it "should increment the total saves on master" do
      @bookmark.master.total_saves.should be > 0
    end
    
    it "should decrement the total saves on master when bookmark is destroyed" do
      master = @bookmark.master
      @bookmark.destroy
      master.reload.total_saves.should be == 0
    end
    
    after(:each) do
      User.delete_all
      Bookmark.delete_all
      Url.delete_all
    end
  
end