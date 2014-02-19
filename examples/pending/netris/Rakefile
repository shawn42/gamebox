libdir = File.dirname(__FILE__)+"/lib"
$: << libdir
confdir = File.dirname(__FILE__)+"/config"
$: << confdir

require 'environment'
$: << GAMEBOX_PATH
load "tasks/gamebox_tasks.rake"
STATS_DIRECTORIES = [
  %w(Source            src/), 
  %w(Config            config/), 
  %w(Maps              maps/), 
  %w(Unit\ tests       specs/),
  %w(Libraries         lib/),
].collect { |name, dir| [ name, "#{APP_ROOT}/#{dir}" ] }.select { |name, dir| File.directory?(dir) }

