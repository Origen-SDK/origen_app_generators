require 'origen'
require 'colored'
require 'origen_app_generators/base'
require 'origen_app_generators/application'
require 'origen_app_generators/plugin'
require 'origen_app_generators/empty_application'
require 'origen_app_generators/empty_plugin'
require 'origen_app_generators/new'
require 'origen_app_generators/test_engineering/test_block'
require 'origen_app_generators/test_engineering/stand_alone_application'

module OrigenAppGenerators
  extend Origen::Utility::InputCapture

  TEST_INPUTS = [
    # Empty app
    ['0', '0', :default, :default, []],
    # Empty plugin
    ['0', '1', :default, :default, 'A test block', 'yes', []],
    # Stand alone test engineering app
    ['1', '0', :default, :default, 'Falcon, Eagle', 'Falcon[ram, atd(2), comm[ram(2), osc](3)], Eagle[ram(2), atd(4)]', ['origen g example']]
  ]

  # If adding any new generators manually always add them at the top, but
  # generally speaking don't, use 'rake new' to create a new generator instead
  AVAILABLE = {
    'Test Engineering' => [
      # OrigenAppGenerators::TestEngineering::TestBlock,
      OrigenAppGenerators::TestEngineering::StandAloneApplication
    ]
  }

  def self.invoke(path)
    puts
    puts 'CHOOSE AN ENGINEERING DOMAIN'
    puts
    puts "Domain-specific application templates are available for the following areas (enter '0' to build an empty generic one)"
    puts
    i = 0
    accept = [0]
    puts '0 - Empty / Not listed'
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
      puts '0 - Application'
      puts '1 - Plugin'
      puts
      accept = [0, 1]
      selection = get_text(single: true, accept: accept, default: 0).to_i

      case selection
      when 0
        OrigenAppGenerators::EmptyApplication.start [path]
      when 1
        OrigenAppGenerators::EmptyPlugin.start [path]
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
