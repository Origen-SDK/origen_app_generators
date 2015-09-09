module OrigenAppGenerators
  module TestEngineering
    # Generates a generic application shell
    class StandAloneApplication < Application
      desc 'A stand alone test engineering application'

      # Any methods that are not protected will get invoked in the order that they are
      # defined when the generator is run, method naming is irrelevant unless you want
      # to override a method that is defined by the parent class

      def get_user_input
        # The methods to get the common user input that applies to all applications will
        # get called at the start automatically, you have a chance here to ask any additional
        # questions that are specific to the type of application being generated
        get_top_level_names
        get_sub_block_names
      end

      def generate_files
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

      def get_top_level_names
        puts
        puts 'NAME YOUR TOP-LEVEL DEVICE(S)'
        puts
        puts 'What do you want to call the top-level class that represents your device?'
        puts 'By default it will be called TopLevel, but if you want this application to support multiple devices you should'
        puts 'give them unique names.'
        puts 'Separate multiple names with a comma:    Falcon, Eagle, Vulture'
        puts

        valid = false
        until valid
          @top_level_names = get_text(single: true, default: 'TopLevel').strip.split(',').map do |name|
            name.strip.gsub(/\s+/, '_').camelize
          end
          unless @top_level_names.empty?
            # Should we check anything here?
            valid = true
          end
        end
        @top_level_names
      end

      def get_sub_block_names
        puts
        puts 'DEFINE YOUR SUB-BLOCKS'
        puts
        puts 'What sub-blocks does this device contain?'
        puts 'You can leave this blank, but entering some details of the sub-blocks you will want to involve in your tests'
        puts 'will save you some manual setup of the associated models and controllers.'
        puts 'You can specify layers of hierarchy and multiple instantiations, here are some examples:'
        puts
        puts '  A RAM, OSC, PLL and 2 ATDs at the top-level:    ram, osc, pll, atd(2)'
        puts '  With 3 com blocks with embedded components:     ram, osc, pll, atd(2), com[ram(2), osc](3)'
        if @top_level_names.size > 1
          puts
          puts 'If you want different modules for each of your top-level devices you can do:'
          puts
          puts "  #{@top_level_names[0]}[ram, atd(2)], #{@top_level_names[1]}[ram(2), atd(4)]"
        end
        puts

        valid = false
        until valid
          @top_level_names = get_text(single: true).strip.split(',').map do |name|
            name.strip.gsub(/\s+/, '_').camelize
          end
          unless @top_level_names.empty?
            # Should we check anything here?
            valid = true
          end
        end
        @top_level_names
      end

      # Defines the filelist for the generator, the default list is inherited from the
      # parent class (Application).
      # The filelist can contain references to generate files, directories or symlinks in the
      # new application.
      #
      # Generally to make your generator more maintainable try and re-use as much as possible
      # from the parent generator, this means that your generator will automatically stay up
      # to date with the latest conventions
      #
      # The master templates live in templates/app_generators/application, but
      # DO NOT MODIFY THESE FILES DIRECTLY.
      # Either add or remove things post-generation in the modify_files method or copy the
      # master file to the equivalent sub-directory of templates/app_generators/test_engineering/generic_stand_alone_application
      # which will override the version in the master directory.
      #
      # Additional files can be added or removed from the filelist as shown below.
      def filelist
        @filelist ||= begin
          list = super  # Always pick up the parent list
          # Example of how to remove a file from the parent list
          # list.delete(:web_doc_layout)
          # Example of how to add a file, in this case the file will be compiled and copied to
          # the same location in the new app
          list[:top_level_controller] = { source: 'lib/top_level_controller.rb',
                                          dest:   "lib/#{@name}/top_level_controller.rb" }
          list[:environment_j750] = { source: 'environment/j750.rb' }
          list[:environment_uflex] = { source: 'environment/uflex.rb' }
          list[:environment_v93k] = { source: 'environment/v93k.rb' }
          # Alternatively specifying a different destination, typically you would do this when
          # the final location is dynamic
          # list[:gemspec] = { source: 'gemspec.rb', dest: "#{@name}.gemspec" }
          # Example of how to create a directory
          # list[:pattern_dir] = { dest: "pattern", type: :directory }
          # Example of how to create a symlink
          list[:environment_default] = { source: 'j750.rb',          # Relative to the file being linked to
                                         dest:   'environment/default.rb', # Relative to destination_root
                                         type:   :symlink }
          # Remember to return the final list
          list
        end
      end
    end
  end
end
