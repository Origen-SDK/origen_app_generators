require 'origen'
class OrigenAppGeneratorsApplication < Origen::Application
  # This information is used in headers and email templates, set it specific
  # to your application
  config.name     = "Origen App Generators"
  config.initials = "Origen_App_Generators"
  config.rc_url   = "ssh://git@github.com:Origen-SDK/origen_app_generators.git"

  # To enable deployment of your documentation to a web server (via the 'origen web'
  # command) fill in these attributes. The example here is configured to deploy to
  # the origen.freescale.net domain, which is an easy option if you don't have another
  # server already in mind. To do this you will need an account on CDE and to be a member
  # of the 'origen' group.
  config.web_directory = "/proj/.web_origen/html/origen_app_generators"
  config.web_domain = "http://origen-sdk.org/origen_app_generators"

  # When false Origen will be less strict about checking for some common coding errors,
  # it is recommended that you leave this to true for better feedback and easier debug.
  # This will be the default setting in Origen v3.
  config.strict_errors = true

  # See: http://origen.freescale.net/origen/latest/guides/utilities/lint/
  config.lint_test = {
    # Require the lint tests to pass before allowing a release to proceed
    run_on_tag: true,
    # Auto correct violations where possible whenever 'origen lint' is run
    auto_correct: true, 
    # Limit the testing for large legacy applications
    #level: :easy,
    # Run on these directories/files by default
    #files: ["lib", "config/application.rb"],
  }

  # Versioning is based on a timestamp by default, if you would rather use semantic
  # versioning, i.e. v1.0.0 format, then set this to true.
  # In parallel go and edit config/version.rb to enable the semantic version code.
  config.semantically_version = true

  # An example of how to set application specific LSF parameters
  #config.lsf.project = "msg.te"
  
  # An example of how to specify a prefix to add to all generated patterns
  #config.pattern_prefix = "nvm"

  # An example of how to add header comments to all generated patterns
  #config.pattern_header do
  #  cc "This is a pattern created by the example origen application"
  #end

  # By default all generated output will end up in ./output.
  # Here you can specify an alternative directory entirely, or make it dynamic such that
  # the output ends up in a setup specific directory. 
  #config.output_directory do
  #  "#{Origen.root}/output/#{$dut.class}"
  #end

  # Similary for the reference files, generally you want to setup the reference directory
  # structure to mirror that of your output directory structure.
  #config.reference_directory do
  #  "#{Origen.root}/.ref/#{$dut.class}"
  #end
 
  # This will automatically deploy your documentation after every tag
  #def after_release_email(tag, note, type, selector, options)
  #  deployer = Origen.app.deployer
  #  if deployer.running_on_cde? && deployer.user_belongs_to_origen?
  #    command = "origen web compile --remote --api"
  #    if Origen.app.version.production?
  #      command += " --archive #{Origen.app.version}"
  #    end
  #    Dir.chdir Origen.root do
  #      system command
  #    end
  #  end 
  #end

  # Ensure that all tests pass before allowing a release to continue
  #def validate_release
  #  if !system("origen specs") || !system("origen examples")
  #    puts "Sorry but you can't release with failing tests, please fix them and try again."
  #    exit 1
  #  else
  #    puts "All tests passing, proceeding with release process!"
  #  end
  #end

  # To enabled source-less pattern generation create a class (for example PatternDispatcher)
  # to generate the pattern. This should return false if the requested pattern has been
  # dispatched, otherwise Origen will proceed with looking up a pattern source as normal.
  #def before_pattern_lookup(requested_pattern)
  #  PatternDispatcher.new.dispatch_or_return(requested_pattern)
  #end

  # If you use pattern iterators you may come accross the case where you request a pattern
  # like this:
  #   origen g example_pat_b0.atp
  #
  # However it cannot be found by Origen since the pattern name is actually example_pat_bx.atp
  # In the case where the pattern cannot be found Origen will pass the name to this translator
  # if it exists, and here you can make any substitutions to help Origen find the file you 
  # want. In this example any instances of _b\d, where \d means a number, are replaced by
  # _bx.
  #config.pattern_name_translator do |name|
  #  name.gsub(/_b\d/, "_bx")
  #end

  # If you want to use pattern iterators, that is the ability to generate multiple pattern
  # variants from a single source file, then you can define the required behavior here.
  # The examples below implement some of the iterators that were available in Origen 1,
  # you can remove them if you don't want to use them, or of course modify or add new 
  # iterators specific to your application logic.
  
  # By setting iterator
  config.pattern_iterator do |iterator|
    # Define a key that you will use to enable this in a pattern, here the iterator
    # can be enabled like this: Pattern.create(by_setting: [1,2,3]) do
    iterator.key = :by_setting

    # The value passed from the pattern via the key comes in here as the first
    # argument, the name applied here can be anything, but settings seem reasonable since
    # an array of setting values is expected.
    # The last argument &pattern is mandatory and represents the pattern block (the bit contained
    # within Pattern.create do ... end)
    iterator.loop do |settings, &pattern|
      # Implement the loop however you like, here we loop for each value in the array
      settings.each do |setting|
        # Now call the pattern passing in the setting argument, this would be captured
        # in the pattern like this:
        #   Pattern.create do |setting|
        pattern.call(setting)
      end
    end

    # Each pattern iteration needs a unique name, otherwise Origen will simply overwrite 
    # the same output file each time.
    # The base pattern name and the pattern argument, in this case the setting, will be
    # passed in here and whatever is returned is what will be used as the name.
    iterator.pattern_name do |name, setting|
      # Substiture _x in the name with the setting, _1, _2, etc.
      name.gsub("_x", "_#{setting}")
    end
  end


end
