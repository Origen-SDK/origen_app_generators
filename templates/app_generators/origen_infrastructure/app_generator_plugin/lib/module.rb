require 'origen_app_generators'
require '<%= @name %>/base'
require '<%= @name %>/application'
require '<%= @name %>/plugin'

module <%= @namespace %>
  # Define test sets of inputs to test your generators. The last item in each array is
  # required and always indicates what action should be taken once the application has
  # been built. nil means take no action, :default means to run a default set of test
  # operations, and an array of Origen command strings gives you control of exactly
  # what to run.
  #
  # These inputs can be executed individually by running 'origen app_gen:test -i INDEX',
  # where INDEX is the index number of the set you want to execute from the TEST_INPUTS
  # array.
  #
  # You can also execute all sets of test inputs by running: 'origen app_gen:test -r'
  TEST_INPUTS = [
  ] # END_OF_TEST_INPUTS Don't remove this comment, it is used by the app_gen:new command!

  # As you add new generators to this app they will be entered here, this enables the
  # mechanism to register them with the 'origen new' command.
  # You should generally not modify this by hand, instead use the 'origen app_gen:new'
  # command every time you want to create a new generator, and this will be filled in
  # for you.
  AVAILABLE = {
  }
end
