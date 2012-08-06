class EntriesController < ApplicationController
  helper_method :sort_column, :sort_direction

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

	  if @entry.save
  		redirect_to new_entry_path, notice: 'Entry was successfully created.' 
  	else
  		render action: "new" 
  	end
  end
 
  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy

    redirect_to new_entry_url 
  end
  
  
  private
	
  	def find_company_projects_sum
  		# returns a mapping [project name, id, client info, sum of hours]
  		my_company.projects.map{
  			|p|[p.name, p.id, p.client, p.entries.reduce(0) do |sum, entry| 
  					sum = sum + entry.hours 
  				end
  			]
  		}
  	end
  	
  	def find_company_employees_sum
  		# returns a mapping [user email, id, name, sum of hours]
  		my_company.users.order("email ASC").map{
  			|u|[u.email, u.id, u.name, u.entries.reduce(0) do |sum, entry| 
  					sum = sum + entry.hours 
  				end
  			]
  		}
  	end
	
  	def find_company_projects
  		# returns a mapping [project name, id]
  		my_company.projects.map{|p|[p.name, p.id]}
  	end
  	
  	def find_company_entries
  		my_company.projects.entries
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
