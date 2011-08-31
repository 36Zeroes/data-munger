module DataMunger
  class Aggregation
    attr_accessor :map, :reduce
    
    def initialize(opts={}, &block)
      if opts.keys.include?(:map) || opts.keys.include?(:reduce)
        @map = opts[:map]
        @reduce = opts[:reduce]
      elsif block_given?
        @reduce = block
      end
    end

    SUM = Aggregation.new :reduce => :sum
    MIN = Aggregation.new :reduce => :min
    MAX = Aggregation.new :reduce => :max
    
    AVG   = Aggregation.new {|list| list.sum / list.size}

    COUNT = Aggregation.new :map    => proc{|a,b| [a,b].flatten.uniq}, 
                            :reduce => :size
                          
    NUM   = Aggregation.new :reduce => :size

    def self.aggregate(records, fields, aggregations)
      # normalize fields
      fields
      result = records.inject(Array.new(fields.size)){ |agg, record|
        agg.zip(record.values_at(*fields)).map{|agg_elem, new_val|
          if agg_elem.nil? || new_val.nil?
            agg_elem || new_val
          else
            if @map
              @map.call(agg_elem, new_val)
            else
              agg_elem << new_val
            end
          end
        }
      }
      case @reduce
      when Symbol then; result.map{|r| r.send(@reduce)}
      when Proc then;   result.map{|r| @reduce.call(r)}
      else
        result
      end
    end
  end
end