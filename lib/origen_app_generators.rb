require 'origen'
require_relative '../config/application.rb'
require 'colored'
require 'origen_app_generators/base'
require 'origen_app_generators/application'
require 'origen_app_generators/plugin'
require 'origen_app_generators/empty_application'
require 'origen_app_generators/empty_plugin'
require 'origen_app_generators/new'
require 'origen_app_generators/test_engineering/test_block'
require 'origen_app_generators/test_engineering/stand_alone_application'
require 'origen_app_generators/origen_infrastructure/app_generator_plugin'

module OrigenAppGenerators
  extend Origen::Utility::InputCapture

  TEST_INPUTS = [
    # 0 - Empty app
    ['0', '0', :default],
    # 1 - Empty plugin
    ['0', '1', :default, :default, 'A test block', 'yes', :default],
    # 2 - Stand alone test engineering app
    ['2', '0', :default, :default, 'Falcon, Eagle', 'Falcon[ram, atd(2), comm[ram(2), osc](3)], Eagle[ram(2), atd(4)]', [:default, 'origen g example']],
    # 3 - Test module
    ['2', '1', :default, :default, 'Test module for all flash IPs', 'FLASH_512K, FLASH_1024K', 'flash', [:default, 'origen g example']],
    # 4 - An app generators plugin
    ['1', '0', :default, :default, 'My application generators', :default]
  ] # END_OF_TEST_INPUTS Don't remove this comment, it is used by the app_gen:new command!

  # As you add new generators to this app they will be entered here, this enables the
  # mechanism to register them with the 'origen new' command.
  # You should generally not modify this by hand, instead use the 'origen app_gen:new'
  # command every time you want to create a new generator, and this will be filled in
  # for you.
  AVAILABLE = {
    'Test Engineering'      => [
      OrigenAppGenerators::TestEngineering::TestBlock,
      OrigenAppGenerators::TestEngineering::StandAloneApplication
    ],
    'Origen Infrastructure' => [
      OrigenAppGenerators::OrigenInfrastructure::AppGeneratorPlugin
    ]
  }

  # @api private
  def self.add_generators(new_generators, options = {})
    new_generators.each do |domain, gens|
      gens.each { |gen| template_dirs[gen] ||= options[:template_dir] if options[:template_dir] }
      if generators[domain]
        gens.each { |g| generators[domain].unshift(g) }
        new_generators.delete(domain)
      end
    end
    @generators = new_generators.merge(generators)
  end

  # @api private
  def self.unload_generators
    @generators = {}
  end

  # @api private
  def self.generators
    @generators ||= AVAILABLE
  end

  # @api private
  def self.template_dirs
    @template_dirs ||= {}
  end

  # @api private
  def self.invoke(path)
    puts
    puts 'CHOOSE AN APPLICATION DOMAIN'
    puts
    puts "Domain-specific application templates are available for the following areas (enter '0' to build an empty generic one)"
    puts
    i = 0
    accept = [0]
    puts '0 - Empty / Not listed'
    generators.reverse_each do |domain, _generators|
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
      domain = generators.to_a
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
