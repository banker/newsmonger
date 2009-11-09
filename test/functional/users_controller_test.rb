require 'test_helper'
 
class UsersControllerTest < ActionController::TestCase
  context "Visiting the signup form" do
    setup { get :new }
    should_respond_with :success
  end
  
  context "Attempting to signup with valid information" do
    setup { post :create, :user => Factory.attributes_for(:user) }
    should_change 'User.count', :by => 1
    
    should "sign user in" do
      session[:user_id].should == assigns(:user).id
    end
    
    should_redirect_to('home page') { root_path }
  end
  
  context "Attempting to signup with invalid information" do
    setup { post :create, :user => {}}
    should_not_change 'User.count'
    should_not_be_signed_in
    should_render_template :new
  end
end
