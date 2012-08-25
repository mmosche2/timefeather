class Relationship < ActiveRecord::Base
  attr_accessible :user_id, :project_id, :rate, :staffing_start, :staffing_end, :budgeted_hrs
  
  belongs_to :user
  belongs_to :project

	validates :user_id, :presence => true
	validates :project_id, :presence => true
	validates :rate, :presence => true
	
end
