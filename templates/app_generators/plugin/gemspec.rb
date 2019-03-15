# coding: utf-8
config = File.expand_path('../config', __FILE__)
require "#{config}/version"

Gem::Specification.new do |spec|
  spec.name          = "<%= @name %>"
  spec.version       = <%= @namespace %>::VERSION
  spec.authors       = ["<%= User.current.name %>"]
  spec.email         = ["<%= User.current.email %>"]
  spec.summary       = "<%= @summary %>"
<% if @audience == :external -%>
  #spec.homepage      = "http://origen-sdk.org/<%= @name %>"
<% else -%>
  #spec.homepage      = "http://origen.mycompany.net/<%= @name %>"
<% end -%>

  spec.required_ruby_version     = '>= 2'
  spec.required_rubygems_version = '>= 1.8.11'

  # Only the files that are hit by these wildcards will be included in the
  # packaged gem, the default should hit everything in most cases but this will
  # need to be added to if you have any custom directories
  spec.files         = Dir["lib/<%= @name %>.rb", "lib/<%= @name %>/**/*.rb", "templates/**/*", "config/**/*.rb",
                           "bin/*", "lib/tasks/**/*.rake", "pattern/**/*.rb", "program/**/*.rb",
                           "app/lib/<%= @name %>.rb", "app/lib/<%= @name %>/**/*.rb", "app/templates/**/*",
                           "app/patterns/**/*.rb", "app/flows/**/*.rb", "app/models/**/*.rb"
                          ]
  spec.executables   = []
  spec.require_paths = ["lib", "app/lib"]

  # Add any gems that your plugin needs to run within a host application
  spec.add_runtime_dependency "origen", ">= <%= @latest_origen_version %>"
<% if @runtime_dependencies -%>  
  <% @runtime_dependencies.each do |dep| -%>
spec.add_runtime_dependency <%= dep.map{ |d| "\"#{d}\"" }.join(', ') %>
  <% end -%>
<% end -%>
<% if @post_runtime_dependency_comments -%>  
  <% @post_runtime_dependency_comments.each do |line| -%>
# <%= line %>
  <% end -%>
<% end -%>
end
