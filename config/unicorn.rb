# config/unicorn.rb
#worker_processes Integer(ENV["WEB_CONCURRENCY"] || 4)
worker_processes Integer(ENV['WEB_CONCURRENCY'] || 1)
timeout 60
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    Rails
      .logger.debug 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    Rails
      .logger.debug 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
