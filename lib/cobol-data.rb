require "cobol_data/version"

module CobolData
  autoload :SchemaParser, 'cobol_data/schema_parser'
  autoload :Mapper,       'cobol_data/mapper'
  autoload :Base,         'cobol_data/base'

  autoload :Error,        'cobol_data/error'
end
