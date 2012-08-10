class SessionsController < ApplicationController

  def new    
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
	    	cookies.permanent[:auth_token] = user.auth_token
    	else
    		cookies[:auth_token] = user.auth_token  
      end

      flash["alert alert-success"] = "Logged in!"
      redirect_to root_url
    else
      flash["alert alert-error"] = "Email or password is invalid."
      redirect_to login_path
    end
  end
  
  def destroy
    cookies.delete(:auth_token)
    flash[:alert] = "Logged out!"
    redirect_to root_url
  end

end
