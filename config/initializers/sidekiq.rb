# conn  = Proc.new {  REDIS}
conn = proc { Redis.new url: ENV['REDIS_URL'] }
Aws.eager_autoload!

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 3, &conn)
end

Sidekiq.default_worker_options = { 'backtrace' => true }

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 7, &conn)
  config.on(:shutdown) do
    Rails.logger.debug 'Got TERM, shutting down process...'
    Rails
      .logger.debug "we defo have to watch what we put here. We don't want to kill everything when we deploy a new version"
  end
end
