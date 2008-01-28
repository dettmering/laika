require File.dirname(__FILE__) + '/../spec_helper'

describe PatientData, "can copy itself" do
  fixtures :patient_data, :registration_information
  
  before(:each) do
    @patient_data = patient_data(:steve)
    @patient_data_copy = @patient_data.copy
  end

  it "should copy its name when copied" do
    @patient_data_copy.name.should == 'steve'
  end
  
  it "should copy its registration information" do
    @patient_data_copy.registration_information.should_not be_nil
    @patient_data_copy.registration_information.first_name.should == 'Steve'
    @patient_data_copy.registration_information.last_name.should == 'Stevenson'
  end
end