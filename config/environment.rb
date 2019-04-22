# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
ENV["AWS_REGION"] = "us-east-1"




ENV["default_ami"] = "ami-04788916c74e6f3a2"

Rails.application.initialize!

Rails.application.configure do
  config.log_tags = [:uuid, :remote_ip]
end
