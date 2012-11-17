RSpec::Matchers.define :parse_line_to do |expected|
  match do |actual|
    CobolData::SchemaParser.parse_line(actual) == expected
  end

  failure_message_for_should do |actual|
    "expected: #{expected} \n     got: #{CobolData::SchemaParser.parse_line(actual)}"
  end
end

RSpec::Matchers.define :parse_to do |expected|
  match do |actual|
    CobolData::SchemaParser.parse(actual) == expected
  end

  failure_message_for_should do |actual|
    "expected: #{expected} \n     got: #{CobolData::SchemaParser.parse(actual)}"
  end
end
