class UsersController < ApplicationController
  
  def new
    @user = User.new
    @users = my_company.users
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
