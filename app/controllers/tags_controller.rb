class TagsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  load_and_authorize_resource :find_by => :name

  rescue_from ActiveRecord::RecordNotFound, :with => :no_bookmarks_for_tag

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  def show
    @bookmarks = @tag.taggings.collect { |tagging|   
      Bookmark.find(tagging.taggable_id)
    }
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end
  
  def no_bookmarks_for_tag
    render "bookmarks/_no_bookmarks"
  end
end