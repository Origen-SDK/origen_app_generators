module <%= @namespace %>
  class Plugin < OrigenAppGenerators::Plugin

    def initialize(*args)
      @audience = :internal
      super
    end

  end
end
