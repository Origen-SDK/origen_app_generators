module OrigenAppGenerators
  # The base generator class that should be used by all application generators
  class Application < Base
    # Any methods that are not protected will get invoked in the order they are
    # defined when the generator is run

    protected

    def type
      :application
    end

    # This is the default list of files that will get generated for a new application
    # when you call the compile_filelist method.
    # To customize this for a domain specific application generator you can either
    # delete an entry:
    #
    #   filelist.delete(:config_application)
    #   compile_filelist
    #
    # Or point it to a different template, the supplied path is relative to templates/app_generators
    #
    #   filelist[:config_application][:source] = "dng_test_app/config/application.rb"
    #   compile_filelist
    def filelist
      fail '@name must be defined before calling filelist for the first time' unless @name
      @filelist ||= {
        config_application: { source: 'config/application.rb' },
        config_version:     { source: 'config/version.rb' },
        config_boot:        { source: 'config/boot.rb' },
        config_commands:    { source: 'config/commands.rb' },
        config_dev:         { source: 'config/maillist_dev.txt' },
        config_prod:        { source: 'config/maillist_prod.txt' },
        doc_history:        { source: 'doc/history' },
        target_default:     { source: 'target/default.rb' },
        # target_default:     { source: 'debug.rb',          # Relative to the file being linked to
        #                      dest:   'target/default.rb', # Relative to destination_root
        #                      type:   :symlink },
        environment_dir:    { dest: 'environment', type: :directory },
        lib_module:         { source: 'app/lib/module.rb',
                              dest:   "app/lib/#{@name}.rb" },
        lib_module_dir:     { dest:   "app/lib/#{@name}", type: :directory },
        models_dir:         { dest:   'app/models', type: :directory },
        controllers_dir:    { dest:   'app/controllers', type: :directory },
        patterns_dir:       { dest:   'app/patterns', type: :directory },
        flows_dir:          { dest:   'app/flows', type: :directory },
        app_pins:           { source: "#{Origen.top}/templates/code_generators/pins.rb",
                              dest:   'app/pins/application.rb' },
        app_timesets:       { source: "#{Origen.top}/templates/code_generators/timesets.rb",
                              dest:   'app/timesets/application.rb' },
        app_parameters:     { source: "#{Origen.top}/templates/code_generators/parameters.rb",
                              dest:   'app/parameters/application.rb' },
        spec_helper:        { source: 'test/spec/spec_helper.rb' },
        web_index:          { source: 'app/templates/web/index.md.erb' },
        web_basic_layout:   { source: 'app/templates/web/layouts/_basic.html.erb' },
        web_navbar:         { source: 'app/templates/web/partials/_navbar.html.erb' },
        web_release_notes:  { source: 'app/templates/web/release_notes.md.erb' },
        rakefile:           { source: 'Rakefile' },
        gemfile:            { source: 'Gemfile' },
        gitignore:          { source: '.gitignore' },
        irbrc:              { source: '.irbrc' },
        rspec:              { source: '.rspec' },
        # This sets the initial mode of the new workspace to 'debug'
        session:            { source: 'origen_core_session',
                              dest:   '.session/origen_core',
                              copy:   true
                            }
      }
    end
  end
end
