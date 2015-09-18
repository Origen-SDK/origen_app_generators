desc 'Create an application generator'
task :new do
  OrigenAppGenerators::New.start []
end

desc 'Test run the new app process'
task :test, [:set] do |t, args|
  _delete_tmp_dir
  if args[:set]
    vals = OrigenAppGenerators::TEST_INPUTS[args[:set].to_i]
    vals.pop # Throw away the test commands
    str = vals.map { |i| i == :default ? "\n" : "#{i}\n" }.join('')
    result = system "echo '#{str}' | rake test"
  else
    result = _execute_generator(:invoke)
  end
  exit 1 unless result
end

desc "Test run a specific generator: rake 'run[TestEngineering::GenericTestBlock]'"
task :run, [:generator_class] do |_t, args|
  _delete_tmp_dir
  begin
    klass = eval(args[:generator_class])
  rescue
    klass = eval("OrigenAppGenerators::#{args[:generator_class]}")
  end
  _execute_generator(klass)
end

desc 'Test that all generators build'
task :regression do
  OrigenAppGenerators::TEST_INPUTS.each do |inputs|
    # Test that origen and the console can boot in the new app
    commands = ['origen -v', 'origen lint', 'rake new_app_tests:load_target'] + inputs.pop
    if ENV['TRAVIS'] && ENV['CONTINUOUS_INTEGRATION']
      prefix = 'bundle && bundle exec '
    end
    str = inputs.map { |i| i == :default ? "\n" : "#{i}\n" }.join('')
    # Test the app can build
    unless system "echo '#{str}' | rake test"
      Origen.app.stats.report_fail
      exit 1
    end
    # Copy the new app test rake tasks to the new app
    t = File.expand_path("../new_app_tests.rake", Pathname.new(__FILE__).realpath)
    FileUtils.cp t, 'tmp/lib/tasks'
    # Test the app can boot
    Bundler.with_clean_env do
      Dir.chdir 'tmp' do
        commands.each do |command|
          unless system("#{prefix}#{command}")
            Origen.app.stats.report_fail
            exit 1
          end
        end
      end
    end
  end
  Origen.app.stats.report_pass
end

def _execute_generator(klass)
  # With the generator identified this now launches it in a standalone shell
  # This is to emulate how it will run in real life and cause it to fail if there are
  # any dependencies on running within an Origen app environment

  boot = "#{File.expand_path(File.dirname(__FILE__))}/boot.rb"
  origen_lib = "#{Origen.top}/lib"
  origen_lib = '/proj/mem_c40tfs_testeng/r49409/origen/lib'
  cmd = "#{boot} #{origen_lib} #{klass}"
  cmd = "ruby #{cmd}" if Origen.running_on_windows?
  # puts cmd
  result = false
  Bundler.with_clean_env do
    result = system cmd
  end
  result
end

def _delete_tmp_dir
  sh "rm -rf #{Origen.root}/tmp", verbose: false do |ok, _res|
    # Sometimes vim can lock a dir if the file is being viewed, trying again will
    # usually finish the job
    unless ok
      sh "rm -rf #{Origen.root}/tmp", verbose: false do |ok, _res|
        unless ok
          # I did my best!
        end
      end
    end
  end
end
