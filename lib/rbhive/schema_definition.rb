require 'json'

module RBHive
  class SchemaDefinition
    attr_reader :schema
  
    TYPES = { 
      :BOOLEAN_TYPE => :to_s,
      :TINYINT_TYPE => :to_i,
      :SMALLINT_TYPE => :to_i,
      :INT_TYPE => :to_i,
      :BIGINT_TYPE => :to_i,
      :FLOAT_TYPE => :to_f,
      :DOUBLE_TYPE => :to_f,
      :STRING_TYPE => :to_s,
      :TIMESTAMP_TYPE => :to_s,
      :BINARY_TYPE => :to_s,
      :ARRAY_TYPE => :to_s,
      :MAP_TYPE => :to_s,
      :STRUCT_TYPE => :to_s,
      :UNION_TYPE => :to_s,
      :USER_DEFINED_TYPE => :to_s,
      :DECIMAL_TYPE => :to_f
      
    }
  
    def initialize(schema, example_row)
      @schema = schema
      @example_row = example_row ? example_row.split("\t") : []
    end
  
    def column_names
      @column_names ||= begin
        #schema_names = @schema.fieldSchemas.map {|c| c.name }
        schema_names = @schema.columns.map(&:columnName)
        
        # In rare cases Hive can return two identical column names
        # consider SELECT a.foo, b.foo...
        # in this case you get two columns called foo with no disambiguation.
        # as a (far from ideal) solution we detect this edge case and rename them
        # a.foo => foo1, b.foo => foo2
        # otherwise we will trample one of the columns during Hash mapping.
        s = Hash.new(0)
        schema_names.map! { |c| s[c] += 1; s[c] > 1 ? "#{c}---|---#{s[c]}" : c }
        schema_names.map! { |c| s[c] > 1 ? "#{c}---|---1" : c }
        schema_names.map! { |c| c.gsub('---|---', '_').to_sym }
        
        # Lets fix the fact that Hive doesn't return schema data for partitions on SELECT * queries
        # For now we will call them :_p1, :_p2, etc. to avoid collisions.
        offset = 0
        while schema_names.length < @example_row.length
          schema_names.push(:"_p#{offset+=1}")
        end
        schema_names
      end
    end
  
    def column_type_map
      @column_type_map ||= column_names.inject({}) do |hsh, c| 
        definition = @schema.columns.find {|s| s.columnName.to_sym == c }

        
        # If the column isn't in the schema (eg partitions in SELECT * queries) assume they are strings
        hsh[c] = definition ? TTypeId::VALUE_MAP[definition.typeDesc.types.map(&:primitiveEntry).map(&:type)[0]].to_sym : :string
        hsh
      end
    end
  
    def coerce_row(row)
      column_names.zip(row.split("\t")).inject({}) do |hsh, (column_name, value)|
        hsh[column_name] = coerce_column(column_name, value)
        hsh
      end
    end
  
    def coerce_column(column_name, value)
      type = column_type_map[column_name]
      return 1.0/0.0 if(type != :string && value == "Infinity")
      return 0.0/0.0 if(type != :string && value == "NaN")
      return nil if value.nil? || value.downcase == 'null'
      return coerce_complex_value(value) if type.to_s =~ /^ARRAY_TYPE/
      conversion_method = TYPES[type]
      conversion_method ? value.send(conversion_method) : value
    end
  
    def coerce_row_to_array(row)
      column_names.map { |n| row[n] }
    end
    
    def coerce_complex_value(value)
      return nil if value.nil?
      return nil if value.length == 0
      return nil if value.downcase == 'null'
      JSON.parse(value)
    end
  end
end
