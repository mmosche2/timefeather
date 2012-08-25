class RelationshipsController < ApplicationController
  before_filter :authorize
  
  def create
    @project = Project.find(params[:relationship][:project_id])
    
    # BELOW CAN PROBABLY BE DELETED
    # @user = User.find(params[:relationship][:user_id])
    # @rate = params[:relationship][:rate]
    # @staffingstart = params[:relationship][:staffing_start]
    # @staffingend = params[:relationship][:staffing_end]
    # @budgeted_hrs = params[:relationship][:budgeted_hrs]
    # @user.staff!(@project, @rate, @staffingstart, @staffingend, @budgeted_hrs)

    @relationship = Relationship.new(params[:relationship])
    respond_to do |format|
      if @relationship.save 
          format.html { redirect_to @project }
          format.js
      else 
          format.html { redirect_to @project }
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