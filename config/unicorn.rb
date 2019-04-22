# config/unicorn.rb
#worker_processes Integer(ENV["WEB_CONCURRENCY"] || 4)
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 1)
timeout 60
preload_app true

before_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end


  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end


  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

end
