class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :company_id, :name
  has_secure_password
  
  belongs_to :company
  has_many :entries
  
  validates :email,
				:presence 	=> true,
				:uniqueness => { :case_sensitive => false },
				:format 	=> { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
	
	validates_presence_of :password, :on => :create
  
end
