class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  attr_accessible :cal_date, :hours, :notes, :user_id, :project_id
  
  validates :hours, :presence => true
  validates :user_id, :presence => true
  validates :project_id, :presence => true
  
  def mdmy_format
    cal_date.strftime('%a, %b %-d %Y')
  end
  
  def sum_hours(entries)
    entries.each do |entry|
  		@hrs_sum = @hrs_sum + entry.hours
  	end
  	return @hrs_sum
  end
  
  
end
