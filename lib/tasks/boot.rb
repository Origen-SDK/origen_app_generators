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

# Prevent the bundle from loading by running this outside of the
if RUBY_PLATFORM == 'i386-mingw32'
  tmp_dir = 'C:/tmp/origen_app_generators/new_app'
else
  tmp_dir = '/tmp/origen_app_generators/new_app'
end
FileUtils.rm_rf tmp_dir if File.exist?(tmp_dir)
FileUtils.mkdir_p tmp_dir

begin
  Dir.chdir tmp_dir do
    require 'origen'
    # For some reason this is not being defined by required origen anymore
    User = Origen::Users::User unless defined? User
    if RUBY_VERSION >= '2.0.0'
      gem 'byebug', '~>3.5'
    else
      gem 'debugger', '~>1.6'
    end
    require 'origen_app_generators'
    if ARGV[1] == 'invoke'
      OrigenAppGenerators.invoke('tmp')
    else
      eval(ARGV[1]).start ['tmp']
    end
  end
ensure
  system "mv #{tmp_dir}/tmp tmp"
end
