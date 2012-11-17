require 'spec_helper'

describe CobolData::Parser do
  context 'standard format' do
    it 'parses strings' do
      "05 NAMEALT PIC XXX.".should be_parsed_as [:namealt, { type: :text, length: 3 }]
    end

    it 'parses numbers' do
      "05 NUMALT PIC 999.".should be_parsed_as [:numalt, { type: :number, length: 3 }]
    end

    it 'parses decimals' do
      "04 DEC2 PIC 999V99.".should be_parsed_as [:dec2, { type: :number, precision: 3, scale: 2 }]
    end

  end

  context 'repeat factors' do
    it 'works for strings' do
      "05 NAME PIC X(10).".should be_parsed_as [:name, { type: :text, length: 10 }]
    end

    it 'works for numbers' do
      "05 NUM PIC 9(5).".should be_parsed_as [:num, { type: :number, length: 5 }]
    end

    it 'works for decimals' do
      "04 DEC PIC 9(4)V99.".should be_parsed_as [:dec, { type: :number, precision: 4, scale: 2 }]
    end

  end
  context 'modifiers' do
    it 'parses packed decimals' do
      "04 COMP PIC 9(5)V9  COMP-3.".should be_parsed_as [:comp, { type: :number, precision: 5, scale: 1, packed: true }]
    end

    it 'parses signs' do
      "04 NUMSIGNED PIC S9(5).".should be_parsed_as [:numsigned, { type: :number, length: 5, signed: true }]
    end
  end

  it 'parses variable names correctly' do
    "05 NAME-WITH-DASH PIC X(10).".should be_parsed_as [:name_with_dash, { type: :text, length: 10 }]
  end

  it 'parses redefines' do
    "04 REDEF REDEFINES ORIGINAL.".should be_parsed_as [:redef, { redefines: :original }]
  end
end
