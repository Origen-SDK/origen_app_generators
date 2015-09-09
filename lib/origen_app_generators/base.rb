module OrigenAppGenerators
  # This is the base generator used by all generators in this application
  class Base < Origen::CodeGenerators::Base
    include Origen::Utility::InputCapture

    require 'gems'

    def set_source_paths
      # The base Origen generator puts the Origen core directory on the source path, in retrospect this
      # was a bad idea and makes for hard to debug errors if an app generator resolves a template from
      # outside of this app.
      # So to keep things sane remove any inherited source paths.
      self.class.source_paths.pop until self.class.source_paths.empty?
      klass = self.class
      until klass == OrigenAppGenerators::Base
        dir = klass.to_s.sub('OrigenAppGenerators::', '').split('::').map(&:underscore).join('/')
        dir = File.expand_path("../../../templates/app_generators/#{dir}", __FILE__)
        self.class.source_paths << dir if File.exist?(dir)
        klass = klass.superclass
      end
    end

    # Just makes the type (:plugin or :application) available to all templates
    def set_type
      @type = type
    end

    def get_common_user_input
      get_name_and_namespace
      # get_revision_control
    end

    def get_lastest_origen_version
      @latest_origen_version = (Gems.info 'origen')['version']
    end

    protected

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

    def get_revision_control
      puts ''
      puts 'IS THIS FOR TRAINING?'
      puts ''
      training = get_text(confirm: :return_boolean, default: 'no')
      if type == :plugin && !training
        puts ''
        puts 'WHAT CATEGORY BEST DESCRIBES YOUR PLUGIN??'
        puts ''
        cats = {
          dut:      'Top-level SoC/DUT models',
          helper:   'Helper methods and code snippets',
          physical: 'Physical interface drivers (e.g. JTAG)',
          protocol: 'Protocol driver providing read/write register APIs (e.g. JTAG2IPS)',
          module:   'A module to support testing a specific silicon block',
          tester:   'Any Origen tester model, could be an ATE or a debugger or testbench stimulus generator ',
          misc:     'Anything else'
        }
        cats.each do |key, val|
          puts "#{key} - #{val}"
        end
        puts ''
        category = get_text(single: true, accept: cats.keys).downcase.to_sym
      end
      @vault = 'sync://sync-15088:15088/Projects/common_tester_blocks/'
      if training
        @vault += 'origen_training/'
      elsif type == :plugin
        @vault += "origen_blocks/#{category}/"
      else
        @vault += 'blocks/'
      end
      @vault += "#{@name}/tool_data/origen"
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
          empty_directory(file[:dest] || file[:source])
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

    # Convenience method that is equivalent to calling get_name and then get_namespace
    def get_name_and_namespace
      get_name
      get_namespace
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
