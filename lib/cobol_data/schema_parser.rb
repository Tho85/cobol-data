class CobolData::SchemaParser
  class << self
    TYPES = { 'X' => :text, '9' => :number }

    def parse_line(s)
      # Parse level, name and definition
      if line_match = %r|(?<level>\d+)\s+(?<name>[\w\-]+)\s+(?<definition>.*)|.match(s)
        format = { level: line_match[:level].to_i }

        # Check for standard format
        if definition_match = %r|PIC\s+(?<format>\S*)\s*(?<modifiers>.*)|.match(line_match[:definition])
          # Expand length in parentheses
          format_expanded = definition_match[:format].gsub(/([X9])\((\d+)\)/) { $1 * $2.to_i }

          # Check for general string or number format
          if format_match = %r|^(?<sign>[S]?)(?<type>[X9]+)(?<scale>.*)|.match(format_expanded)
            format.merge! type: TYPES[format_match[:type][0]], length: format_match[:type].length
          end

          # Is a scale given?
          if format_match[:scale]
            # Check for decimals, e.g. 9(4)V99
            if scale_match = %r|^V(?<scale>\d+)|.match(format_match[:scale])
              format.merge! scale: scale_match[:scale].length
            end
          end

          # Is there a sign?
          if format_match[:sign] == 'S'
            format.merge! signed: true
          end

          # Are there some modifiers?
          if definition_match[:modifiers]
            # Check for COMP-3
            if modifier_match = %r|COMP-3$|.match(definition_match[:modifiers])
              format.merge! packed: true
            end
          end

          # Check for redefines
        elsif definition_match = %r|REDEFINES\s+(?<original>[\w\-]+).*|.match(s)
          format.merge! redefines: to_field_name(definition_match[:original])
        end

        { to_field_name(line_match[:name]) => format }

      end
    end

    def parse(s)
      s.split("\n").reject { |line| line =~ /^\*/ }.join("").gsub(/[\r\n]/, '').split('.').compact.inject({}) do |hash, line|
        line_format = parse_line(line)
        hash.merge! line_format if line_format
        hash
      end
    end

    private

    def to_field_name(name)
      name.downcase.gsub('-', '_').to_sym
    end
  end

end


