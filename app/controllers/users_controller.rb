class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  
  load_and_authorize_resource

  def index
    @users = User.paginate :page => params[:page], :order => 'created_at DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  def show
    logger.warn "h!!!!!" + params[:id]
    @user = User.find_by_username(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

end
