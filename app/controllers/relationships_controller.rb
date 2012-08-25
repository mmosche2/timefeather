class RelationshipsController < ApplicationController
  before_filter :authorize
  
  def new
    @relationship = Relationship.new
    @company = my_company
    @project = params[:project] ? Project.find(params[:project]) : nil
    @user = params[:user] ? User.find(params[:user]) : nil
    if (@project)
      @staffed_employees = @project.staffed_users
      @notstaffed_employees = @company.users - @staffed_employees
      @notstaffed_employees.map{|u|[u.name, u.id]}
    else
      @staffed_projects = @user.staffed_projects
      @notstaffed_projects = @company.projects - @staffed_projects
      @notstaffed_projects.map{|p|[p.name, p.id]}
    end
  end
  
  
  def create
    @relationship_params = params[:relationship]

    @project = @relationship_params[:project_id] ? Project.find(params[:relationship][:project_id]) : nil
    @user = @relationship_params[:user_id] ? User.find(params[:relationship][:user_id]) : nil
    
    if @relationship_params.first[0] == "user_id"
      @myredirect = @user
    else
      @myredirect = @project
    end
    
    @relationship = Relationship.new(@relationship_params)
    respond_to do |format|
      if @relationship.save 
          format.html { redirect_to @myredirect }
          format.js
      else 
          format.html { @project ? (redirect_to @project) : (redirect_to @user) }
          format.js
      end
    end    
  end

  def update
    @relationship = Relationship.find(params[:id])
    @project = @relationship.project

    respond_to do |format|
      if @relationship.update_attributes(params[:relationship]) 
          format.html { redirect_to @project }
          format.js
          format.json {respond_with_bip(@relationship)}
      else 
          format.html { redirect_to @project }
          format.js
          format.json {respond_with_bip(@relationship)}
      end
    end
  end

  def destroy
    @relationship = Relationship.find(params[:id])
    @project = @relationship.project
    @user = @relationship.user
    # is this better than just calling @relationship.destroy?
    #@user.unstaff!(@project)
    @relationship.destroy
    respond_to do |format|
        format.html { redirect_to @project }
        format.js
    end
  end
  
  
  

  
end