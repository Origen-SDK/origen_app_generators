require 'origen'
require 'colored'
require 'origen_app_generators/base'
require 'origen_app_generators/application'
require 'origen_app_generators/plugin'
require 'origen_app_generators/generic_application'
require 'origen_app_generators/generic_plugin'
require 'origen_app_generators/new'
require 'origen_app_generators/test_engineering/generic_test_block'

module OrigenAppGenerators
  extend Origen::Utility::InputCapture

  TEST_INPUTS = [
    ['0', 'application', :default, :default],
    ['1', '0', :default, :default, 'A test block', 'yes'],
    ['0', 'plugin', :default, :default, 'A cool plugin', 'yes'],
  ]

  # If adding any new generators manually always add them at the top, but
  # generally speaking don't, use 'rake new' to create a new generator instead
  AVAILABLE = {
    'Test Engineering' => [
      OrigenAppGenerators::TestEngineering::GenericTestBlock
    ]
  }

  def self.invoke(path)
    puts
    puts 'CHOOSE AN ENGINEERING DOMAIN'
    puts
    puts "Domain specific application templates are available for the following areas (enter '0' to build a generic one)"
    puts
    i = 0
    accept = [0]
    puts '0 - Generic / Not listed'
    AVAILABLE.reverse_each do |domain, _generators|
      i += 1
      accept << i
      puts "#{i} - #{domain}"
    end
    puts
    selection = get_text(single: true, default: '0', accept: accept).to_i
    if selection == 0
      puts
      puts "WHAT TYPE OF APPLICATION DO YOU WANT TO BUILD? (if you don't know go with 'application')"
      puts
      type = get_text(single: true, default: 'application', accept: %w(application plugin)).downcase.to_sym

      if type == :application
        OrigenAppGenerators::GenericApplication.start [path]
      else
        OrigenAppGenerators::GenericPlugin.start [path]
      end
    else
      domain = AVAILABLE.to_a
      domain = domain[domain.size - selection]
      puts
      puts "CHOOSE FROM THE FOLLOWING #{domain[0].upcase} APPLICATION TEMPLATES"
      puts
      accept = []
      i = 0
      domain[1].reverse_each do |generator|
        accept << i
        puts "#{i} - #{generator.desc}"
        i += 1
      end
      puts
      selection = get_text(single: true, accept: accept).to_i
      domain[1][domain[1].size - 1 - selection].start [path]
    end
  end
end
