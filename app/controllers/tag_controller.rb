class TagController < ApplicationController
  
  def show
    tags = params[:tags].split('/')
    
    @urls = Url.where(:tag_words.all => tags).paginate({
        :per_page=>25,
        :page=>params[:page] || 1
    })
    
  end
    
end