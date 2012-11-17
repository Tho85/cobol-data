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

  context 'with redefines' do
    let(:schema) { {
      id:         { level: 1, type: :number, length: 4 },
      name:       { level: 1, type: :text,   length: 20 },
      real_name:  { level: 1, redefines: :name },
      first_name: { level: 2, type: :text,   length: 10 },
      last_name:  { level: 2, type: :text,   length: 10 },
      number:     { level: 1, type: :number, length: 2}
    } }

    let(:parser) { CobolData::DataParser.new(schema) }

    it 'redefines correctly' do
      parser.parse_line("1234VORNAME   NACHNAME  42").should == { id: 1234, first_name: 'VORNAME   ', last_name: 'NACHNAME  ', number: 42 }
    end

  end
end
