ENV['RAILS_ENV'] = 'test'
require File.expand_path(File.dirname(__FILE__) + '/../config/environment')
require 'test_help'
require 'shoulda'
require 'shoulda/rails'
require 'factory_girl'
require 'matchy'


class ActiveSupport::TestCase
  # Drop all columns after each test case.
  def teardown
    MongoMapper.database.collections.each do |coll|
      coll.remove  
    end
  end

  # Make sure that each test case has a teardown
  # method to clear the db after each test.
  def inherited(base)
    base.define_method teardown do 
      super
    end
  end
end

class ActionController::TestCase

  def self.should_be_signed_in_as(&block)
    should "be signed in as #{block.bind(self).call}" do
      user = block.bind(self).call
      assert_not_nil user,
        "please pass a User. try: should_be_signed_in_as { @user }"
      assert_equal user.id,   session[:user_id],
        "session[:user_id] is not set to User's id"
    end
  end

  def self.should_not_be_signed_in
    should "not be signed in" do
      assert_nil session[:user_id], "session[:user_id] is not nil"
    end
  end
end
