class EntriesController < ApplicationController
  helper_method :sort_column, :sort_direction
  respond_to :html, :json

  def new
    @entry = Entry.new
  end

  def create
    @entry = Entry.new(params[:entry])
    if (@entry.notes.empty?)
        @entry.notes = "---"
    end
    
	  if @entry.save
	    flash["alert alert-success"] = 'Entry was successfully created'
  		redirect_to root_url
  	else
  	  flash["alert alert-error"] = "Invalid Time Entry" 
  		redirect_to root_url
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
        	
        end
        
        format.html { redirect_to root_url, :notice => 'User was successfully updated.' }
        format.json
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @entry.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
  
  # DONT THINK THIS IS NEEDED ANYMORE - CLEANUP
  def updatejs
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

    @editableprojects = find_company_projects
    @editableemployees = find_company_employees
    
    ### UPDATE CALENDAR STUFF
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
    
    render 'update.js.erb'
  end
  

 
##### TABLE #####
  def entrytable
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
 
 
 
 
  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy

    flash["alert"] = 'Entry was deleted'
    redirect_to root_url 
  end
  
  
  
################# PRIVATE METHODS ################# 
  private
	
	

  	



end
