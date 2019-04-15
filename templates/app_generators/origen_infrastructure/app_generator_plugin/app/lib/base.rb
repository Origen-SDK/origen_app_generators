module <%= @namespace %>
  # This is a mixin that is included in both the application and plugin
  # generators, it provides a place to add things that should apply to
  # all of your applications and plugins
  module Base
    # Any helper methods added to this base module will not be automatically invoked,
    # you must call them from either the top-level application or plugin generators,
    # or from a child generator.

    protected

    # Here you can modify the default list of files that are included in all of your
    # applications AND plugins.
    #
    # See here for the default list of files:
    # https://github.com/Origen-SDK/origen_app_generators/blob/master/lib/origen_app_generators/application.rb
    # If the child generator is a plugin, then this list is then modified by the base plugin generator which
    # you can see here:
    # https://github.com/Origen-SDK/origen_app_generators/blob/master/lib/origen_app_generators/plugin.rb
    #
    # The filelist can contain references to generate files, directories or symlinks in the
    # new application.
    #
    # To make your generators more maintainable, try and re-use as much as possible
    # from the parent generators, this means that your generator will automatically stay up
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
        # Example of how to recursively copy a directory
        # list[:copy_dir] = { source: 'src_dir', dest: 'dest_dir', type: :directory, copy: true }
        # Example of how to create a directory
        # list[:pattern_dir] = { dest: "pattern", type: :directory }
        # By default, directories created in this way will contain a .keep file, to inhibit this:
        # list[:pattern_dir] = { dest: "pattern", type: :directory, nokeep: true }
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
