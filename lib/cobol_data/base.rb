module CobolData
  class Base
    class << self
      include Enumerable

      attr_accessor :schema_file, :data_file

      def schema
        @schema ||= CobolData::SchemaParser.parse open(schema_file).read
      end

      def mapper
        @mapper ||= CobolData::Mapper.new(schema)
      end

      def each
        open(data_file).readlines.each do |line|
          yield new mapper.read(line)
        end
      end

      def define_getters!
        schema.each do |field_name, _|
          define_method(field_name) do
            @attributes[field_name]
          end
        end
      end

      def define_setters!
        schema.each do |field_name, _|
          define_method("#{field_name}=") do |new_value|
            @attributes[field_name] = new_value
          end
        end
      end
    end

    def initialize(attributes={})
      self.class.define_getters!
      self.class.define_setters!

      @attributes = self.class.schema.inject({}) do |hash, (field_name, _)|
        hash[field_name] = (attributes[field_name] if attributes.key?(field_name))
        hash
      end
    end

    def save
      File.open(self.class.data_file, "a") do |file|
        file.write self.class.mapper.write(@attributes)
      end
    end

  end
end
