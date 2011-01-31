class ImportController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  
  def index    
  end
  
  def upload
    Nokogiri::HTML(params[:file].read).search('dt a').each do |link|
      bookmark = Bookmark.new(
          :title    => link.content,
          :url      => link['href'],
          :tags     => link['tags'].split(','),
          :add_date => Time.at(link['add_date'].to_i),
          :private  => link['private']
        )
      current_user.bookmarks << bookmark
    end
    redirect_to(user_bookmarks_path(current_user), :notice=>'Bookmarks were uploaded.')
  end
  
end