module <%= @namespace %>
  class Interface
    include OrigenTesters::ProgramGenerators
    
    # This will be called at the start of every flow or sub-flow (whenever Flow.create
    # is called).
    # Any options passed to Flow.create will be passed in here.
    # The options will contain top_level: true, whenever this is called at the start of
    # a new top-level flow.
    def startup(options = {})
    end

    # This will be called at the end of every flow or sub-flow (at the end of every
    # Flow.create block).
    # Any options passed to Flow.create will be passed in here.
    # The options will contain top_level: true, whenever this is called at the end of a
    # top-level flow file.
    def shutdown(options = {})
    end
  end
end
