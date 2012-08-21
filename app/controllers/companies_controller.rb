include ActionView::Helpers::NumberHelper

class CompaniesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :authorize, :only => :show
  
  def show
    @user = current_user
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
  	@entries = my_company.entries.where("cal_date >= ? AND cal_date <= ?", @myfrom, @myto).order('cal_date DESC')
  	
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
  	
  	# NEXT ENTRY FILTER - PROJECTS
  	@entries = @entries.where("project_id in (?)", @filter_projects)
  	
  	# NEXT ENTRY FILTER - EMPLOYEES
  	@entries = @entries.where("user_id in (?)", @filter_employees)
    
    # VARIABLES - NEW ENTRY BOX
    @entry = Entry.new
    @projects = find_company_projects_sum
    @employees = find_company_employees_sum
    
    # VARIABLES - ENTRY TABLE
    @editableprojects = find_company_projects
   	@editableemployees = find_company_employees   
    
    # SUM FOR ENTRY TABLE
    @hrs_sum = 0
  	@entries.each do |entry|
  		@hrs_sum = @hrs_sum + entry.hours
  	end

  	
  	# DETERMINE USER METRICS
  	@firstofweek = @today.beginning_of_week
  	@firstofmonth = @today.beginning_of_month
  	@firstofyear = @today.beginning_of_year
  	
  	@my_week_sum = find_entries_sum(@firstofweek, @today)
  	@my_month_sum = find_entries_sum(@firstofmonth, @today)
  	@my_year_sum = find_entries_sum(@firstofyear, @today)
  	
  	@workdays_week = business_days_between(@firstofweek, @today+1)
  	@workdays_month = business_days_between(@firstofmonth, @today+1)
  	@workdays_year = business_days_between(@firstofyear, @today+1)
  	
  	@workhours_week = @workdays_week*EXPECTED_DAILY_HOURS
  	@workhours_month = @workdays_month*EXPECTED_DAILY_HOURS
  	@workhours_year = @workdays_year*EXPECTED_DAILY_HOURS
  	
    @workhours_week = @workhours_week == 0 ? 1 : @workhours_week
  	@workhours_month = @workhours_month == 0 ? 1 : @workhours_month
  	@workhours_year = @workhours_year == 0 ? 1 : @workhours_year
  	
  	@utilization_week = number_to_percentage((@my_week_sum/@workhours_week)*100, :precision => 0)
  	@utilization_month = number_to_percentage((@my_month_sum/@workhours_month)*100, :precision => 0)
  	@utilization_year = number_to_percentage((@my_year_sum/@workhours_year)*100, :precision => 0)
  	
  	
  	# PULL CALENDAR ENTRIES
  	@date = @date = params[:date] ? Date.parse(params[:date]) : Date.today
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



################# PRIVATE METHODS ################# 
  private
  

    
    def business_days_between(date1, date2)
      business_days = 0
      date = date2
      while date > date1
       business_days = business_days + 1 unless date.saturday? or date.sunday?
       date = date - 1.day
      end
      business_days
    end
    
    # USED FOR NEW ENTRY LISTS -- client/sum not needed?
   	def find_company_projects_sum
   		# returns a mapping [project name, client info, sum of hours, id]
   		my_company.projects.map{
   			|p|[p.name, p.client, p.entries.reduce(0) do |sum, entry| 
   					sum = sum + entry.hours 
   				end, p.id
   			]
   		}
   	end
   	
    # USED FOR NEW ENTRY LISTS -- email/sum not needed?
   	def find_company_employees_sum
   		# returns a mapping [user name, email, sum of hours, id]
   		my_company.users.order("email ASC").map{
   			|u|[u.name, u.email, u.entries.reduce(0) do |sum, entry| 
   					sum = sum + entry.hours 
   				end, u.id
   			]
   		}
   	end

    
    
    

end
