class Company < ActiveRecord::Base
  attr_accessible :name, :users_attributes
  
  has_many :users, :dependent => :destroy
	accepts_nested_attributes_for :users, :allow_destroy => true
	has_many :projects, :dependent => :destroy
	has_many :entries, :through => :projects, :dependent => :destroy
  
  validates :name, :presence => true
	validates_uniqueness_of :name, :case_sensitive => false	

	
end
