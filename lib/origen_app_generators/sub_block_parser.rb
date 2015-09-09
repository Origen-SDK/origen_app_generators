module OrigenAppGenerators
  require 'strscan'
  class SubBlockParser

    def parse(str)
      r = {}
      split(str).each do |tag|
        tag, i = extract_instantiations(tag)
        name, children = extract_children(tag)
        name = camelize(name)
        r[name] = {}
        r[name][:instantiations] = i if i
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
      until str.eos?
        r << next_tag(str)
      end
      r
    end

    def next_tag(str)
      v = str.scan_until(/,|\[|$/)
      if v[-1] == ','
        v.chop.strip
      elsif v[-1] == '['
        open = 1
        while open > 0 do
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
        [$1, parse($2)]
      else
        [tag.strip, nil]
      end
    end

    def extract_instantiations(tag)
      if tag.strip =~ /(.*)\((\d+)\)$/
        [$1, $2.to_i]
      else
        [tag.strip, nil]
      end
    end

    def camelize(val)
      val.strip.gsub(/\s+/, '_').camelize
    end
  end
end
