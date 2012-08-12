class UsersController < ApplicationController
  
  def new
    @user = User.new
    @company_param = params[:company]
    @company = @company_param ? Company.find(@company_param) : my_company
    
    @type = "new"
  end
  
  def create
    @user = User.new(params[:user])

    if @user.save    
      
      # sign the user in if they are creating the company profile
      if !signed_in?
        cookies[:auth_token] = @user.auth_token
      end
      
      redirect_to root_url
    else
      @company = Company.find(params[:user][:company_id])
      render "new"
    end
  end
  
  def account
    @user = current_user
    @company = my_company
    @type = "edit"
    render "edit"
  end
  
  def edit
    @user = User.find(params[:id])
    
    @company = my_company
    @users = @company.users
    
    @type = "edit"
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
        redirect_to root_url
    else
        @type = "edit"
        render action: "edit"
    end
  end
  
  
  def destroy
		@user = User.find(params[:id])
		
		if @user == current_user
		  @user.destroy
		  session[:user_id] = nil
			redirect_to root_url 
		else
		  @user.destroy
			redirect_to root_url
	  end
	end
  
end
