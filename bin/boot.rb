#!/usr/bin/env ruby
# This is used to boot the generator in an environment with no
# Origen application loaded.
# This emulates how it will run when generating an app and means
# that any unintended dependencies on a real app environment will
# be highlighted during test.

$LOAD_PATH.unshift ARGV.shift
$LOAD_PATH.unshift ARGV.shift
$LOAD_PATH.unshift ARGV.shift

require 'fileutils'
require 'origen'

# Prevent the bundle from loading by running this outside of the
if Origen.os.windows?
  tmp_dir = 'C:/tmp/my_app_generators/new_app'
else
  tmp_dir = '/tmp/my_app_generators/new_app'
end
FileUtils.rm_rf tmp_dir if File.exist?(tmp_dir)
FileUtils.mkdir_p tmp_dir

begin
  Dir.chdir tmp_dir do
    # For some reason this is not being defined by require origen anymore
    User = Origen::Users::User unless defined? User
    #require 'byebug'
    require 'origen_app_generators'
    load_generators = ARGV.shift
    OrigenAppGenerators.unload_generators unless ARGV[0]
    require load_generators if File.exist?(load_generators)

    OrigenAppGenerators.invoke('tmp')
  end
ensure
  FileUtils.mv "#{tmp_dir}/tmp", 'tmp' if File.exist?("#{tmp_dir}/tmp")
end
