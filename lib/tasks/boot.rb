#!/usr/bin/env ruby
# This is used to boot the generator in an environment with no
# Origen application loaded.
# This emulates how it will run when generating an app and means
# that any unintended dependencies on a real app environment will
# be highlighted during test.

# Path to Origen lib dir must be supplied as first arg
$LOAD_PATH.unshift ARGV[0]
$LOAD_PATH.unshift "#{File.expand_path(File.dirname(__FILE__))}/../"

require 'fileutils'
require 'origen'

# Prevent the bundle from loading by running this outside of the
if Origen.os.windows?
  tmp_dir = 'C:/tmp/origen_app_generators/new_app'
else
  tmp_dir = '/tmp/origen_app_generators/new_app'
end
FileUtils.rm_rf tmp_dir if File.exist?(tmp_dir)
FileUtils.mkdir_p tmp_dir

begin
  require 'origen'
  Dir.chdir tmp_dir do
    # For some reason this is not being defined by require origen anymore
    User = Origen::Users::User unless defined? User
    require 'byebug'
    require 'origen_app_generators'
    if ARGV[1] == 'invoke'
      OrigenAppGenerators.invoke('tmp')
    else
      eval(ARGV[1]).start ['tmp']
    end
  end
ensure
  FileUtils.mv "#{tmp_dir}/tmp", 'tmp' if File.exist?("#{tmp_dir}/tmp")
end
