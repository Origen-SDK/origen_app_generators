module <%= @namespace %>
  module <%= @domain_namespace %>
    # Generates a generic application shell
    class <%= @classname %> < <%= @parentclass %>

      desc "<%= @summary %>"

      # Any methods that are not protected will get invoked in the order that they are
      # defined when the generator is run, method naming is irrelevant unless you want
      # to override a method that is defined by the parent class
      
      def get_user_input
        # The methods to get the common user input that applies to all applications will
        # get called at the start automatically, you have a chance here to ask any additional
        # questions that are specific to the type of application being generated.
        # See the following links for some examples of how to ask questions:
        # https://github.com/Origen-SDK/origen_app_generators/blob/master/lib/origen_app_generators/base.rb#L94
        # https://github.com/Origen-SDK/origen_app_generators/blob/master/lib/origen_app_generators/plugin.rb#L44
      end

      def generate_files
        # Calling this will build all files, directories and symlinks contained in the
        # hash returned by the filelist method below
        build_filelist 
      end

      def modify_files
        # Here you can add or remove things post-generation.
        # Alternatively, you can copy any master file to the equivalent sub-directory of
        # templates/app_generators/<%= @domain_namespace.underscore %>/<%= @classname.underscore %>
        # and this will override the version in the master directory.
        #
        # However, post generation modification is recommended when possible since it means that your
        # generated applications will automatically stay up to date with any improvements made to the
        # master file.
        # The downside is that creating a post-generation modification takes a bit more effort to create
        # compared to simply copying and modifying the file manually.
        # To help with creating modifications, you have access to all of the Thor Action methods described here:
        # http://www.rubydoc.info/github/wycats/thor/Thor/Actions
        # See the enable method for an example of using these here:
        # https://github.com/Origen-SDK/origen_app_generators/blob/master/lib/origen_app_generators/new.rb#L25
      end

      def conclude
        # Print out anything you think the user should know about their new application at the end
        puts "New app created at: #{destination_root}"
      end

      protected

      # Defines the filelist for the generator, the default list is inherited from the
      # parent class (<%= @namespace %>::<%= @parentclass %>).
      # <% if @parentclass == 'Plugin' -%>  
      # Since this is a plugin generator, the default list of files comprises the application list,
      # which you can see here:
      # https://github.com/Origen-SDK/origen_app_generators/blob/master/lib/origen_app_generators/application.rb
      # And this is then modified by the base plugin generator which you can see here:
      # https://github.com/Origen-SDK/origen_app_generators/blob/master/lib/origen_app_generators/plugin.rb
      # Additionally, this application could have made further modifications to the default list
      # within lib/<%= @namespace.underscore %>/plugin.rb
<% else %>
      # See here for the default list of files included in an application:
      # https://github.com/Origen-SDK/origen_app_generators/blob/master/lib/origen_app_generators/application.rb
      # Additionally, this application could have made further modifications to the default list
      # within lib/<%= @namespace.underscore %>/application.rb
<% end -%>
      #
      # The filelist can contain references to generate files, directories or symlinks in the
      # new application.
      #
      # To make your generator more maintainable, try and re-use as much as possible
      # from the parent generator, this means that your generators will automatically stay up
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
end
