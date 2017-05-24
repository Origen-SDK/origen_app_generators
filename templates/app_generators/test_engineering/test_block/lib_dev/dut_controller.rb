module <%= @namespace %>Dev
  # This is a dummy DUT controller that should be used to test that your test module can
  # integrate into a top-level app
  class DUTController
    def startup(options = {})
      tester.set_timeset('func_25', 40)
      ss 'Startup the SoC'
      pin(:resetb).drive!(0)
      100.cycles
      pin(:resetb).dont_care
    end

    def shutdown(options = {})
      ss 'Shutdown the SoC'
      pin(:resetb).drive!(0)
    end

    def write_register(reg, options = {})
      arm_debug.write_register(reg, options)
    end

    def read_register(reg, options = {})
      arm_debug.read_register(reg, options)
    end
  end
end
