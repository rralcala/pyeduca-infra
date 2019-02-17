class SessionsController < ApplicationController

  skip_filter :authenticate, :only => [:new, :create]

  def new
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = _("Session terminated")
    redirect_to :action => "new"
  end

  def create
    name = params[:name]
    password = params[:password]

    session[:locale] = params[:language]
    session[:user_id] = User.authenticate(name, password)
    
    if session[:user_id]
      redirect_to_return
    else
      flash[:error] = _("User's name or password incorrect")
      redirect_to :action => "new"
    end
  end

end
