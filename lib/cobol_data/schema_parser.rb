class CobolData::SchemaParser
  class << self
    TYPES = { 'X' => :text, '9' => :number }

    def parse_line(s)
      # Check for standard format
      if line_match = %r|(?<name>[\w\-]+)\s+PIC\s+(?<format>\S*)\s*(?<modifiers>.*)|.match(s)
        # Expand length in parentheses
        format_expanded = line_match[:format].gsub(/([X9])\((\d+)\)/) { $1 * $2.to_i }

        # Check for general string or number format
        format = if format_match = %r|^(?<sign>[S]?)(?<type>[X9]+)(?<scale>.*)|.match(format_expanded)
          { type: TYPES[format_match[:type][0]], length: format_match[:type].length }
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
        if line_match[:modifiers]
          # Check for COMP-3
          if modifier_match = %r|COMP-3$|.match(line_match[:modifiers])
            format.merge! packed: true
          end
        end

        { to_field_name(line_match[:name]) => format }

      # Check for redefines
      # TODO: DRY name part of regex (see above)
      elsif line_match = %r|(?<name>[\w\-]+)\s+REDEFINES\s+(?<original>[\w\-]+).*|.match(s)
        { to_field_name(line_match[:name]) => { redefines: to_field_name(line_match[:original]) } }
      end
    rescue
      # TODO Raise ParserException
      nil
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


