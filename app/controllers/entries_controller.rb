class EntriesController < ApplicationController
  helper_method :sort_column, :sort_direction
  respond_to :html, :json

  def new
    @entry = Entry.new
  end

  def create
    @entry_params = params[:entry]
    @entry = Entry.new(@entry_params)
    if (@entry.notes.empty?)
        @entry.notes = "---"
    end
    
    # REPLACED BY REDIRECT_TO :BACK
    # @project = @entry_params[:project_id] ? Project.find(@entry_params[:project_id]) : nil
    # @user = @entry_params[:user_id] ? User.find(@entry_params[:user_id]) : nil
    # 
    # if @entry_params.first[0] == "user_id"
    #   @myredirect = @user
    # else
    #   @myredirect = @project
    # end
    
	  if @entry.save
	    flash["alert alert-success"] = 'Entry was successfully created'
  		redirect_to :back
  	else
  	  flash["alert alert-error"] = "Invalid Time Entry" 
  		redirect_to :back
  	end
  end
  
  
  def edit
     @entry = Entry.find(params[:id])
  end
  
  def update
    @entry = Entry.find(params[:id])
    
    respond_to do |format|
      if @entry.update_attributes(params[:entry])
       
       if (params[:shouldupdate])
          ### UPDATE TABLE STUFF
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

        	@entries = my_company.entries.where("cal_date >= ? AND cal_date <= ?", @myfrom, @myto).order(sort_column + ' ' + sort_direction)

          @filter_projects = params[:filter_projects]
          @filter_employees = params[:filter_employees]
          if (@filter_projects.blank?)	#if project filter blank, set to all projects
            @filter_projects = my_company.projects.map{|p| p.id.to_s}
          end
          if (@filter_employees.blank?)	#if employee filter blank, set to current user
            @filter_employees = current_user.id.to_s
          end

        	# PROJECTS FILTER
        	@entries = @entries.where("project_id in (?)", @filter_projects)

        	# EMPLOYEES FILTER
        	@entries = @entries.where("user_id in (?)", @filter_employees)

          # SUM FOR ENTRY TABLE
          @hrs_sum = 0
        	@entries.each do |entry|
        		@hrs_sum = @hrs_sum + entry.hours
        	end
        	
        	# NEW SUM FOR PROJECT AND USER
        	@user = @entry.user
        	@project = @entry.project
        	@user_sum = @user.entries.reduce(0) do |sum, entry| 
     					            sum = sum + entry.hours 
     				          end
     			@project_sum = @project.entries.reduce(0) do |sum, entry| 
           					      sum = sum + entry.hours 
     				          end
        else
          @user = @entry.user
          @project = @entry.project
        end
        
        format.html { redirect_to root_url, :notice => 'User was successfully updated.' }
        format.json
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @entry.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
  
##### TABLE #####
  def entrytable
    @is_user_page = params[:is_user_page]
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
  	
  	@entries = my_company.entries.where("cal_date >= ? AND cal_date <= ?", @myfrom, @myto).order(sort_column + ' ' + sort_direction)
    
    @filter_projects = params[:filter_projects]
    @filter_employees = params[:filter_employees]
    if (@filter_projects.blank?)	#if project filter blank, set to all projects
      @filter_projects = my_company.projects.map{|p| p.id.to_s}
    end
    if (@filter_employees.blank?)	#if employee filter blank, set to current user
      @filter_employees = current_user.id.to_s
    end

  	# PROJECTS FILTER
  	@entries = @entries.where("project_id in (?)", @filter_projects)
  	
  	# EMPLOYEES FILTER
  	@entries = @entries.where("user_id in (?)", @filter_employees)
  
    # SUM FOR ENTRY TABLE
    @hrs_sum = 0
  	@entries.each do |entry|
  		@hrs_sum = @hrs_sum + entry.hours
  	end

    @editableprojects = find_company_projects
    @editableemployees = find_company_employees
    
  end
  
