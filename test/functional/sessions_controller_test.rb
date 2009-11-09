require 'test_helper'
 
class SessionsControllerTest < ActionController::TestCase
  context "Visiting the sign in form" do
    setup { get :new }
    should_respond_with :success
    should "display signup form" do
      assert_select 'form[action=?]', session_path do
        assert_select 'input[id=?]', 'email'
        assert_select 'input[id=?]', 'password'
      end
    end
  end
  
  context "Submitting the sign in form with good credentials" do
    setup do
      @user = Factory(:user)
      post :create, :email => @user.email, :password => 'testing'
    end
    should_be_signed_in_as { @user }
    should_redirect_to("root") { root_path }
  end
  
  context "Submitting the sign in form with bad credentials" do
    setup do
      @user = Factory(:user)
      post :create, :email => @user.email, :password => 'FAIL'
    end
    
    should_not_be_signed_in
    should_redirect_to('sign in') { new_session_path }
  end
  
  context "Logging out" do
    setup do
      session[:user_id] = 'john@doe.com'
      delete :destroy
    end
    
    should_not_be_signed_in
    should_respond_with :redirect
  end
end
