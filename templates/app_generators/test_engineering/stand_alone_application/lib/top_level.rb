module <%= @namespace %>
  class <%= @options[:name] || 'TopLevel' %>
    include Origen::TopLevel

    def initialize(options = {})
      instantiate_pins(options)
      instantiate_registers(options)
      instantiate_sub_blocks(options)
    end

    def instantiate_pins(options = {})
      add_pin :tclk
      add_pin :tdi
      add_pin :tdo
      add_pin :tms
      add_pin :resetb
      add_pins :port_a, size: 8
    end

    def instantiate_registers(options = {})
    end

    def instantiate_sub_blocks(options = {})
<% @options[:sub_blocks].each do |name, attrs| -%>
<%   if attrs[:instances] -%>
      sub_block :<%= name.underscore %>, instances: <%= attrs[:instances] %>, class_name: '<%= name.camelize %>'
<%   else -%>
      sub_block :<%= name.underscore %>, class_name: '<%= name.camelize %>'
<%   end -%>
<% end -%>
    end
  end
end
