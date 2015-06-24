# coding: utf-8
config = File.expand_path('../config', __FILE__)
require "#{config}/version"

Gem::Specification.new do |spec|
  spec.name          = "origen_app_generators"
  spec.version       = OrigenAppGenerators::VERSION
  spec.authors       = ["Stephen McGinty"]
  spec.email         = ["stephen.f.mcginty@gmail.com"]
  spec.summary       = "Origen application generators"
  spec.homepage      = "http://origen-sdk.org/origen_app_generators"
  spec.license       = 'LGPL-3'
  spec.required_ruby_version     = '>= 1.9.3'
  spec.required_rubygems_version = '>= 1.8.11'

  # Only the files that are hit by these wildcards will be included in the
  # packaged gem, the default should hit everything in most cases but this will
  # need to be added to if you have any custom directories
  spec.files         = Dir["lib/**/*.rb", "templates/**/*", "config/**/*.rb",
                           "bin/*", "lib/tasks/**/*.rake", "pattern/**/*.rb",
                           "program/**/*.rb"
                          ]
  spec.executables   = []
  spec.require_paths = ["lib"]

  # Add any gems that your plugin needs to run within a host application
  spec.add_runtime_dependency "origen", ">= 0.0.3"
  # DO NOT ADD ANY ADDITIONAL RUNTIME DEPENDENCIES HERE, WHEN THESE GENERATORS
  # ARE INVOKED TO GENERATE A NEW APPLICATION IT WILL NOT BE LAUNCHED FROM WITHIN
  # A BUNDLED ENVIRONMENT.
  #
  # THEREFORE GENERATORS MUST NOT RELY ON ANY 3RD PARTY GEMS THAT ARE NOT
  # PRESENT AS PART OF A STANDARD ORIGEN INSTALLATION - I.E. YOU CAN ONLY RELY
  # ON THE GEMS THAT ORIGEN ITSELF DEPENDS ON.
  #
  # DEVELOPMENT ONLY DEPENDENCIES ARE ALLOWED AND CAN BE ADDED BELOW.

  # Add any gems that your plugin needs for its development environment only
  #spec.add_development_dependency "doc_helpers", ">= 1.7.0"
end
