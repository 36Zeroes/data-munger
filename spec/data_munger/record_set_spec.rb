require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe DataMunger::RecordSet, 'when loaded from an array of hashes without specifying columns' do
  before do
    @data = DataMunger::RecordSet.new([
        {:first => 'a', :second => 'b'},
        {:first => '1', :second => '2', :third => 'ignored'}
      ])
  end
  
  it 'should build one record per array item' do
    @data.size.should == 2
    @data.each{|record| record.should be_a(DataMunger::Record)}
  end
    
  it 'should set the columns from the first hash' do
    @data.columns.should == [:first, :second]  
  end
    
  it 'should not be empty' do
    @data.empty?.should be_false
  end
    
  it 'should allow adding an additional column' do
    @data.add_column(:third) do |record|
      "Added #{record.second}"
    end
    @data.columns.should == [:first, :second, :third]
    @data.to_a[0].values.should == ['a', 'b', 'Added b']
    @data.to_a[1].values.should == ['1', '2', 'Added 2'] # overwrote the original :third value      
  end
    
  it 'should allow transforming of an existing col' do
    @data.transform_columns(:first, :second) do |row|
      [row[:first] * 2, row.second * 2]
    end
    @data.to_a[0].values.should == ['aa', 'bb']
    @data.to_a[1].values.should == ['11', '22', 'ignored']
  end
end

describe "Merging two result sets" do
  before do
    @first_data = DataMunger::RecordSet.new([
        {:common_key => '1', :in_first => 'a'},
        {:common_key => '2', :in_first => 'b'}
      ]
    )
    @second_data = [
        {:common_key => '1', :in_second => 'c'},
        {:common_key => 'not common', :in_second => 'who-cares?'}
      ]
    @second_record_set = DataMunger::RecordSet.new(@second_data)
    @first_data.merge_record_set(@second_record_set, :common_key)
  end
  
  it "should result in columns from both" do
    @first_data.columns.should eql([:common_key, :in_first, :in_second])
  end
  
  it "should not add new rows -- only lookup common mergekeys" do
    @first_data.size.should eql(2)
  end
  
  it "should merge the records into the object" do    
    merged_item = @first_data.first
    merged_item[:common_key].should eql('1')
    merged_item[:in_first].should eql('a')
    merged_item[:in_second].should eql('c')

    second_merged_item = @first_data.to_a[1]
    second_merged_item[:common_key].should eql('2')
    second_merged_item[:in_first].should eql('b')
    second_merged_item[:in_second].should eql(nil)
  end
  
  it "should not effect the argument to merge_record_set" do
    @second_record_set.size.should == 2
    @second_record_set.to_a.should == @second_data
  end
end