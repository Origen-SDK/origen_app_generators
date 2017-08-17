module <%= @namespace %>
  # This will be the parent class of all of your application generators, it provides a place
  # to add anything that you want to be added to all of your applications
  class Application < OrigenAppGenerators::Application
    # Any methods added above the protected line will get automatically invoked
    # at the start of *all* of your application generators.

    protected

    # You can add helper methods that you want to make available to all of your application
    # generators here, these will not get called unless a child generator calls them.

    # Here you can modify the default list of files that are included in all of your applications.
    #
    # See here for the default list of files:
    # https://github.com/Origen-SDK/origen_app_generators/blob/master/lib/origen_app_generators/application.rb
    #
    # The filelist can contain references to generate files, directories or symlinks in the
    # new application.
    #
    # To make your generators more maintainable, try and re-use as much as possible
    # from the parent generator, this means that your generator will automatically stay up
    # to date with the latest conventions.
    #
    # Additional files can be added or removed from the filelist as shown below.
    def filelist
      @filelist ||= begin
        list = super  # Always pick up the parent list
        # Example of how to remove a file from the parent list
        # list.delete(:web_doc_layout)
        # Example of how to add a file, in this case the file will be compiled and copied to
        # the same location in the new app
        # list[:config_shared_commands] = { source: 'config/shared_commands.rb' }
        # Alternatively specifying a different destination, typically you would do this when
        # the final location is dynamic
        # list[:gemspec] = { source: 'gemspec.rb', dest: "#{@name}.gemspec" }
        # Example of how to create a directory
        # list[:pattern_dir] = { dest: "pattern", type: :directory }
        # Example of how to create a symlink
        # list[:target_default] = { source: 'debug.rb',          # Relative to the file being linked to
        #                           dest:   'target/default.rb', # Relative to destination_root
        #                           type:   :symlink }
        # Remember to return the final list
        list
      end
    end
  end
end
