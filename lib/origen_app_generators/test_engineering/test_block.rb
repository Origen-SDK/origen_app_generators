module OrigenAppGenerators
  module TestEngineering
    # Generates a generic plugin shell
    class TestBlock < Plugin
      include Common

      desc 'An IP test module intended to plugin into a top-level (SoC) application'

      def initialize(*args)
        @audience = :internal
        super
      end

      def get_user_input
        # The methods to get the common user input that applies to all applications will
        # get called at the start automatically, you have a chance here to ask any additional
        # questions that are specific to the type of application being generated
      end

      def generate_files
        @runtime_dependencies = [
          ['origen_testers', '>= 0.6.1']
        ]
        build_filelist
      end

      def final_modifications
        prepend_to_file "app/lib/#{@name}.rb", "require 'origen_testers'\n"
      end

      def conclude
        puts "New test module created at: #{destination_root}"
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
          list = common_filelist(super)  # Always pick up the parent list
          list
        end
      end
    end
  end
end
