module OrigenAppGenerators
  # The base generator class that should be used by all plugin generators
  class Plugin < Application
    def get_common_user_input
      get_name_and_namespace
      get_summary
      get_revision_control
      fail "yo"
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
        list[:config_development] = { source: 'config/development.rb' }
        list[:gemspec] = { source: 'gemspec.rb', dest: "#{@name}.gemspec" }
        list[:templates_shared] = { dest: 'templates/shared', type: :directory }
        list
      end
    end

    def get_summary
      puts
      puts 'DESCRIBE YOUR NEW PLUGIN IN A FEW WORDS'
      puts
      @summary = get_text(single: true)
    end

    def type
      :plugin
    end
  end
end