##### CALENDAR #####
  def entrycalendar
    @filter_projects = params[:filter_projects]
    @filter_employees = params[:filter_employees]
    if (@filter_projects.blank?)	#if project filter blank, set to all projects
      @filter_projects = my_company.projects.map{|p| p.id.to_s}
    end
    if (@filter_employees.blank?)	#if employee filter blank, set to current user
      @filter_employees = current_user.id.to_s
    end

  	#PROJECTS FILTER
  	@entries = my_company.entries.where("project_id in (?)", @filter_projects)
  	
  	#EMPLOYEES FILTER
  	@entries = @entries.where("user_id in (?)", @filter_employees)
    
    # PULL CALENDAR ENTRIES
    @company = my_company
  	@date = @date = params[:date] ? Date.parse(params[:date]) : Date.today
  	@calendar_entries = @entries.where("cal_date >= ? AND cal_date <= ?", 
  	                                           @date.beginning_of_month, @date.end_of_month)
                                               
  	@cal_entry_array = (@date.beginning_of_month..@date.end_of_month).map{
  	  |d|[d, @calendar_entries.where("cal_date = ?", d).reduce(0) do |sum, entry| 
 					sum = sum + entry.hours 
 				end
 			]
  	}
  	
  	@cal_month_sum =  @calendar_entries.reduce(0) do |sum, entry|
                        sum = sum + entry.hours
                      end
    
  end
 
##### TRENDS #####
  def entrytrends
    @is_user_page = params[:is_user_page]
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
  	
  	@entries = my_company.entries.where("cal_date >= ? AND cal_date <= ?", @myfrom, @myto)
    
    @filter_projects = params[:filter_projects]
    @filter_employees = params[:filter_employees]
    if (@filter_projects.blank?)	#if project filter blank, set to all projects
      @filter_projects = my_company.projects.map{|p| p.id.to_s}
    end
    if (@filter_employees.blank?)	#if employee filter blank, set to current user
      @filter_employees = current_user.id.to_s
    end

  	# PROJECTS FILTER
  	@entries = @entries.where("project_id in (?)", @filter_projects)
  	
  	# EMPLOYEES FILTER
  	@entries = @entries.where("user_id in (?)", @filter_employees)
  	
  	# CALCULATE SUM BY PROJECT [PROJECT NAME, SUM]
      # (this can probably be done with a better method using less sql calls)
    if (@filter_projects.kind_of?(Array))
      @project_sum_array = @filter_projects.map{
   			|p|[Project.find(p).name, @entries.where("project_id = ?", p).reduce(0) do |sum, entry| 
   					sum = sum + entry.hours.to_i
   				end
   			]
   		}
   	else
   	  p = @filter_projects
      @project_sum_array = [[Project.find(p).name, @entries.where("user_id = ?", p).reduce(0) do |sum, entry| 
 					sum = sum + entry.hours.to_i
 				end
 			]]   	  
 	  end

    # CALCULATE SUM BY EMPLOYEE [NAME, SUM]
      # (this can probably be done with a better method using less sql calls)
    if (@filter_employees.kind_of?(Array))
      @employee_sum_array = @filter_employees.map{
        |e|[User.find(e).name, @entries.where("user_id = ?", e).reduce(0) do |sum, entry| 
   					sum = sum + entry.hours.to_i
   				end
   			]
   		}
   	else
   	  e = @filter_employees
      @employee_sum_array = [[User.find(e).name, @entries.where("user_id = ?", e).reduce(0) do |sum, entry| 
 					sum = sum + entry.hours.to_i
 				end
 			]]   	  
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

  end
  
  
  
  
  
 
  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy

    flash["alert"] = 'Entry was deleted'
    redirect_to :back 
  end
  
  
  
################# PRIVATE METHODS ################# 
  private
	
   	def get_projects_sum_array
   		# returns a mapping [project name, client info, sum of hours, id]
   		my_company.projects.map{
   			|p|[p.name, p.client, p.entries.reduce(0) do |sum, entry| 
   					sum = sum + entry.hours 
   				end, p.id
   			]
   		}
   	end
 	
   	def get_employees_sum_array
   		# returns a mapping [user name, email, sum of hours, id]
   		my_company.users.order("email ASC").map{
   			|u|[u.name, u.email, u.entries.reduce(0) do |sum, entry| 
   					sum = sum + entry.hours 
   				end, u.id
   			]
   		}
   	end

  	

    def business_days_between(date1, date2)
      business_days = 0
      date = date2
      while date > date1
       business_days = business_days + 1 unless date.saturday? or date.sunday?
       date = date - 1.day
      end
      business_days
    end


end
