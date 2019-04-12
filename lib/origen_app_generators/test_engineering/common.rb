module OrigenAppGenerators
  module TestEngineering
    module Common
      def common_filelist(list)
        # Example of how to remove a file from the parent list
        # list.delete(:target_debug)
        # Example of how to add a file, in this case the file will be compiled and copied to
        # the same location in the new app
        list[:environment_v93k] = { source: 'environment/v93k.rb' }
        list[:environment_j750] = { source: 'environment/j750.rb' }
        list[:environment_uflex] = { source: 'environment/uflex.rb' }
        # Alternatively specifying a different destination, typically you would do this when
        # the final location is dynamic
        # list[:gemspec] = { source: 'gemspec.rb', dest: "#{@name}.gemspec" }
        # Example of how to create a directory
        # list[:pattern_dir] = { dest: 'pattern', type: :directory }
        # Example of how to create a symlink
        list[:environment_default] = { source: 'uflex.rb',           # Relative to the file being linked to
                                       dest:   'environment/default.rb', # Relative to destination_root
                                       type:   :symlink }
        # Test engineering source directories
        list[:patterns_dir] = { dest: 'app/patterns', type: :directory }
        list[:flows_dir]    = { dest: 'app/flows', type: :directory }
        # Remember to return the final list
        list
      end
    end
  end
end
