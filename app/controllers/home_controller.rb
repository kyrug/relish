class HomeController < ApplicationController

  def index     
    @bookmarks = Url.publicly_available.ordered(sort_params[params[:view]]).paginate({
        :per_page=>25,
        :page=>params[:page] || 1
    })
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookmarks }
    end
  end
  
  
  def popular
    @bookmarks = Url.publicly_available.ordered('popular').paginate({
        :per_page=>25,
        :page=>params[:page] || 1
    })
    respond_to do |format|
      format.html {render :template=>'home/index'  }
      format.xml  { render :xml => @bookmarks }
    end
  end

  def sort_params
    { "popular" => "hotness desc",
      "recent"  => "add_date desc" }
  end

end
