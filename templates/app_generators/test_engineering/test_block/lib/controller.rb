module <%= @namespace %>
  class <%= @options[:name] %>Controller
    include Origen::Controller

    def do_something
      # The config register is defined in the corresponding model
      config.mode.write!(0x14)
      tester.wait(time_in_us: 100)
      config.secure.read!(0)
    end
  end
end
