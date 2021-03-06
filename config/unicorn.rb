if ENV["RAILS_ENV"] == "production"
  worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
  timeout 15
  preload_app true
  listen "/var/www/capacitor/shared/tmp/sockets/unicorn.sock"
  pid "/var/www/capacitor/shared/tmp/pids/unicorn.pid"

  before_fork do |server, worker|
    Signal.trap 'TERM' do
      puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
      Process.kill 'QUIT', Process.pid
    end

    defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
  end

  after_fork do |server, worker|
    Signal.trap 'TERM' do
      puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
    end

    defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
  end
else
  worker_processes 1
end
