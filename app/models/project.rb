class Project < ActiveRecord::Base  
  attr_accessible :client, :name, :company_id, :budgeted_dollars
  
  belongs_to :company
  has_many :entries
  has_many :reverse_relationships,
					 :class_name => "Relationship",
					 :dependent => :destroy
	has_many :staffed_users, :through => :reverse_relationships, :source => :user
  
  validates :name, :presence => true
  validates_numericality_of :budgeted_dollars, :message => 'Please input a number'
  

end
