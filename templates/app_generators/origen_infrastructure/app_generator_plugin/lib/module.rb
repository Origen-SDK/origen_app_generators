require 'origen_app_generators'
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
  #
  # The default set of inputs below will run within this application, however they only
  # test the empty plugin/application generators which are provided by origen_app_generators
  # and which are already tested within origen_app_generators' test suite.
  # Therefore, they are provided for example but are not required for test coverage,
  # so they can be safely removed if you like.
  TEST_INPUTS = [
    # 0 - Empty app, no operations performed after building
    ['0', '0', :default, :default, nil],
    # 1 - Empty plugin, with the default set of operations performed after building
    ['0', '1', :default, :default, 'A test block', 'yes', :default],
    # 2 - Empty plugin, with some custom test operations performed after building
    ['0', '1', :default, :default, 'A test block', 'yes', ['origen -v', 'origen lint']]
  ]

  # As you add new generators to this app they will be entered here, this enables the
  # mechanism to register them with the 'origen new' command.
  # You should generally not modify this by hand, instead use the 'origen app_gen:new'
  # command every time you want to create a new generator, and this will be filled in
  # for you.
  AVAILABLE = {
  }
end
