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
	
	before_create { generate_token(:auth_token) }
  
  
	def generate_token(column)
		begin
		  self[column] = SecureRandom.urlsafe_base64
		end while User.exists?(column => self[column])
	end
	
	def send_password_reset
	  generate_token(:password_reset_token)
	  self.password_reset_sent_at = Time.zone.now
	  save!
	  UserMailer.password_reset(self).deliver
	end
	
  
end
