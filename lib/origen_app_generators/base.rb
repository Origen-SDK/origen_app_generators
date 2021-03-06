module OrigenAppGenerators
  # This is the base generator used by all generators in this application
  class Base < Origen::CodeGenerators::Base
    include Origen::Utility::InputCapture

    require 'gems'

    def validate_application_name
      @name = args.first.to_s.strip
      if @name == ''
        puts
        puts "You must supply a name for what you want to call your application: 'origen new my_name'"
        puts
        exit 1
      elsif @name != @name.symbolize.to_s
        puts
        puts 'The name of your new app must be lowercased and underscored and contain no special characters'
        puts
        exit 1
      end
    end

    def set_source_paths
      # The base Origen generator puts the Origen core directory on the source path, in retrospect this
      # was a bad idea and makes for hard to debug errors if an app generator resolves a template from
      # outside of this app.
      # So to keep things sane remove any inherited source paths.
      self.class.source_paths.pop until self.class.source_paths.empty?
      klass = self.class

      until klass == OrigenAppGenerators::Base
        if template_dir = OrigenAppGenerators.template_dirs[klass]
          dir = []
          last_class = nil
          until klass.to_s =~ /^OrigenAppGenerators/
            dir << "#{template_dir}/#{class_dir(klass)}"
            last_class = klass
            klass = klass.superclass
          end
          dir << "#{template_dir}/base"
          klass = last_class
        else
          dir = []
          class_dirs(klass).each do |class_dir|
            dir << "#{Origen.root!}/templates/app_generators/#{class_dir}"
            dir << "#{Origen.root!}/app/templates/app_generators/#{class_dir}"
          end
        end
        Array(dir).each do |dir|
          self.class.source_paths << dir if File.exist?(dir) && !self.class.source_paths.include?(dir)
        end
        klass = klass.superclass
      end
    end

    # Just makes the type (:plugin or :application) available to all templates
    def set_type
      @type = type
    end

    def get_common_user_input
      # Don't bother asking the user for this, their life will be easier if they just go with
      # Origen's default namespace based on their app's name
      @namespace = @name.to_s.camelize
    end

    def get_lastest_origen_version
      @latest_origen_version ||= begin
        (Gems.info 'origen')['version']
      rescue
        # If the above fails, e.g. due to an SSL error in the runtime environment, try to fetch the
        # latest Origen version from the Origen website, before finally falling back to the version
        # we are currently running if all else fails
        begin
          require 'httparty'
          response = HTTParty.get('http://origen-sdk.org/origen/release_notes/')
          version = Origen::VersionString.new(response.body.match(/Tag: v(\d+\.\d+.\d+)</).to_a.last)
          if version.valid?
            version
          else
            fail "Can't get the latest version!"
          end
        rescue
          Origen.version
        end
      end
    end

    protected

    def class_dir(klass)
      names = klass.to_s.split('::')
      names.shift
      names.map(&:underscore).join('/')
    end

    def class_dirs(klass)
      names = klass.to_s.split('::')
      names.shift
      dirs = []
      until names.empty?
        dirs << names.map(&:underscore).join('/')
        names.pop
      end
      dirs
    end

    # def application_class?(klass)
    #  until klass == OrigenAppGenerators::Base
    # end

    def debugger
      require 'byebug'
      byebug # rubocop:disable Lint/Debugger
    end

    def plugin?
      type == :plugin
    end

    def application?
      !plugin?
    end

    def self.title
      desc.sub(/^An? /, '').titleize
    end

    # Calling this will compile all files in filelist against the current instance
    # variable values
    def build_filelist
      symlink_cmds = []
      self.destination_root = args.first
      filelist.each do |_name, file|
        if file[:type] == :symlink
          if Origen.running_on_windows?
            dest = Pathname.new("#{destination_root}/#{file[:dest]}")
            source = dest.dirname.to_s + "/#{file[:source]}"
            symlink_cmds << "call mklink /h #{dest.to_s.gsub('/', '\\')} #{source.to_s.gsub('/', '\\')}"
          else
            create_link file[:dest], file[:source]
          end
        elsif file[:type] == :dir || file[:type] == :directory
          if file[:copy]
            if (file.key? :dest) && (file.key? :source)
              directory(file[:source], file[:dest])
            else
              directory(file[:dest] || file[:source])
            end
          elsif file[:nokeep]
            empty_directory(file[:dest] || file[:source])
          else
            copy_file('dot_keep', "#{file[:dest]}/.keep")
          end
        else
          dest = file[:dest] || file[:source]
          if file[:copy] || dest =~ /.erb$/
            copy_file(file[:source], dest)
          else
            @options = file[:options] || {}
            template(file[:source], dest)
          end
        end
      end
      symlink_cmds.each { |cmd| system(cmd) }
    end

    # Prompts the user to confirm or enter the Ruby namespace to be used in the app.
    #
    # If @name is already defined a proposal will be generated from that, alternatively a proposal
    # can be supplied. If not proposal is resolved the user will be prompted to input from scratch.
    def get_namespace(proposal = nil)
      puts
      puts "SELECT YOUR #{type.to_s.upcase}'S NAMESPACE"
      puts
      puts "All #{type} code needs to reside in a unique namespace, this prevents naming collisions with 3rd party plugins."
      puts 'By Ruby conventions, this must start with a capital letter and should ideally be CamelCased and not use underscores.'
      # puts 'Some examples:: C40TFSNVMTester, CAPIOrigen, LS2080, ApacheOrigen'
      [@namespace_advice].each { |l| puts l } if @namespace_advice
      puts
      if !proposal && @name
        proposal = @name.to_s.camelize
      end
      proposal = nil if proposal.length < 3

      valid = false
      until valid
        @namespace = get_text(single: true, default: proposal)
        proposal = nil
        unless @namespace.empty?
          if @namespace.length >= 3
            valid = valid_constant?(@namespace)
          end
          unless valid
            puts 'That namespace is not valid :-('
            puts
          end
        end
      end
      @namespace
    end

    # Returns true if the given string can be converted to a valid Ruby constant and one that
    # does not already exist within the scope of this application and Origen Core
    def valid_constant?(string)
      valid = false
      # Try and convert this to a constant to test for validity, this will also screen things
      # like Origen since that will not trigger an error
      begin
        string.constantize
      rescue NameError => e
        if e.message =~ /^uninitialized constant/
          valid = true
        end
      else
        # Something else is wrong with it
      end
      valid
    end

    # Prompts the user to input a name for the new application, this will be screened to ensure
    # that it can cleanly cast to a symbol for use in Origen.
    #
    # This should be unique within the whole Origen ecosystem, in future this method will be enhanced
    # to check with the Origen server which will in future maintain a database of known app names.
    #
    # The final name is returned at the end and assigned to variable @name for use in templates.
    def get_name
      proposal = args.first.symbolize.to_s
      proposal = nil if proposal.length < 3
      puts
      puts "WHAT DO YOU WANT TO CALL YOUR NEW #{type.to_s.upcase}?"
      puts
      puts "This should be lowercased and underscored and will be used to uniquely identify your #{type} within the Origen ecosystem."
      [@name_advice].each { |l| puts l } if @name_advice
      puts
      valid = false
      until valid
        name = get_text(single: true, default: proposal)
        proposal = nil
        unless name.empty?
          if name == name.symbolize.to_s
            if name.symbolize.to_s.length >= 3
              valid = true
              @name = name
            end
          else
            puts
            puts 'That name is not valid, how about this?'
            proposal = name.symbolize.to_s
          end
        end
      end
      @name
    end
  end
end
