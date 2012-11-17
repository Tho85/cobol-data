require 'spec_helper'

describe CobolData::DataParser do
  context 'string schema' do
    let(:schema) { {
      id: { type: :number, length: 3 },
      name: { type: :text, length: 10 },
      height: { type: :number, length: 4, scale: 2 }
    } }

    let(:parser) { CobolData::DataParser.new(schema) }

    it 'parses data to hashes' do
      parser.parse_line("015THOMAS    0180").should == { id: 15, name: "THOMAS    ", height: 1.8 }
    end
  end
end
