class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  attr_accessible :cal_date, :hours, :notes, :user_id, :project_id
  
  validates :hours, :presence => true
  
end
