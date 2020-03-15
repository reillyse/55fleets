if (Rails.env.development?)
  REDIS = Redis.new url: ENV["REDIS_URL"], db: 2

else
  REDIS = Redis.new url: ENV["REDIS_URL"], db: 2
end
