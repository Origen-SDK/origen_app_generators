module OrigenAppGenerators
  module TestEngineering
    # Generates a generic plugin shell
    class TestBlock < Plugin
      desc 'An IP test module intended to plugin into a top-level (SoC) application'

      def initialize(*args)
        @audience = :internal
        super
      end

      def get_user_input
        # The methods to get the common user input that applies to all applications will
        # get called at the start automatically, you have a chance here to ask any additional
        # questions that are specific to the type of application being generated
        get_ip_names
        get_sub_block_name
      end

      def generate_files
        @runtime_dependencies = [
          ['origen_testers', '>= 0.6.1']
        ]
        build_filelist
      end

      def add_requires
        prepend_to_file "lib/#{@name}.rb", "require 'origen_testers'\n"
      end

      def conclude
        puts "New test module created at: #{destination_root}"
      end

      protected

      def get_ip_names
        puts
        puts 'NAME THE IP BLOCKS THAT THIS MODULE WILL SUPPORT'
        puts
        puts "You don't need to name them all up front, but you must declare at least one."
        puts 'We recommend that you use the official name(s) for the IP(s) as used by your design team.'
        puts 'Separate multiple names with a comma:    FLASH_C40_512K, FLASH_C40_2M'
        puts

        valid = false
        until valid
          @ip_names = get_text(single: true).strip.split(',').map do |name|
            n = name.strip.symbolize.to_s.upcase
            unless n.empty?
              n
            end
          end.compact
          unless @ip_names.empty?
            # Should we check anything here?
            valid = true
          end
        end
        @ip_names
      end

      def get_sub_block_name
        puts
        puts "WHAT SHOULD BE THE PATH TO #{@ip_names.first} WHEN IT IS INSTANTIATED IN AN SOC?"
        puts
        puts 'Your IPs will be instantiated by a top-level (SoC) model, at which point it should be given a generic nickname'
        puts 'that will provide an easy way to access it.'
        puts 'For example, if you had an IP model for an NVM block, the IP name might be "FLASH_C40_512K_128K", but when it is'
        puts 'instantiated it would be given the name "flash", allowing it be easily accessed as "dut.flash".'
        puts

        valid = false
        until valid
          @sub_block_name = get_text(single: true).strip.split(',').map do |name|
            n = name.strip.symbolize.to_s.downcase
            unless n.empty?
              n
            end
          end.compact
          unless @sub_block_name.empty?
            # Should we check anything here?
            valid = true
          end
        end
        @sub_block_name = @sub_block_name.first
      end

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
          list[:target_default] = { source: 'target/default.rb' }
          list[:environment_v93k] = { source: 'environment/v93k.rb' }
          list[:environment_j750] = { source: 'environment/j750.rb' }
          list[:environment_ultraflex] = { source: 'environment/ultraflex.rb' }
          list[:program_prb1] = { source: 'program/prb1.rb' }
          list[:lib_interface] = { source: 'lib/interface.rb', dest: "lib/#{@name}/interface.rb" }
          # Alternatively specifying a different destination, typically you would do this when
          # the final location is dynamic
          # list[:gemspec] = { source: 'gemspec.rb', dest: "#{@name}.gemspec" }
          # Example of how to create a directory
          list[:pattern_dir] = { dest: 'pattern', type: :directory }
          # Example of how to create a symlink
          #list[:target_default] = { source: 'j750.rb',          # Relative to the file being linked to
          #                          dest:   'target/default.rb', # Relative to destination_root
          #                          type:   :symlink }
          list[:test_dut] = { source:  'lib/test/dut.rb',
                              dest:    "lib/#{@name}/test/dut.rb",
                              options: { class_name: @ip_names.first, sub_block_name: @sub_block_name }
                            }
          
          @ip_names.each_with_index do |name, i|
            list["ip_#{i}"] = { source:  'lib/model.rb',
                                dest:    "lib/#{@name}/#{name.underscore}.rb",
                                options: { name: name }
                              }

            list["ip_controller_#{i}"] = { source:  'lib/controller.rb',
                                           dest:    "lib/#{@name}/#{name.underscore}_controller.rb",
                                           options: { name: name }
                                         }

          end
          # Remember to return the final list
          list
        end
      end
    end
  end
end
