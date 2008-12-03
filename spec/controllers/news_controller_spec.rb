require File.dirname(__FILE__) + '/../spec_helper'

shared_examples_for "all news users" do
  it "should load the index" do
    get :index
    response.should render_template('news/index')
  end
end

describe NewsController do
  fixtures :users

  describe "in use by a non-admin" do
    before(:each) do
      @admin = users(:rob_mccready)
      @admin.roles.clear
      @admin.roles << Role.administrator
      @user = users(:alex_kroman)
      @user.roles.clear
      controller.stub!(:current_user).and_return(@user)
    end

    it_should_behave_like "all news users"

    it "should not create a new news" do
      count = SystemMessage.count
      post :create, :message => {:body => 'hi world'}
      SystemMessage.count.should == count
    end

    it "should not update an existing news" do
      msg = SystemMessage.create!(:body => 'hi world', :author => @admin)
      put :update, :id => msg.id, :message => {:body => 'hi there'}
      msg.reload
      msg.body.should == 'hi world'
    end

    it "should not delete an existing news" do
      msg = SystemMessage.create!(:body => 'hi world', :author => @admin)
      delete :destroy, :id => msg.id
      lambda { msg.reload }.should_not raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "in use by an admin" do
    before(:each) do
      @admin = users(:rob_mccready)
      @admin.roles.clear
      @admin.roles << Role.administrator
      @user = users(:alex_kroman)
      @user.roles.clear
      @user.roles << Role.administrator
      controller.stub!(:current_user).and_return(@user)
    end

    it_should_behave_like "all news users"

    it "should create a new news" do
      count = SystemMessage.count
      post :create, :message => {:body => 'hi world'}
      response.should redirect_to(:action => 'index')
      SystemMessage.count.should == count + 1
    end

    it "should update an existing news" do
      msg = SystemMessage.create!(:body => 'hi world', :author => @user)
      put :update, :id => msg.id, :message => {:body => 'hi there'}
      response.should redirect_to(:action => 'index')
      msg.reload
      msg.body.should == 'hi there'
    end

    it "should delete an existing news" do
      msg = SystemMessage.create!(:body => 'hi world', :author => @user)
      delete :destroy, :id => msg.id
      response.should redirect_to(:action => 'index')
      lambda { msg.reload }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

end
