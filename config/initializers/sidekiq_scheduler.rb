require 'sidekiq/scheduler'
begin
  Sidekiq.schedule = YAML.load_file(File.expand_path("../../../config/schedule.yml",__FILE__))
end
