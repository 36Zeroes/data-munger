require "data_munger/version"
require 'hashie'

require 'data_munger/table'
require 'data_munger/record'

module DataMunger
  # Turn into an array...
  def self.arrify(*ary)
    if ary.nil?
      nil
    elsif ary.size == 1 && ary[0].respond_to?(:to_ary)
      ary.first
    else
      ary
    end    
  end
end
