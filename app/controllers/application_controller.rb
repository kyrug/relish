class ApplicationController < ActionController::Base
  protect_from_forgery
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access Denied."
    redirect_to root_url
  end
  
  def render_404
    respond_to do |format|
      format.html { render :file => "#{RAILS_ROOT}/public/404.html", :status => '404 Not Found', :layout=>false }
      format.xml  { render :nothing => true, :status => '404 Not Found' }
    end
    true
  end
  
end
