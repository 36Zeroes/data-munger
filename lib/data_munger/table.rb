require 'set'

module DataMunger
  class Table
    include Enumerable
    
    attr_accessor :columns
    attr_reader :grouped_on
    
    def initialize(records=nil, opts={})
      @columns = opts[:columns] || []
      @records = []
      @grouped_on = nil
      self.add_records(records)
    end

    def group_on!(*cols)
      if grouped?
        @records.map!{|record| 
          record.group_sub_records!(*cols)
        }
      else
        perform_grouping_on!(*cols)        
      end
      self
    end

    def grouped?
      !!@cols_grouped_on
    end
    
    def row_at(index)
      @records[index]
    end

    # Merge in based on the common joined :on column(s)
    def merge_join(data_to_append, opts={})
      join_cols = DataMunger.arrify(opts[:on]) 
      raise ArgumentError, "You must specify what to join :on" unless join_cols
      
      new_cols = data_to_append.columns - join_cols
      add_columns(*new_cols) do |original_row|
        row_to_append = data_to_append.detect{|r|
          r.values_at(*join_cols) == original_row.values_at(*join_cols)
        }
        (row_to_append || {}).values_at(*new_cols)
      end
    end
    
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
        
    def empty!
      @records = []
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
    
    def inspect(level=0)
      prefix = ("--" * (level))
      "#{prefix}> Table with #{@records.size} records>\n" + 
      (@records || []).map{|record|
        (record.is_a?(Record) ? record.inspect(level + 1) : record.inspect)
      }.join("\n")
    end
    

    private
    def perform_grouping_on!(*cols)
      @cols_grouped_on = DataMunger.arrify(cols)
      
      raw_grouping = @records.group_by{|r| r.to_group(*@cols_grouped_on)}
      
      grouped_records = if RUBY_VERSION >= '1.9'
        raw_grouping.keys
      else # Generate an ordering (1.8 doesn't order hash keys)
        @records.map{|r| r.to_group(*@cols_grouped_on)}.uniq
      end
      
      empty!
      add_records(grouped_records)
      
      # Append sub-records to each group
      @records.each do |record|
        record.sub_table = DataMunger::Table.new(raw_grouping[record])
      end
      
      self
    end
  end
end
