# config valid only for current version of Capistrano
lock '3.3.3'

def pid
  "`cat #{fetch(:unicorn_pid)}`"
end

set :application, 'tiyan_weixin'
set :repo_url, 'https://github.com/wehere/tiyan_weixin.git'
set :deploy_to, '/home/deploy/apps/tiyan_weixin'
# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5


set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log, "#{shared_path}/log/puma_access.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [0, 16]
set :puma_workers, 0
set :puma_init_active_record, true
set :puma_preload_app, true


set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "/home/deploy/pids/unicorn.pid"

namespace :unicorn do
  desc 'Stop Unicorn'
  task :stop do
    on roles(:app) do
      within current_path do
        if test("[ -e #{fetch(:unicorn_pid)} ]")
          execute :kill, "-s QUIT", pid
        else
          info "unicorn is not running..."
        end
      end
    end
  end

  desc 'Start Unicorn'
  task :start do
    on roles(:app) do
      within current_path do
        execute :bundle, "exec unicorn_rails", "-c", fetch(:unicorn_config), "-E", "production", "-D"
      end
    end
  end


  desc 'Restart Unicorn'
  task :restart
  before :restart, :stop
  before :restart, :start

end

namespace :deploy do

  after :finishing, 'deploy:cleanup'
  after :finishing, 'unicorn:restart'

end
