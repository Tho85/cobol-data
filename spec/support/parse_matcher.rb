RSpec::Matchers.define :be_parsed_as do |expected|
  match do |actual|
    CobolData::SchemaParser.parse(actual) == expected
  end
end
