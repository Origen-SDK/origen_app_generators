require 'origen'
<% if @type == :plugin -%>
require_relative '../config/application.rb'
<% end -%>
module <%= @namespace %>
<% if @type == :plugin -%>
  # THIS FILE SHOULD ONLY BE USED TO LOAD RUNTIME DEPENDENCIES
  # If this plugin has any development dependencies (e.g. dummy DUT or other models that are only used
  # for testing), then these should be loaded from config/boot.rb

<% end -%>
  # Example of how to explicitly require a file
  # require '<%= @name %>/my_class'
  #
  # If your application is large, it is usually better to use autoload to keep the boot up
  # time of your application low, here is the same example using autoload:
  # autoload :MyClass, '<%= @name %>/my_class'
end
