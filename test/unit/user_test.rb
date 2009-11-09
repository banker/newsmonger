require 'test_helper'
 
class UserTest < ActiveSupport::TestCase
  should "validate presence of email" do
    user = User.new
    user.save
    assert_match /empty/, user.errors.on(:email)
    user.email = 'foo@bar.com'
    user.save
    assert_nil user.errors.on(:email)
  end
  
  should "validate length of email" do
    user = User.new
    user.email = 'a@a'
    user.save
    assert user.errors.on(:email)
  end
  
  should "always store email as lower case" do
    user = User.new
    user.email = 'F@FOOBAR.COM'
    user.save
    assert_equal 'f@foobar.com', user.email
  end
  
  should "be able to set user's reset password code" do
    user = Factory(:user)
    assert_nil user.reset_password_code

    assert_nil user.reset_password_code_until
    
    user.set_password_code!
    user.reset_password_code
    assert user.reset_password_code_until.is_a?(Time)
  end
  
  context "Authentication" do
    should 'work with existing email and correct password' do
      user = Factory(:user)
      assert_equal user, User.authenticate(user.email, 'testing')
    end
    
    should 'work with existing email (case insensitive) and password' do
      user = Factory(:user)
      assert_equal user, User.authenticate(user.email.upcase, 'testing')
    end
    
    should 'not work with existing email and incorrect password' do
      assert_nil User.authenticate('john@doe.com', 'foobar')
    end
    
    should 'not work with non-existant email' do
      assert_nil User.authenticate('foo@bar.com', 'foobar')
    end
  end
  
  context "password" do
    should 'be required if crypted password is blank' do
     user = User.new
     user.save
     assert user.errors.on(:password)
    end
    
    should 'not be required if crypted password is present' do
      user = User.new
      user.crypted_password = BCrypt::Password.create('foobar')
      user.save
      assert_nil user.errors.on(:password)
    end
    
    should "validate the length of password" do
      user = User.new
      user.password = '1234'
      user.save
      assert user.errors.on(:password)
      user.password = '123456'
      assert_equal "is invalid", user.errors.on(:password)
    end
  end
end
