require 'origen'
<% if @type == :plugin -%>
require_relative '../../config/application.rb'
<% end -%>
module <%= @namespace %>
end
