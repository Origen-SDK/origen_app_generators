module OrigenAppGenerators
  require 'strscan'
  # Responsible for parsing something like this:
  #
  #   "ram, osc, pll, atd(2), comms[ram(2), osc](3)"
  #
  # into this:
  #
  #   {
  #     "RAM"=>{}, "Osc"=>{}, "PLL"=>{}, "ATD"=> {:instances=>2},
  #     "Comms"=>{:instances=>3, :children=>{"RAM"=>{:instances=>2}, "Osc"=>{}}}
  #   }
  #
  class SubBlockParser
    def parse(str)
      r = {}
      split(str).each do |tag|
        tag, i = extract_instances(tag)
        name, children = extract_children(tag)
        name = camelize(name)
        r[name] = {}
        r[name][:instances] = i if i
        r[name][:children] = children if children
      end
      r
    end

    private

    # Splits the given string by comma, but understands that nested
    # commas should not be split on
    def split(str)
      r = []
      str = StringScanner.new(str)
      r << next_tag(str) until str.eos?
      r
    end

    def next_tag(str)
      v = str.scan_until(/,|\[|$/)
      if v[-1] == ','
        v.chop.strip
      elsif v[-1] == '['
        open = 1
        while open > 0
          v += str.scan_until(/\[|\]/)
          if v[-1] == '['
            open += 1
          else
            open -= 1
          end
        end
        v += next_tag(str)
      # End of line
      else
        v.strip
      end
    end

    def extract_children(tag)
      # http://rubular.com/r/plGILY2e2U
      if tag.strip =~ /([^\[]*)\[(.*)\]/
        [Regexp.last_match(1), parse(Regexp.last_match(2))]
      else
        [tag.strip, nil]
      end
    end

    def extract_instances(tag)
      if tag.strip =~ /(.*)\((\d+)\)$/
        [Regexp.last_match(1), Regexp.last_match(2).to_i]
      else
        [tag.strip, nil]
      end
    end

    def camelize(val)
      val.strip.gsub(/\s+/, '_').camelize
    end
  end
end
