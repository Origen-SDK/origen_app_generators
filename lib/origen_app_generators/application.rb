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
        doc_history:        { source: 'doc/history' },
        target_default:     { source: 'target/default.rb' },
        # target_default:     { source: 'debug.rb',          # Relative to the file being linked to
        #                      dest:   'target/default.rb', # Relative to destination_root
        #                      type:   :symlink },
        environment_dir:    { dest: 'environment', type: :directory },
        lib_module:         { source: 'lib/module.rb',
                              dest:   "lib/#{@name}.rb" },
        # lib_top_level:      { source: 'lib/top_level.rb',
        #                      dest:   "lib/#{@name}/top_level.rb" },
        lib_tasks:          { source: 'lib/app.rake',
                              dest:   "lib/tasks/#{@name}.rake" },
        spec_helper:        { source: 'spec/spec_helper.rb' },
        # web_index:          { source: 'templates/web/index.md.erb' },
        # web_basic_layout:   { source: 'templates/web/layouts/_basic.html.erb' },
        # web_doc_layout:     { source: 'templates/web/layouts/_doc.html.erb' },
        # web_navbar:         { source: 'templates/web/partials/_navbar.html.erb' },
        # web_references:     { source: 'templates/web/references.md.erb' },
        # web_archive:        { source: 'templates/web/archive.md.erb' },
        # web_contact:        { source: 'templates/web/contact.md.erb' },
        # web_release_notes:  { source: 'templates/web/release_notes.md.erb' },
        # web_defintions:     { source: 'templates/web/docs/environment/definitions.md.erb' },
        # web_installation:   { source: 'templates/web/docs/environment/installation.md.erb' },
        # web_introduction:   { source: 'templates/web/docs/environment/introduction.md.erb' },
        rakefile:           { source: 'Rakefile' },
        gemfile:            { source: 'Gemfile' },
        gitignore:          { source: '.gitignore' },
        irbrc:              { source: '.irbrc' },
        rspec:              { source: '.rspec' },
        # This sets the default mode of the new workspace to 'debug'
        session:            { source: 'origen_core_session',
                              dest:   '.session/origen_core',
                              copy:   true
                            }
      }
    end
  end
end
