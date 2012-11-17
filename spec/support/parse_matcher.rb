require 'cobol_data/parser'

RSpec::Matchers.define :be_parsed_as do |expected|
  match do |actual|
    CobolData::Parser.parse(actual) == expected
  end
end
