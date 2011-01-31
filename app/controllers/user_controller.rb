class UserController < ApplicationController
  
  def bookmarks
    @user = User.first(:username=>params[:username]) or (render_404 and return)
    @bookmarks = available_bookmarks.ordered.paginate({
          :per_page=>25,
          :page=>params[:page] || 1
    })
  end
  
  def tags
    @user = User.first(:username=>params[:username]) or (render_404 and return)
    @bookmarks = available_bookmarks.ordered.paginate({
        :tags.all => params[:tags].split('/'),
        :per_page=>25,
        :page=>params[:page] || 1
    })
  end
  
  protected
  def available_bookmarks
    (current_user) ?  @user.bookmarks_visible_to(current_user) : @user.bookmarks.publicly_available
  end
  
 
end