module <%= @namespace %>
  class <%= @options[:name] %>
    include Origen::Model

    def initialize(options = {})
      instantiate_registers(options)
    end

    def instantiate_registers(options)
      # Define your IP's registers here
      reg :config, 0x0, size: 32 do |reg|
        reg.bits 15..8, :mode
        reg.bit 1, :ext_clk, reset: 1
        reg.bit 0, :secure, access: :ro
      end
    end
  end
end
