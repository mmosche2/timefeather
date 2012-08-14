class ApplicationController < ActionController::Base
  protect_from_forgery
  

################# PRIVATE METHODS #################   
  private
    
    def current_user
      @current_user ||= User.find_by_auth_token( cookies[:auth_token] ) if cookies[:auth_token] 
    end
    
    def my_company
      @my_company ||= current_user.company if current_user
    end
    
    def authorize
      redirect_to login_url if current_user.nil?
    end
    
    def signed_in?
  	  !current_user.nil?
    end
    
    helper_method :current_user
    helper_method :my_company
    helper_method :signed_in?
    
    
    def sort_column
       Entry.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end
    
    helper_method :sort_column, :sort_direction
    
    
  	def find_company_projects
   		# returns a mapping [project name, id]
   		my_company.projects.map{|p|[p.id, p.name]}
   	end

  	def find_company_employees
   		# returns a mapping [project name, id]
   		my_company.users.map{|u|[u.id, u.name]}
   	end
   	
   	def find_entries_sum(from, to)
      current_user.entries.where("cal_date >= ? AND cal_date <= ?", from, to).reduce(0) do |sum, entry|
        sum = sum + entry.hours
      end
    end
    
    
  	
    helper_method :find_company_projects
    helper_method :find_company_employees
    helper_method :find_entries_sum
    
    
end
