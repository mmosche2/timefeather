class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  private
    
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    
    def my_company
      @my_company ||= current_user.company if current_user
    end
    
    def authorize
      redirect_to login_url if current_user.nil?
    end
    
    def signed_in?
  	  !current_user.nil?
    end
    
    helper_method :current_user
    helper_method :my_company
    helper_method :signed_in?
    
end
