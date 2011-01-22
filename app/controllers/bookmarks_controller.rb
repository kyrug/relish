class BookmarksController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  # Because index shows newest bookmarks for all users
  # If a user is logged in, index shows their bookmarks instead
  # Show should work for public bookmarks

  load_and_authorize_resource

  def index
    # TODO: use cancan for these.
    if user_signed_in?
      @bookmarks = current_user.bookmarks.paginate :page => params[:page], :order => 'created_at DESC'
    else
      @bookmarks = Bookmark.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookmarks }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bookmark }
    end
  end

  def new
    if not params[:url].blank?
      @bookmark.url = params[:url]
    end
    if not params[:title].blank?
      @bookmark.title = params[:title]
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bookmark }
    end
  end

  def edit
    # Thanks, cancan! (no-op)
  end

  def create
    # TODO: figure out which of these works best and pairs with cancan
    @bookmark = Bookmark.new(params[:bookmark])
    @bookmark = current_user.bookmarks.create(params[:bookmark])

    respond_to do |format|
      if @bookmark.save
        format.html do
          if params[:goback]
            redirect_to(@bookmark.url)
          else
            redirect_to(@bookmark,
                        :notice => 'Bookmark was successfully created.')
          end
        end
        format.xml  { render :xml => @bookmark, :status => :created, :location => @bookmark }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bookmark.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @bookmark.update_attributes(params[:bookmark])
        format.html { redirect_to(@bookmark, :notice => 'Bookmark was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bookmark.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @bookmark.destroy
    respond_to do |format|
      format.html { redirect_to(bookmarks_url) }
      format.xml  { head :ok }
    end
  end
end
