class CompaniesController < ApplicationController
  
  before_filter :authorize, :only => :show
  
  def show
    @user = current_user
    @company = my_company
  end
  
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
       
        redirect_to root_url 
    else
        render action: "new" 
    end
  end

end
