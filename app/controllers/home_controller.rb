class HomeController < ApplicationController
  def index
    @bookmarks = Bookmark.all.paginate(:page => params[:page], :order => 'created_at DESC')
  end

end
