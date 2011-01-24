class HomeController < ApplicationController
  # show all public bookmarks in the most recent order
  def index
    @bookmarks = Bookmark.where(:private => 0).all.paginate(:page => params[:page], :order => 'created_at DESC')
  end

end
