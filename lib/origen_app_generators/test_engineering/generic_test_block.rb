module OrigenAppGenerators
  module TestEngineering
    # Generates a generic plugin shell
    class GenericTestBlock < Plugin
      desc 'A generic test block'

      def generate_files
        @runtime_dependencies = [
          ['origen_testers', '>= 0.3.0.pre35']
        ]
        build_filelist
      end

      def add_requires
      fail "yo"
        prepend_to_file "lib/#{@name}.rb", "require 'origen_testers'\n"
      end

      def conclude
        puts "New test block created at: #{destination_root}"
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
      # master file to the equivalent sub-directory of templates/app_generators/test_engineering/mpg_test_block
      # which will override the version in the master directory.
      #
      # Additional files can be added or removed from the filelist as shown below.
      def filelist
        @filelist ||= begin
          list = super  # Always pick up the parent list
          # Example of how to remove a file from the parent list
          list.delete(:target_debug)
          list.delete(:target_production)
          # Example of how to add a file, in this case the file will be compiled and copied to
          # the same location in the new app
          list[:target_v93k] = { source: 'target/v93k.rb' }
          list[:target_j750] = { source: 'target/j750.rb' }
          list[:target_ultraflex] = { source: 'target/ultraflex.rb' }
          list[:program_prb1] = { source: 'program/prb1.rb' }
          list[:lib_interface] = { source: 'lib/interface.rb', dest: "lib/#{@name}/interface.rb" }
          # Alternatively specifying a different destination, typically you would do this when
          # the final location is dynamic
          # list[:gemspec] = { source: 'gemspec.rb', dest: "#{@name}.gemspec" }
          # Example of how to create a directory
          list[:pattern_dir] = { dest: 'pattern', type: :directory }
          # Example of how to create a symlink
          list[:target_default] = { source: 'j750.rb',          # Relative to the file being linked to
                                    dest:   'target/default.rb', # Relative to destination_root
                                    type:   :symlink }
          # Remember to return the final list
          list
        end
      end
    end
  end
end
