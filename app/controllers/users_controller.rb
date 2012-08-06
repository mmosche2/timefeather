class UsersController < ApplicationController
  
  def new
    @user = User.new
    @users = my_company.users
    @type = "new"
  end
  
  def create
    @user = User.new(params[:user])
    name = @user.email.split('@')[0]
    @user.name = name
    if @user.save    
      redirect_to new_user_path
    else
      @users = my_company.users
      render "new"
    end
  end
  
  
  def edit
    @user = User.find(params[:id])
    @users = my_company.users
    @type = "edit"
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
        redirect_to dashboard_path
    else
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
			redirect_to new_user_path
	  end
	end
  
end
