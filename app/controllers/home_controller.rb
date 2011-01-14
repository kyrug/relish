class HomeController < ApplicationController
  def index
    @bookmarks = Bookmark.all
  end

end
