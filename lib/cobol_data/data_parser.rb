require 'bigdecimal'

class CobolData::DataParser
  def initialize(schema)
    @schema = schema
  end

  def parse_line(line)
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
