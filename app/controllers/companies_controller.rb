class CompaniesController < ApplicationController
  
  
  def new
    @company = Company.new
    user = @company.users.build
  end

  def create
    @company = Company.new(params[:company])
    myuser = @company.users.first
    myuser.name = myuser.email.split('@')[0]
    
    if @company.save
        user = User.new(params[:users_attributes])
        
        session[:user_id] = myuser.id
       
        redirect_to new_user_path 
    else
        render action: "new" 
    end
  end

end
