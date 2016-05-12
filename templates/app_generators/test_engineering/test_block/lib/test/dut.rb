module <%= @namespace %>
  module Test
    # This is a dummy DUT class should be used to test that your test module can integrate
    # into a top-level app
    class DUT
      include Origen::TopLevel

      def initialize(options = {})
        instantiate_sub_blocks(options)
      end

      def instantiate_sub_blocks(options)
        sub_block :<%= options[:sub_block_name] %>, class_name: '<%= @namespace %>::<%= options[:class_name] %>', base_address: 0x1000_0000
      end
    end
  end
end
