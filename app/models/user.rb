class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :company_id, :name, :start_date, :end_date, :active
  has_secure_password
  
  belongs_to :company
  has_many :entries
  has_many :relationships, :dependent => :destroy
  has_many :staffed_projects, :through => :relationships, :source => :project
  
  validates :email,
				:presence 	=> true,
				:uniqueness => { :case_sensitive => false },
				:format 	=> { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
	
	validates_presence_of :password, :on => :create
	validates_presence_of :password_confirmation, :on => :create
	
	before_create { generate_token(:auth_token) }
  
  
  
  def staffed?(project)
    relationships.find_by_project_id(project.id)
  end

  def staff!(project, rate, staffingstart, staffingend, budgeted_hrs)
    relationships.create!(project_id: project.id, rate: rate, staffing_start: staffingstart, staffing_end: staffingend,
                          budgeted_hrs: budgeted_hrs)
  end

  def unstaff!(project)
    relationships.find_by_project_id(project.id).destroy
  end
  
  
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
