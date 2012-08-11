class CompaniesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :authorize, :only => :show
  
  def show
    @user = current_user
    @company = my_company
    
    @today = Date.today
    
    if (!params[:from].blank? && !params[:to].blank?)
  		@myfrom = Date.strptime(params[:from][0], "%b %e %Y")
  		@myto = Date.strptime(params[:to][0], "%b %e %Y")
  	elsif (!params[:myfrom].blank? && !params[:myto].blank?)
  		@myfrom = Date.strptime(params[:myfrom], "%Y-%m-%d") 
  		@myto = Date.strptime(params[:myto], "%Y-%m-%d") 
  	else
  		@myfrom = @today.beginning_of_month
  		@myto = @today
  	end
    
    @entry = Entry.new
    @projects = find_company_projects_sum
    @editableprojects = find_company_projects
        
    @entries = my_company.entries.where("cal_date >= ? AND cal_date <= ?", @myfrom, @myto).order(sort_column + ' ' + sort_direction)
    
    @hrs_sum = 0
  	@entries.each do |entry|
  		@hrs_sum = @hrs_sum + entry.hours
  	end

  	
  	@employees = find_company_employees_sum
  	@editableemployees = find_company_employees
  	
  end
  
  def new
    @company = Company.new
  end

  def create
    @company = Company.new(params[:company])
    
    if @company.save 
          
        redirect_to new_user_path(:company => @company)
    else
        render action: "new" 
    end
  end


  private

   	def find_company_projects_sum
   		# returns a mapping [project name, client info, sum of hours, id]
   		my_company.projects.map{
   			|p|[p.name, p.client, p.entries.reduce(0) do |sum, entry| 
   					sum = sum + entry.hours 
   				end, p.id
   			]
   		}
   	end

   	def find_company_employees_sum
   		# returns a mapping [user name, email, sum of hours, id]
   		my_company.users.order("email ASC").map{
   			|u|[u.name, u.email, u.entries.reduce(0) do |sum, entry| 
   					sum = sum + entry.hours 
   				end, u.id
   			]
   		}
   	end

   	def find_company_projects
   		# returns a mapping [project name, id]
   		my_company.projects.map{|p|[p.id, p.name]}
   	end
   	
   	def find_company_employees
   		# returns a mapping [project name, id]
   		my_company.users.map{|u|[u.id, u.name]}
   	end

   	def find_company_entries
   		my_company.projects.entries
   	end

  	def sort_column
       Entry.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end
    
    
    

end
