class CompaniesController < ApplicationController
  
  before_filter :authorize, :only => :show
  
  def show
    @user = current_user
    @company = my_company
    
    if (!params[:from].blank? && !params[:to].blank?)
  		@myfrom = convert_date(params[:from])
  		@myto = convert_date(params[:to])
  	elsif (!params[:myfrom].blank? && !params[:myto].blank?)
  		@myfrom = Date.strptime(params[:myfrom], "%Y-%m-%d") 
  		@myto = Date.strptime(params[:myto], "%Y-%m-%d") 
  	else
  		@myfrom = Date.today.beginning_of_month
  		@myto = Date.today
  	end
    
    @projects = find_company_projects_sum
        
    

  	
  	@employees = find_company_employees_sum
  	
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


  private

   	def find_company_projects_sum
   		# returns a mapping [project name, id, client info, sum of hours]
   		my_company.projects.map{
   			|p|[p.name, p.id, p.client, p.entries.reduce(0) do |sum, entry| 
   					sum = sum + entry.hours 
   				end
   			]
   		}
   	end

   	def find_company_employees_sum
   		# returns a mapping [user email, id, name, sum of hours]
   		my_company.users.order("email ASC").map{
   			|u|[u.email, u.id, u.name, u.entries.reduce(0) do |sum, entry| 
   					sum = sum + entry.hours 
   				end
   			]
   		}
   	end

   	def find_company_projects
   		# returns a mapping [project name, id]
   		my_company.projects.map{|p|[p.name, p.id]}
   	end

   	def find_company_entries
   		my_company.projects.entries
   	end


end
