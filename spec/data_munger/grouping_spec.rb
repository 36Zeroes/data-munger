require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe 'RecordSet when grouped' do
  before do
    @table = DataMunger::Table.new([
        {:first => 1, :second => 'a'},
        {:first => 1, :second => 'a'},
        {:first => 1, :second => 'b'},
        {:first => 2, :second => 'c'}
      ]).group_on!(:first)
  end
  
  it 'should generate group records, each having a RecordSet of sub-records' do
    @table.each do |group|
      group.should be_a(DataMunger::Record)
      group.sub_table.should_not be_empty
      
      group.sub_table.each do |record|
        record.should be_a(DataMunger::Record)
      end
    end
  end
  
  it 'should group common values for the grouped field' do
    @table.size.should == 2 # groups
    @table.row_at(0).to_hash.should == {:first => 1}
    @table.row_at(1).to_hash.should == {:first => 2}
  end
  
  it 'should have subrecords for groups' do
    @table.row_at(0).sub_table.size.should == 3
    @table.row_at(1).sub_table.size.should == 1
  end
  
  describe 'and then grouped again' do
    before do
      @original_records = @table.to_a
      @table.group_on!(:second)
    end
    
    it 'should retain the same top level records' do
      @table.to_a.size.should == @original_records.size
    end
    
    it 'should make sub-groups for each of the groups' do
      @table.row_at(0).sub_table.size.should == 2   # group :first=>1  has subgroups :second=>a and :second=>b
      @table.row_at(0).sub_table.row_at(0).to_hash.should == {:second => 'a'}
      @table.row_at(0).sub_table.row_at(1).to_hash.should == {:second => 'b'}
      
      @table.row_at(1).sub_table.size.should == 1   # group :first=>2  has subgroups :second=>c
      @table.row_at(1).sub_table.row_at(0).to_hash.should == {:second => 'c'}
    end
  end
end

describe 'RecordSet when grouped on multiple fields' do
  before do
    @table = DataMunger::Table.new([
        {:first => 1, :second => 'a'},
        {:first => 1, :second => 'a'},
        {:first => 1, :second => 'b'},
        {:first => 2, :second => 'c'}
      ]).group_on!(:first, :second)
  end
  
  it 'should group common values for all fields' do
    @table.size.should == 3
    @table.row_at(0).values_at(:first, :second).should == [1,'a']
    @table.row_at(1).values_at(:first, :second).should == [1,'b']
    @table.row_at(2).values_at(:first, :second).should == [2,'c']
  end
  
  it 'should have subrecords for groups' do
    @table.row_at(0).sub_table.size.should == 2 
    @table.row_at(1).sub_table.size.should == 1
    @table.row_at(2).sub_table.size.should == 1
  end
end