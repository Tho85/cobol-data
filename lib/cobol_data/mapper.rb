require 'bigdecimal'

class CobolData::Mapper
  def initialize(schema)
    @schema = schema
  end

  def read(line)
    # First convert schema to string unpack schema
    raw_hash = Hash[prepared_schema.keys.zip(line.unpack(schema_to_unpack_argument))]

    # Then convert data types
    prepared_schema.inject({}) do |hash, (field_name, field_format)|
      # Fetch raw value from hash
      raw_value = raw_hash[field_name]

      # Convert all values to their target type
      converted_value = case field_format[:type]
                        when :text
                          raw_value
                        when :number
                          if field_format[:scale]
                            BigDecimal.new(raw_value) / (10 ** field_format[:scale])
                          else
                            raw_value.to_i
                          end
                        end

      # Set new value
      hash[field_name] = converted_value
      hash
    end
  end

  def write(data)
    # Go through every field in the schema
    line = prepared_schema.inject("") do |line, (field_name, field_format)|
      length = field_format[:length]

      # Convert value to a string
      append = case field_format[:type]
              when :text
                "%-#{length}s" % data[field_name]
              when :number
                if field_format[:scale]
                  "%0#{length}d" % ((data[field_name] || 0) * (10 ** field_format[:scale]))
                else
                  "%0#{length}d" % data[field_name].to_i
                end
              end

      # Raise error if field is too long
      raise CobolData::Error::ArgumentError if append.length > length

      line += append
    end

    line + "\n"
  end

  private
  def schema_to_unpack_argument
    prepared_schema.values.map do |field_format|
      "a#{field_format[:length]}"
    end.join("")
  end

  def prepared_schema
    # Prepare schema by removing redefined columns
    prepared_schema = @schema.dup

    @schema.each do |(field_name, field_format)|
      if field_format[:redefines]
        # Simply delete redefined fields...
        prepared_schema.delete field_format[:redefines]
        # ... and delete redefining field
        prepared_schema.delete field_name
      end
    end

    prepared_schema
  end

end
