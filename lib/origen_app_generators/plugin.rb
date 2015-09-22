module OrigenAppGenerators
  # The base generator class that should be used by all plugin generators
  class Plugin < Application
    def get_common_user_input
      get_name_and_namespace
      get_summary
      get_audience
    end

    protected

    # See Application#filelist for more details
    def filelist
      @filelist ||= begin
        list = super
        list.delete(:web_doc_layout)
        list.delete(:web_references)
        list.delete(:web_defintions)
        list.delete(:web_installation)
        list.delete(:web_introduction)
        list[:gemspec] = { source: 'gemspec.rb', dest: "#{@name}.gemspec" }
        list[:templates_shared] = { dest: 'templates/shared', type: :directory }
        if @audience == :external
          list[:travis] = { source: '.travis.yml' }
          list[:web_navbar] = { source: 'templates/web/partials/_navbar_external.html.erb', dest: 'templates/web/partials/_navbar.html.erb' }
        else
          list[:web_navbar] = { source: 'templates/web/partials/_navbar_internal.html.erb', dest: 'templates/web/partials/_navbar.html.erb' }
        end
        list
      end
    end

    def get_summary
      puts
      puts 'DESCRIBE YOUR NEW PLUGIN IN A FEW WORDS'
      puts
      @summary = get_text(single: true)
    end

    # Prompts the user to say whether the new plugin is intended for an internal
    # or external audience (meaning it will published to rubygems.org)
    def get_audience(proposal = nil)
      puts
      puts 'IS THIS PLUGIN GOING TO BE RELEASED TO AN EXTERNAL AUDIENCE?'
      puts
      puts 'By answering yes...'
      puts
      confirm_external = get_text(confirm: :return_boolean, default: 'no')
      @audience = :external if confirm_external
    end

    def type
      :plugin
    end
  end
end
