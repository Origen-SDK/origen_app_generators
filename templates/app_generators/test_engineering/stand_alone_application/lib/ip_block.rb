module <%= @namespace %>
  class <%= @options[:name] %>
    include Origen::Model

    def initialize(options = {})
      instantiate_registers(options)
      instantiate_sub_blocks(options)
    end

    def instantiate_registers(options = {})
    end

    def instantiate_sub_blocks(options = {})
<% @options[:sub_blocks].each do |name, attrs| -%>
<%   if attrs[:instances] -%>
      sub_blocks :<%= name.underscore %>, instances: <%= attrs[:instances] %>, class_name: '<%= name.camelize %>'
<%   else -%>
      sub_block  :<%= name.underscore %>, class_name: '<%= name.camelize %>'
<%   end -%>
<% end -%>
    end
  end
end
