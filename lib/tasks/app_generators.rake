desc 'Create an application generator'
task :new do
  OrigenAppGenerators::New.start []
end

desc 'Test run the new app process'
task :test do
  _delete_tmp_dir
  _execute_generator(:invoke)
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

def _execute_generator(klass)
  # With the generator identified this now launches it in a standalone shell
  # This is to emulate how it will run in real life and cause it to fail if there are
  # any dependencies on running within an Origen app environment

  boot = "#{File.expand_path(File.dirname(__FILE__))}/boot.rb"
  origen_lib = "#{Origen.top}/lib"
  cmd = "#{boot} #{origen_lib} #{klass}"
  cmd = "ruby #{cmd}" if Origen.running_on_windows?
  # puts cmd
  Bundler.with_clean_env do
    system cmd
  end
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
