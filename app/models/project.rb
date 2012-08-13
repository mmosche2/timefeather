class Project < ActiveRecord::Base  
  attr_accessible :client, :name, :company_id, :budgeted_hrs
  
  belongs_to :company
  has_many :entries
  
  validates :name, :presence => true
  validates_numericality_of :budgeted_hrs, :message => 'Please input a number'
  

end
