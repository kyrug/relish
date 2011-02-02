class UrlsController < ApplicationController
  
  def show
    @bookmark_url = Url.find_by_id(params[:id]) or (render_404 and return)
    @bookmarks = Bookmark.ordered.paginate({
        :url_id=> params[:id],
        :per_page=>25,
        :page=>params[:page] || 1
    })
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookmarks }
    end 
  end
  
 
end