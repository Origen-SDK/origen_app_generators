module OrigenAppGenerators
  module OrigenInfrastructure
    # Generates a generic application shell
    class AppGeneratorPlugin < Plugin
      desc "A plugin to make your own application templates available through the 'origen new' command"

      def initialize(*args)
        @audience = :internal
        super
      end

      # Any methods that are not protected will get invoked in the order that they are
      # defined when the generator is run, method naming is irrelevant unless you want
      # to override a method that is defined by the parent class

      def get_user_input
        # The methods to get the common user input that applies to all applications will
        # get called at the start automatically, you have a chance here to ask any additional
        # questions that are specific to the type of application being generated
      end

      def generate_files
        @runtime_dependencies = [
          ['origen_app_generators', ">= #{Origen.app!.version}"]
        ]
        @post_runtime_dependency_comments = [
          'DO NOT ADD ANY ADDITIONAL RUNTIME DEPENDENCIES HERE, WHEN THESE GENERATORS',
          'ARE INVOKED TO GENERATE A NEW APPLICATION IT WILL NOT BE LAUNCHED FROM WITHIN',
          'A BUNDLED ENVIRONMENT.',
          '',
          'THEREFORE GENERATORS MUST NOT RELY ON ANY 3RD PARTY GEMS THAT ARE NOT',
          'PRESENT AS PART OF A STANDARD ORIGEN INSTALLATION - I.E. YOU CAN ONLY RELY',
          'ON THE GEMS THAT ORIGEN ITSELF DEPENDS ON.'
        ]
        # Calling this will build all files, directories and symlinks contained in the
        # hash returned by the filelist method
        build_filelist
      end

      def modify_files
        # If you want to modify any of the generated files you can do so now, you have access
        # to all of the Thor Action methods described here:
        # http://www.rubydoc.info/github/wycats/thor/Thor/Actions
        # See the enable method in lib/app_generators/new.rb for some examples of using these.
      end

      def conclude
        # Print out anything you think the user should know about their new application at the end
        puts "New app created at: #{destination_root}"
      end

      protected

      # Defines the filelist for the generator, the default list is inherited from the
      # parent class (Plugin).
      # The filelist can contain references to generate files, directories or symlinks in the
      # new application.
      #
      # Generally to make your generator more maintainable try and re-use as much as possible
      # from the parent generator, this means that your generator will automatically stay up
      # to date with the latest conventions
      #
      # The master templates live in templates/app_generators/plugin, but
      # DO NOT MODIFY THESE FILES DIRECTLY.
      # Either add or remove things post-generation in the modify_files method or copy the
      # master file to the equivalent sub-directory of templates/app_generators/origen_infrastructure_engineering/app_generator_plugin
      # which will override the version in the master directory.
      #
      # Additional files can be added or removed from the filelist as shown below.
      def filelist
        @filelist ||= begin
          list = super  # Always pick up the parent list
          # Example of how to remove a file from the parent list
          # list.delete(:web_doc_layout)
          list.delete(:lib_readme)
          list.delete(:lib_readme_dev)
          # Example of how to add a file, in this case the file will be compiled and copied to
          # the same location in the new app
          # list[:config_shared_commands] = { source: 'config/shared_commands.rb' }
          list[:config_load_generators] = { source: 'config/load_generators.rb' }
          list[:lib_plugin] = { source: 'lib/plugin.rb' }
          list[:lib_application] = { source: 'lib/application.rb' }
          # Alternatively specifying a different destination, typically you would do this when
          # the final location is dynamic
          # list[:gemspec] = { source: 'gemspec.rb', dest: "#{@name}.gemspec" }
          # Example of how to create a directory
          # list[:pattern_dir] = { dest: "pattern", type: :directory }
          # Example of how to create a symlink
          # list[:target_default] = { source: 'debug.rb',          # Relative to the file being linked to
          #                          dest:   'target/default.rb', # Relative to destination_root
          #                          type:   :symlink }
          # Remember to return the final list
          list
        end
      end
    end
  end
end
