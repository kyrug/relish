require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  
  it "is not valid without an email" do
    user = User.new
    user.should_not be_valid
  end
  
 
end