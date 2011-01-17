class TagsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]

  def index
    @tags = Tag.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  def show
    @tag = Tag.find_by_name(params[:id])
    
    @bookmarks = @tag.taggings.collect { |tagging|   
      Bookmark.find(tagging.taggable_id)
    }

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end
end
