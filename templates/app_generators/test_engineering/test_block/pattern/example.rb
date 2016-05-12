Pattern.create do
  # Registers should never be written directly from here, always call API methods
  # that are defined by your controllers
  dut.<%= options[:sub_block_name] %>.do_something
end
