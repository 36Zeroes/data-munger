
# As a mash, all hash-keys become methods.
# 
# But it's still a hash, so those Hash methods will take priority (i.e. first, keys, ...)
module DataMunger  
  class Record < Hashie::Mash
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
    
    # Convert to a group, where in all non-grouped values are nullified
    def to_group(*keys)
      g = GroupingRecord.new(self)
      g.delete_if{|key, value| !keys.include?(key)}
      g
    end
    
    def set_values_at(keys, values)
      values = DataMunger.arrify(values)
      DataMunger.arrify(keys).each_with_index do |key, index|
        self[key] = values[index]
      end
      self
    end
  end
  
  # A Grouping is a record which has a sub-listing of records
  class GroupingRecord < Record
    attr_accessor :records
  end
end