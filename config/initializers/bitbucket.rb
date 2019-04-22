
BitBucket.configure do |config|
  
  config.client_id     = ENV["BITBUCKET_APP_TOKEN"]
  config.client_secret = ENV["BITBUCKET_APP_SECRET"]

end
