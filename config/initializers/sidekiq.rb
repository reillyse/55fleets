conn  = Proc.new { Redis.new url: ENV["REDIS_URL"] }
Aws.eager_autoload!

begin
  Sidekiq.configure_client do |config|
    config.redis = ConnectionPool.new(size: 3, &conn)
  end
end
Sidekiq.default_worker_options = { 'backtrace' => true }


begin
  Sidekiq.configure_server do |config|
    config.redis = ConnectionPool.new(size: 7, &conn)
    config.on(:shutdown) do
      puts "Got TERM, shutting down process..."
      puts "we defo have to watch what we put here. We don't want to kill everything when we deploy a new version"

    end

  end
end
