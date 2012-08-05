class Project < ActiveRecord::Base  
  attr_accessible :client, :name, :company_id
  
  belongs_to :company
  has_many :entries
  
  validates :name, :presence => true

end
