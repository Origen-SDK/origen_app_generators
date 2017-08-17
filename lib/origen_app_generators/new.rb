module OrigenAppGenerators
  class New < Base
    include Origen::Utility::InputCapture

    desc 'Creates a new application generator within this application'

    # Naming of this method is important here to override the default user input which
    # does not apply to this generator
    def get_common_user_input
      get_domain
      get_name
      get_type
      get_summary
      @namespace = Origen.app.namespace
    end

    def set_type
      # Type not applicable in for this generator
    end

    def generate_files
      build_filelist
    end

    def enable
      available = Origen.app.namespace.constantize::AVAILABLE
      test_inputs = Origen.app.namespace.constantize::TEST_INPUTS

      # **** Add require line ****
      module_declaration = /\nmodule #{Origen.app.namespace}/
      inject_into_file "lib/#{Origen.app.name}.rb", "require '#{Origen.app.name}/#{@domain_namespace.underscore}/#{@classname.underscore}'\n",
                       before: module_declaration

      # **** Add to the AVAILABLE hash ****
      if available[@domain_summary]
        existing_domain = /\s*('|")#{@domain_summary}('|") => \[\s*\n/
        inject_into_file "lib/#{Origen.app.name}.rb", "      #{Origen.app.namespace}::#{@domain_namespace}::#{@classname},\n",
                         after: existing_domain
      else
        new_domain = <<-END
    '#{@domain_summary}' => [
      #{Origen.app.namespace}::#{@domain_namespace}::#{@classname},
    ],
        END
        available_hash = /AVAILABLE = {\s*\n/
        inject_into_file "lib/#{Origen.app.name}.rb", new_domain, after: available_hash
      end

      # **** Add a starter set of test inputs ****
      # First work out what the selection numbers will be for the new generator
      if available[@domain_summary]
        first = available.size - available.find_index { |k, _| k == @domain_summary }
        second = available[@domain_summary].size
      else
        first = available.size + 1
        second = 0
      end
      inputs = "\n    # #{test_inputs.size} - #{@domain_namespace}::#{@classname}\n"
      if @parentclass == 'Plugin'
        inputs += "    ['#{first}', '#{second}', :default, :default, 'A cool plugin', 'yes', :default]"
      else
        inputs += "    ['#{first}', '#{second}', :default, :default, :default]"
      end
      inputs = ",#{inputs}" unless test_inputs.empty?
      end_of_test_inputs = /\n\s*]\s*#\s*END_OF_TEST_INPUTS/
      inject_into_file "lib/#{Origen.app.name}.rb", inputs, before: end_of_test_inputs
    end

    # Can't compile this as contains some final ERB, so substitute instead
    # def customize_doc_page
    #  file = filelist[:doc_info][:dest]
    #  gsub_file file, 'TITLE_GOES_HERE', @title
    #  if @type == :plugin
    #    gsub_file file, 'INTRO_GOES_HERE', "This generates a customized version of the [Generic Plugin](<%= path 'origen_app_generators/plugin' %>)."
    #  else
    #    gsub_file file, 'INTRO_GOES_HERE', "This generates a customized version of the [Generic Application](<%= path 'origen_app_generators/application' %>)."
    #  end
    # end

    def conclude
      system "origen lint #{Origen.root}/lib/#{Origen.app.name}.rb"
      puts
      puts "New generator created at: #{filelist[:generator][:dest]}"
      puts
      puts "Create any template files you need for this generator in: #{filelist[:templates_dir][:dest]}"
      puts
      # puts "Before you go add some documentation about what this generates to: templates/web/origen_app_generators/origen_app_generators/#{@domain_namespace.underscore}/#{@classname.underscore}.md.erb"
      # puts
    end

    protected

    def get_summary
      puts
      puts 'DESCRIBE YOUR NEW GENERATOR IN A FEW WORDS'
      puts
      @summary = get_text(single: true)
      @title = @summary.sub(/^An? /, '').titleize
    end

    def get_type
      puts
      puts 'WILL YOUR TEMPLATE GENERATE A PLUGIN OR A TOP-LEVEL APPLICATION?'
      puts
      type = get_text(single: true, accept: %w(application plugin)).downcase
      @parentclass = type.capitalize
    end

    def get_name
      puts
      puts 'GIVE YOUR NEW GENERATOR CLASS A NAME'
      puts
      puts 'Your new generator needs a class name, this should be reasonably descriptive although it will not be displayed to end users'
      puts 'Some examples: GenericTestBlock, IPBlock, MPGBOMApp'
      puts
      valid = false
      until valid
        @classname = get_text(single: true).split('::').last
        unless @classname.empty?
          if @classname.length >= 3
            valid = valid_constant?("#{Origen.app.namespace}::#{@domain_namespace}::#{@classname}")
          end
          unless valid
            puts 'That class name is not valid :-('
            puts
          end
        end
      end
      @classname
    end

    def get_domain
      puts
      puts 'WHAT APPLICATION DOMAIN WILL YOUR NEW APP TEMPLATE APPLY TO?'
      puts
      puts "Enter something like 'Test Engineering', 'Design', etc."
      puts
      domain = get_text(single: true)
      domain = domain.titleize
      @domain_summary = domain
      @domain_namespace =  @domain_summary.gsub(' ', '')
    end

    def filelist
      @filelist ||= {
        generator:     { source: 'generator.rb',
                         dest:   "lib/#{Origen.app.name}/#{@domain_namespace.underscore}/#{@classname.underscore}.rb" },
        templates_dir: { dest: "templates/app_generators/#{@domain_namespace.underscore}/#{@classname.underscore}",
                         type: :directory },
        # doc_info:      { source: 'info.md.erb',
        #                 dest:   "templates/web/#{Origen.app.name}/#{@domain_namespace.underscore}/#{@classname.underscore}.md.erb" }
      }
    end
  end
end
