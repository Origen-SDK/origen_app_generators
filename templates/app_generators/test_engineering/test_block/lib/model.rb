module <%= @namespace %>
  class <%= @options[:name] %>
    include Origen::Model

    def initialize(options = {})
      instantiate_registers(options)
    end

    def instantiate_registers(options)
      # Define your IP's registers here
    end
  end
end
