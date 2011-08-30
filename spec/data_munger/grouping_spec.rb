require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe 'RecordSet when grouped' do
  before do
    @records = DataMunger::RecordSet.new([
        {:first => 1, :second => 'a'},
        {:first => 1, :second => 'a'},
        {:first => 1, :second => 'b'},
        {:first => 2, :second => 'c'}
      ]).group_on(:first)
  end
  
  it 'should generate group records, each having a RecordSet of sub-records' do
    @records.each do |group|
      group.should be_a(DataMunger::GroupingRecord)
      group.records.each do |record|
        record.should be_a(DataMunger::Record)
      end
    end
  end
  
  it 'should group common values for the grouped field' do
    @records.size.should == 2 # groups
    @records.to_a[0].to_hash.should == {:first => 1}
    @records.to_a[1].to_hash.should == {:first => 2}
  end
  
  it 'should have subrecords for groups' do
    @records.first.records.size.should == 3
    @records.to_a[1].records.size.should == 1
  end
end

describe 'RecordSet when grouped on multiple fields' do
  before do
    @records = DataMunger::RecordSet.new([
        {:first => 1, :second => 'a'},
        {:first => 1, :second => 'a'},
        {:first => 1, :second => 'b'},
        {:first => 2, :second => 'c'}
      ]).group_on(:first, :second)
  end
  
  it 'should group common values for all fields' do
    @records.size.should == 3
    @records.to_a[0].values.should == [1,'a']
    @records.to_a[1].values.should == [1,'b']
    @records.to_a[2].values.should == [2,'c']
  end
  
  it 'should have subrecords for groups' do
    @records.first.records.size.should == 2 
    @records.to_a[1].records.size.should == 1
    @records.to_a[2].records.size.should == 1
  end
end