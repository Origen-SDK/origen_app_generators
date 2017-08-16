# This file is used to hook the generators defined in this plugin into the
# 'origen new' command, it must not be removed or modified

require 'origen_app_generators'
require "<%= @name %>"

OrigenAppGenerators.add_generators(<%= @namespace %>::AVAILABLE)
