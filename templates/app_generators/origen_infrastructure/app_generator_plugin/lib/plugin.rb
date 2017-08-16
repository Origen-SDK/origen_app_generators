module <%= @namespace %>
  # This will be the parent class of all of your plugin generators, it provides a place
  # to add anything that you want to be added to all of your plugins
  class Plugin < OrigenAppGenerators::Plugin
    def initialize(*args)
      # This makes all of your plugins be configured for internal distribution, i.e. rather
      # than via rubygems.org
      @audience = :internal
      super
    end
  end
end
