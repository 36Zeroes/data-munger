module DataMunger
  class RecordSet
    include Enumerable
    
    attr_reader :columns
    
    def initialize(records=nil, opts={})
      @columns = opts[:columns] || []
      @records = []
      self.add_records(records)
    end
    
    def group_on(*cols)
      cols = DataMunger.arrify(cols)

      raw_grouping = @records.group_by{|record| record.to_group(*cols)}

      grouped_records = DataMunger::RecordSet.new(raw_grouping.keys, :columns => columns)
      grouped_records.each do |group|
        group.records = raw_grouping[group]
      end
      grouped_records
    end    
    
    # Merge another data into this one 
    # based on the common merge_column(s)
    def merge_record_set(data_to_append, merge_column_or_ary)
      merge_columns = DataMunger.arrify(merge_column_or_ary)
      
      new_cols = data_to_append.columns - merge_columns
      add_columns(*new_cols) do |original_row|
        row_to_append = data_to_append.detect{|r|
          r.values_at(*merge_columns) == original_row.values_at(*merge_columns)
        }
        (row_to_append || {}).values_at(*new_cols)
      end
    end
    alias :+ :merge_record_set
    
    def add_records(records)
      recs = DataMunger.arrify(records)
      if !recs.empty?
        set_columns_from_record(recs.first) if @columns.empty?
        @records += Record.wrap_records(recs)
      end
    end
    alias :add_record :add_records

    
    def add_columns(*col_names_or_col_name)
      col_names = DataMunger.arrify(col_names_or_col_name)
      @columns += (col_names - @columns)
      if block_given?
        @records.each{|record|
          record.set_values_at(col_names, yield(record))
        }
      end
    end
    alias :add_column :add_columns
    alias :transform_column :add_columns
    alias :transform_columns :add_columns
    
    def set_columns_from_record(record)
      @columns = record.keys
    end
    
    def each
      for record in @records
        yield record
      end
    end
    
    def filter!
      @records = @records.select{|record| yield(record)}
    end
    
    def size
      @records.size
    end

    def blank?
      nil? || empty?
    end    

    def nil?
      @records.nil?
    end
    
    def empty?
      @records.empty?
    end
  end
end