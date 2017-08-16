# The requested command is passed in here as @command
case @command

when "app_gen:test"
  options = {}

  opt_parser = OptionParser.new do |opts|
    opts.banner = <<-END
Test the generators by emulating the 'origen new' command execution and building the new
application into the tmp directory.

Usage: origen app_gen:test [options]
END
    opts.on('-d', '--debugger', 'Enable the debugger') {  options[:debugger] = true }
    opts.on('-i', '--inputs INDEX', Integer, "Apply the set of test inputs defined in #{Origen.app.namespace}::TEST_INPUTS[INDEX]") { |f| options[:inputs] = f }
    opts.on('-r', '--regression', "Run all sets of test inputs defined in #{Origen.app.namespace}::TEST_INPUTS[INDEX]") { options[:regression] = true }
    opts.on('-a', '--all_generators', "Include the generators from Origen core") { options[:all_generators] = true }
    opts.separator ''
    opts.on('-h', '--help', 'Show this message') { puts opts; exit }
  end

  opt_parser.orig_parse! ARGV

  FileUtils.rm_rf "#{Origen.root}/tmp" if File.exist?("#{Origen.root}/tmp")

  if options[:inputs] || options[:regression]
    if options[:regression]
      inputs = Origen.app.namespace.constantize::TEST_INPUTS
    else
      inputs = [Origen.app.namespace.constantize::TEST_INPUTS[options[:inputs].to_i]]
    end

    if ENV['TRAVIS'] && ENV['CONTINUOUS_INTEGRATION']		
      prefix = 'bundle && bundle exec '		
    end

    overall_fail = false

    inputs.each do |vals|
      test_failed = false
      post_build_operations = Array(vals.pop)
      target_load_test_required = false
      post_build_operations = post_build_operations.map do |op|
        if op.to_s == 'default'
          target_load_test_required = true
          ['origen -v',
           'origen lint',
           'bundle exec rake new_app_tests:load_target',
           'origen web compile --no-serve'
          ]
        elsif op.to_s == 'load_target'
          target_load_test_required = true
          'rake new_app_tests:load_target'
        else
          op
        end
      end.flatten

      str = vals.map { |i| i == :default ? "\n" : "#{i}\n" }.join('')
      cmd = "#{prefix} origen app_gen:test"
      cmd += ' --debugger' if options[:debugger]
      cmd += ' --all_generators' if options[:all_generators]
      passed = false
      Bundler.with_clean_env do
        puts cmd
        passed = system "echo '#{str}' | #{cmd}"
      end

      if passed
        # The app is successfully built, now see if it works...
        unless post_build_operations.empty?
          if target_load_test_required
            FileUtils.cp "#{Origen.root!}/lib/tasks/new_app_tests.rake", 'tmp/lib/tasks'
          end

          operation_failed = false
          Bundler.with_clean_env do
            Dir.chdir "#{Origen.root}/tmp" do
              post_build_operations.each_with_index do |op, i|
                Origen.log.info "Running command: #{op}"
                if system("#{prefix}#{op}")
                  Origen.log.success "Command passed: #{op}"
                else
                  Origen.log.error "Command failed: #{op}"
                  operation_failed = true
                end
              end
            end
          end

          if operation_failed
            if options[:regression]
              overall_fail = true
            else
              Origen.app.stats.report_fail
              exit 1
            end
          end
        end
      else
        Origen.log.error "The generator failed to build!"
        if options[:regression]
          overall_fail = true
        else
          Origen.app.stats.report_fail
          exit 1
        end
      end
    end

    if options[:regression] && overall_fail
      Origen.app.stats.report_fail
      exit 1
    else
      Origen.app.stats.report_pass
      exit 0
    end

  else

    # Launch the generator in a standalone shell, 
    # this is to emulate how it will run in real life and cause it to fail if there are
    # any dependencies on running within an Origen app environment
    boot = "#{Origen.root!}/bin/boot.rb"
    origen_lib = "#{Origen.top}/lib"
    app_gen_lib = "#{Origen.root!}/lib"
    app_lib = "#{Origen.root}/lib"
    load_generators = "#{Origen.root}/config/load_generators.rb"
    cmd = "#{boot} #{origen_lib} #{app_gen_lib} #{app_lib} #{load_generators}"
    cmd = "#{cmd} true" if options[:all_generators] || Origen.app.name == :origen_app_generators
    cmd = "ruby #{cmd}" if Origen.os.windows?
    # puts cmd
    passed = false
    Bundler.with_clean_env do
      passed = system cmd
    end
    exit passed ? 0 : 1
  end

when "app_gen:new"
  options = {}

  opt_parser = OptionParser.new do |opts|
    opts.banner = <<-END
Create a new application generator.

Usage: origen app_gen:new [options]
END
    opts.on('-d', '--debugger', 'Enable the debugger') {  options[:debugger] = true }
    opts.separator ''
    opts.on('-h', '--help', 'Show this message') { puts opts; exit }
  end

  opt_parser.orig_parse! ARGV

  OrigenAppGenerators::New.start []
  exit 0

# Always leave an else clause to allow control to fall back through to the Origen command handler.
# You probably want to also add the command details to the help shown via 'origen -h',
# you can do this bb adding the required text to @plugin_commands before handing control back to
# Origen.
else
  @plugin_commands << <<-EOT
 app_gen:test Test run the 'origen new' command operation using your latest generators
 app_gen:new  Create a new application or plugin generator
  EOT

end
