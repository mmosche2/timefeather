class ProjectsController < ApplicationController
 
  def new
    @project = Project.new
  end
  
  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect_to new_project_path
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
        redirect_to dashboard_path
    else
        render action: "edit" 
    end
  end
  
  
  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    
    redirect_to new_entry_path
  end
  
end
