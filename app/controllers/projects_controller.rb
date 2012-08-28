class ProjectsController < ApplicationController
 
  def new
    @project = Project.new
  end
  
  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect_to overview_path
    else
      render "new"
    end
  end
  
  
  def edit
    @project = Project.find(params[:id])
  end
  
  def update
    @project = Project.find(params[:id])

    if @project.update_attributes(params[:project])
        redirect_to @project
    else
        render action: "edit" 
    end
  end
  
  
  def show
    @project = Project.find(params[:id])
    @user = current_user
    @is_user_page = false
    @company = my_company

      # LOGIC FOR DATE FILTER (TO/FROM)
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

    	# FIND ENTRIES FILTERED BY DATE
    	@entries = @project.entries.where("cal_date >= ? AND cal_date <= ?", @myfrom, @myto).order('cal_date DESC')

    	# LOGIC FOR PROJECTS/EMPLOYEES FILTER
    	if (!params[:filter].blank?)	
  	    @filter_projects = params[:filter][:projects]
  	    if (@filter_projects.blank?) #if project filter blank, set to all projects
  	      @filter_projects = my_company.projects.map{|p| p.id.to_s}
    	  end
    	  @filter_employees = params[:filter][:employees]  	
    	  if (@filter_employees.blank?) #if employee filter blank, set to current user
    	    @filter_employees = current_user.id.to_s
  	    end
    	else
    		@filter_projects = my_company.projects.map{|p| p.id.to_s}
    		@filter_employees = current_user.id.to_s
    	end
    	@filter_projects = @project.id.to_s

    	# NEXT ENTRY FILTER - PROJECTS
      # @entries = @entries.where("project_id in (?)", @filter_projects)

    	# NEXT ENTRY FILTER - EMPLOYEES
    	@entries = @entries.where("user_id in (?)", @filter_employees)

      # VARIABLES - NEW ENTRY BOX
      @entry = Entry.new
      @projects = find_my_projects_sum
      @employees = find_my_employees_sum(@project)

      # VARIABLES - ENTRY TABLE
      @editableprojects = find_company_projects
     	@editableemployees = find_company_employees   

      # SUM FOR ENTRY TABLE
      @hrs_sum = 0
    	@entries.each do |entry|
    		@hrs_sum = @hrs_sum + entry.hours
    	end



    	# PULL CALENDAR ENTRIES
    	@date = params[:date] ? Date.parse(params[:date]) : Date.today
    	@calendar_entries = @entries.where("cal_date >= ? AND cal_date <= ?", 
    	                                           @date.beginning_of_month, @date.end_of_month)

    	@cal_entry_array = (@date.beginning_of_month..@date.end_of_month).map{
    	  |d|[d, @calendar_entries.where("cal_date = ?", d).reduce(0) do |sum, entry| 
   					sum = sum + entry.hours 
   				end
   			]
    	}

    	@cal_month_sum = @calendar_entries.reduce(0) do |sum, entry|
                          sum = sum + entry.hours
                        end


    	# PLACEHOLDER FOR TRENDS
    	@project_sum_array = []
    	@employee_sum_array = []
    	
    	
    
    
    # CREATE AND DISPLAY STAFFING RELATIONSHIP
    @staff = @project.reverse_relationships
    @staffed_employees = @project.staffed_users
    @company = my_company
    @notstaffed_employees = @company.users - @staffed_employees
    @notstaffed_employees.map{|u|[u.name, u.id]}
    
    # FIND USERS ACTUAL HOURS
    @user_entries = @project.entries.select("user_id, sum(hours) as hours_sum").group("user_id")
    
    # CALCULATE TOTAL PROJECT REVENUE
    @project_total_revenue = 0
    @user_entries.each do |e|
      e_user = e.user.relationships.find_by_project_id(@project.id)
      if e_user
        @project_total_revenue = @project_total_revenue + (e.hours_sum.to_d * e_user.rate)
      end
    end
    @project_budgeted_dollars = @project.budgeted_dollars ? @project.budgeted_dollars : 0
    @dollars_percentage = number_to_percentage((@project_total_revenue.to_d/@project_budgeted_dollars)*100, :precision => 0)    
    
    # CALCULATE PROJECT HOURS SUM
    @project_hours_sum = @project.entries.sum(:hours)
    
    # FIND RELEVANT ENTRIES FOR LAST MONTH'S INVOICE
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @prev_month_entries = @project.entries.select("user_id, sum(hours) as hours_sum").
                                           where("cal_date >= ? AND cal_date <= ?", 
  	                                       @date.prev_month.beginning_of_month, @date.prev_month.end_of_month).
  	                                       group("user_id")
    @prev_month_sum = 0
    @prev_month_entries.each do |e|
      e_user = e.user.relationships.find_by_project_id(@project.id)
      if e_user
        @prev_month_sum = @prev_month_sum + (e.hours_sum.to_d * e_user.rate)
      end
    end


    def projectstaff
      @project = Project.find(params[:project_id])
      @staff = @project.reverse_relationships
      @staffed_employees = @project.staffed_users
      @company = my_company
      @notstaffed_employees = @company.users - @staffed_employees
      @notstaffed_employees.map{|u|[u.name, u.id]}
      
      # FIND USERS ACTUAL HOURS
      @user_entries = @project.entries.select("user_id, sum(hours) as hours_sum").group("user_id")
      
      # CALCULATE PROJECT HOURS SUM
      @project_hours_sum = @project.entries.sum(:hours)
    end
    
    
    
  end
  
  
  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    
    redirect_to root_url
  end
  
  
  
  
  
	################# PRIVATE METHODS ################# 
    private



      # USED FOR NEW ENTRY LISTS -- client/sum not needed?
     	def find_my_projects_sum
     		# returns a mapping [project name, client info, sum of hours, id]
     		current_user.staffed_projects.map{
     			|p|[p.name, p.client, p.entries.reduce(0) do |sum, entry| 
     					sum = sum + entry.hours 
     				end, p.id
     			]
     		}
     	end

      # USED FOR NEW ENTRY LISTS -- email/sum not needed?
     	def find_my_employees_sum(project)
     		# returns a mapping [user name, email, sum of hours, id]
     		project.staffed_users.order("name ASC").map{
     			|u|[u.name, u.email, u.entries.reduce(0) do |sum, entry| 
     					sum = sum + entry.hours 
     				end, u.id
     			]
     		}
     	end
  
end
