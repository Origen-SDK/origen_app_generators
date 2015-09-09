require "spec_helper"
require 'origen_app_generators/sub_block_parser'

describe "Sub block parser" do

  before :all do
    @parser = OrigenAppGenerators::SubBlockParser.new
  end
  
  it "Can parse basic strings" do
    s = "ram, atd"
    @parser.parse(s).should == {"RAM" => {}, "ATD" => {}}
  end

  it "Can identify multiple instances" do
    s = "ram, osc(2), atd(3)"
    @parser.parse(s).should == {"RAM" => {}, "Osc" => {instances: 2}, "ATD" => {instances: 3}}
  end

  it "Can handle nesting" do
    s = "ram, atd, nvm[ram(2), osc]"
    @parser.parse(s).should == {"RAM" => {}, "ATD" => {}, "NVM" => {children: {
      "RAM" => {instances: 2}, "Osc" => {}
    }}}
  end

  it "Can handle a top-level namespace" do
    s = "Falcon[ram, atd, nvm[ram(2), osc]], Eagle[ram(2), atd]"
    @parser.parse(s).should == 
      { "Falcon" => { children: {"RAM" => {}, "ATD" => {}, "NVM" => {children: {
          "RAM" => {instances: 2}, "Osc" => {}
        }}}},
        "Eagle" => { children: {"RAM" => {instances: 2}, "ATD" => {}
        }}}
  end
end
