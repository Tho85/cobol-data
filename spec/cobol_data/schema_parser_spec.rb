require 'spec_helper'

describe CobolData::SchemaParser do
  context 'single line' do
    context 'standard format' do
      it 'parses strings' do
        "05 NAMEALT PIC XXX".should parse_line_to [:namealt, { type: :text, length: 3 }]
      end

      it 'parses numbers' do
        "05 NUMALT PIC 999".should parse_line_to [:numalt, { type: :number, length: 3 }]
      end

      it 'parses decimals' do
        "04 DEC2 PIC 999V99".should parse_line_to [:dec2, { type: :number, precision: 3, scale: 2 }]
      end

    end

    context 'repeat factors' do
      it 'works for strings' do
        "05 NAME PIC X(10)".should parse_line_to [:name, { type: :text, length: 10 }]
      end

      it 'works for numbers' do
        "05 NUM PIC 9(5)".should parse_line_to [:num, { type: :number, length: 5 }]
      end

      it 'works for decimals' do
        "04 DEC PIC 9(4)V99".should parse_line_to [:dec, { type: :number, precision: 4, scale: 2 }]
      end

    end
    context 'modifiers' do
      it 'parses packed decimals' do
        "04 COMP PIC 9(5)V9  COMP-3".should parse_line_to [:comp, { type: :number, precision: 5, scale: 1, packed: true }]
      end

      it 'parses signs' do
        "04 NUMSIGNED PIC S9(5)".should parse_line_to [:numsigned, { type: :number, length: 5, signed: true }]
      end
    end

    it 'parses variable names correctly' do
      "05 NAME-WITH-DASH PIC X(10)".should parse_line_to [:name_with_dash, { type: :text, length: 10 }]
    end

    it 'parses redefines' do
      "04 REDEF REDEFINES ORIGINAL".should parse_line_to [:redef, { redefines: :original }]
    end
  end

  context 'multiple lines' do
    it 'parses correctly' do
      %q|01 FIRSTNAME PIC X(10).
         01 LASTNAME PIC X(10).
         01 ACCOUNTNUMBER PIC 9(5).
      |.should parse_to [
        [:firstname, { type: :text, length: 10 }],
        [:lastname,  { type: :text, length: 10 }],
        [:accountnumber, { type: :number, length: 5 }]
      ]
    end

    it 'ignores comments' do
      %q|* This is a comment
         01 FIRSTNAME PIC X(10).
         |.should parse_to [[:firstname, { type: :text, length: 10 }]]
    end

    it 'allows multi-line definitions' do
      %q|01 FIRSTNAME
            PIC X(10).
        |.should parse_to [[:firstname, { type: :text, length: 10 }]]
    end
  end
end
