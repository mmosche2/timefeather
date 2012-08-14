class EntriesController < ApplicationController
  helper_method :sort_column, :sort_direction
  respond_to :html, :json

  def new
    
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
    
    @entry = Entry.new
    @projects = find_company_projects_sum
        
    @entries = my_company.entries.where("cal_date >= ? AND cal_date <= ?", @myfrom, @myto).order(sort_column + ' ' + sort_direction)
    
    @hrs_sum = 0
  	@entries.each do |entry|
  		@hrs_sum = @hrs_sum + entry.hours
  	end
  	
  	@employees = find_company_employees_sum
  	
  	
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
     
     @user = current_user
     @company = my_company

     @today = Date.today

     if (!params[:from].blank? && !params[:to].blank?)
   		@myfrom = Date.strptime(params[:from][0], "%m/%d/%Y")
   		@myto = Date.strptime(params[:to][0], "%m/%d/%Y")
   	elsif (!params[:myfrom].blank? && !params[:myto].blank?)
   		@myfrom = Date.strptime(params[:myfrom], "%Y-%m-%d") 
   		@myto = Date.strptime(params[:myto], "%Y-%m-%d") 
   	else
   		@myfrom = @today.beginning_of_month
   		@myto = @today
   	end

     @entry = Entry.find(params[:id])
     @projects = find_company_projects_sum

     @entries = my_company.entries.where("cal_date >= ? AND cal_date <= ?", @myfrom, @myto).order(sort_column + ' ' + sort_direction)

     @hrs_sum = 0
   	@entries.each do |entry|
   		@hrs_sum = @hrs_sum + entry.hours
   	end


   	@employees = find_company_employees_sum
     
     render "companies/show"
  end
  
  def update
    @entry = Entry.find(params[:id])
    @entry.update_attributes(params[:entry])
    respond_with @entry

#    if @entry.update_attributes(params[:entry])        
#        @entry.cal_date = Date.strptime(@entry.cal_date.to_s, "%Y-%d-%m")
#        flash["alert alert-success"] = 'Entry was successfully updated'
#        redirect_to root_url
#    else
#        flash["alert alert-error"] = 'Entry was not updated'
#        redirect_to root_url
#    end
  end
  
 
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

  	#PROJECTS FILTER
  	@entries = @entries.where("project_id in (?)", @filter_projects)
  	
  	#EMPLOYEES FILTER
  	@entries = @entries.where("user_id in (?)", @filter_employees)
  	
  	
    @editableprojects = find_company_projects
    @editableemployees = find_company_employees
    
  end
  
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
	
	
  	def convert_date(obj)
  	  return Date.new(obj['(1i)'].to_i,obj['(2i)'].to_i,obj['(3i)'].to_i)
  	end
  	
  	def sort_column
       Entry.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end


end
