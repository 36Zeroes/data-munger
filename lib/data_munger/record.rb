
# As a mash, all hash-keys become methods.
# 
# But it's still a hash, so those Hash methods will take priority (i.e. first, keys, ...)
module DataMunger  
  class Record < Hashie::Mash
    # A record can have sub-records (for grouping)
    attr_accessor :sub_table

    # Have to wait for Hashie 2.0 (not released) for this:
    #    include ::Hashie::Extensions::MethodAccess
    def convert_key(key)  # don't stringify keys... why mr mash do this?
      key
    end
    
    def self.wrap_records(records)
      records.map{|record| wrap(record)}
    end
    
    def self.wrap(record)
      if record.is_a?(Record)
        record
      elsif record.respond_to? :to_hash
        new(record.to_hash)
      elsif record.respond_to? :attributes
        new(record.attributes)        
      else
        raise ArgumentError, "Cannot wrap input into a record: #{record}"
      end      
    end
    
    def group_sub_records!(*cols)
      @sub_table.group_on!(*cols) if @sub_table && !@sub_table.blank?
      self
    end
    
    def slice(*keys)
      new_rec = self.class.new
      keys.each { |k| new_rec[k] = self[k] if has_key?(k) }
      new_rec
    end

    # Convert to a group, where in all non-grouped values are nullified
    def to_group(*keys)
      Record.new(slice(*keys))
    end
    
    def set_values_at(keys, values)
      values = DataMunger.arrify(values)
      DataMunger.arrify(keys).each_with_index do |key, index|
        self[key] = values[index]
      end
      self
    end
    
    def inspect(level=0)
      prefix = ("--" * (level))
      key_values_inspection = map{|k,v| "#{k}: #{v}"}.join(',')
      
      "#{prefix}> Record {#{key_values_inspection}}>" +
        ("#{"\n" + @sub_table.inspect(level + 1) if @sub_table}")
    end    
  end
end
