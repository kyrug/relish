require File.dirname(__FILE__) + '/../spec_helper'

describe Bookmark do
  
    before(:each) do
      @user = User.new(:email=>'test@test.com', :display_name=>'test')
      @bookmark = Bookmark.new(
        :title => "Sample title",
        :url => "http://test.com",
        :tags => %w[consulting development]
      )
      @user.bookmarks << @bookmark
      @bookmark.reload
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
      @bookmark.destroy
      Url.first(@bookmark.url).total_saves.should be == 0
    end
    
    it "should not be associated to a master when marked private" do
      @bookmark.private = true
      @bookmark.save
      @bookmark.master.should be_nil
    end
    
    it "should not be associated to a master when created as a private bookmark" do
      @bookmark2 = Bookmark.new(
        :title => "Sample title",
        :url => "http://test2.com",
        :tags => %w[consulting development],
        :private=>true
      )
      @user.bookmarks << @bookmark2
      Url.first(:url=>@bookmark2.url).should be_nil
    end
    
    it "should decrement the total saves on master when marked private" do
      @bookmark.private = true
      @bookmark.save
      Url.first(:url=>@bookmark.url).total_saves.should be == 0
    end
    
    it "should increment the total saves when marked public" do
      @user2 = User.new(
        :email=>'test2@test.com', 
        :display_name=>'test')
        
      @bookmark = Bookmark.new(
        :title => "Some other title", 
        :url => "http://test.com", 
        :private=>:false)
        
      @user2.bookmarks << @bookmark
      Url.first(:url=>@bookmark.url).total_saves.should be == 2
    end
    
    it "should remove tags on master created by user when marked private" do
      @bookmark.tags <<  %w[monday tuesday thursday wednesday friday sunday saturday]
      @bookmark.private = true
      @bookmark.save
      Url.first(:url=>@bookmark.url).tags.should be_empty
    end
    
    after(:each) do
      User.delete_all
      Bookmark.delete_all
      Url.delete_all
    end
  
end