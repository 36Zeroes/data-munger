require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe 'DataMunger' do
  it 'should be a module' do
    DataMunger.class.should == Module
  end
  
  it 'can take an array or single object and ensure an array' do
    DataMunger.arrify(:one).should == [:one]
    DataMunger.arrify(:one, :two).should == [:one, :two]
    DataMunger.arrify([:one]).should == [:one]
    DataMunger.arrify([:one, :two]).should == [:one, :two]    
  end
end