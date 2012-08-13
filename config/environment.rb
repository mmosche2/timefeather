# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Timefeather::Application.initialize!

# Constant Date Formats
Date::DATE_FORMATS[:dmdy] = "%a, %b %-d %Y"

# Constant Values
EXPECTED_DAILY_HOURS = 8

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "mail.gmail.com",
  :user_name            => "reply.to.experimentable@gmail.com",
  :password             => "questrial1",
  :authentication       => "plain",
  :enable_starttls_auto => true
}
