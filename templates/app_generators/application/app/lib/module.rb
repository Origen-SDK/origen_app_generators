require 'origen'
<% if @type == :plugin -%>
require_relative '../../config/application'
<% end -%>
module <%= @namespace %>
end
