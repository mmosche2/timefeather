class ProjectsController < ApplicationController
 
  def new
    @project = Project.new
  end
  
  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect_to root_url
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
        redirect_to root_url
    else
        render action: "edit" 
    end
  end
  
  
  def show
    @project = Project.find(params[:id])
    @user = current_user
    
    # CREATE AND DISPLAY STAFFING RELATIONSHIP
    @relationship = Relationship.new
    @staff = @project.reverse_relationships
    @staffed_employees = @project.staffed_users
    @company = my_company
    @notstaffed_employees = @company.users - @staffed_employees
    @notstaffed_employees.map{|u|[u.name, u.id]}
    
    # FIND USERS ACTUAL HOURS
    @user_entries = @project.entries.select("user_id, sum(hours) as hours_sum").group("user_id")
    
    
    # FIND RELEVANT ENTRIES FOR LAST MONTH'S INVOICE
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @prev_month_entries = @project.entries.select("user_id, sum(hours) as hours_sum").
                                           where("cal_date >= ? AND cal_date <= ?", 
  	                                       @date.prev_month.beginning_of_month, @date.prev_month.end_of_month).
  	                                       group("user_id")
    @prev_month_sum = 0
    @prev_month_entries.each do |e|
      @prev_month_sum = @prev_month_sum + (e.hours_sum.to_d * e.user.relationships.find_by_project_id(@project.id).rate)
    end

    
    
    
  end
  
  
  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    
    redirect_to root_url
  end
  
end
