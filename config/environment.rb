# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Initialize the Rails application.
ENV['AWS_REGION'] = 'us-east-1'

ENV['default_ami'] = 'ami-04788916c74e6f3a2'

Rails.application.configure { config.log_tags = %i[uuid remote_ip] }
