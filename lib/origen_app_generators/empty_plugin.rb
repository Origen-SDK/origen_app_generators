module OrigenAppGenerators
  # Generates a generic plugin shell
  class EmptyPlugin < Plugin
    # Any methods that are not protected will get invoked in the order they are
    # defined when the generator is run

    def generate_files
      build_filelist
    end

    def conclude
      puts "New app created at: #{destination_root}"
    end
  end
end
