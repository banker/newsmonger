require 'test_helper'

class StoryTest < ActiveSupport::TestCase

  context "a valid story" do 
    should "require a title" do 
      @story = Story.new(Factory.attributes_for(:story).merge(:title => nil))
      assert !@story.save
      assert_equal "can't be empty", @story.errors.on(:title)
    end

    should "require a url" do 
      @story = Story.new(Factory.attributes_for(:story).merge(:url => nil))
      assert !@story.save
      assert_equal "can't be empty", @story.errors.on(:url)
    end

    should "reject a bad url" do 
      @story = Story.new(Factory.attributes_for(:story).merge(:url => "not a valid url"))
      assert !@story.save
      assert_equal "is invalid", @story.errors.on(:url)
    end

    should "require a user" do 
      @story = Story.new(Factory.attributes_for(:story).merge(:user => nil))
      assert !@story.save
      assert_equal "can't be empty", @story.errors.on(:user_id)
    end
  end

  context "a new story" do 
    setup do 
      @story = Factory(:story)
    end

    should "be created" do 
      assert_equal 1, Story.count
    end

    should "contain the created date" do
      assert @story.created_at.is_a?(Time)
    end

    should "contain the updated time" do 
      last_update = @story.updated_at
      sleep 2
      @story.save
      assert @story.updated_at > last_update
    end

    should "start with one point" do 
      assert_equal 1, @story.votes 
    end

    context "a newly created comment" do 
      should "generate a slug" do 
        assert_match /google-launches/, @story.slug
      end

      should "not append integers to the slug" do 
        assert_match /\w+$/, @story.slug
      end
      
      should "generate a unique slug even when titles are the same" do 
        @identical = Factory(:story)
        assert_not_equal @identical.slug, @story.slug
      end
    end

    context "with voting users" do 
      setup do 
        @user = Factory(:user)
      end

      should "increment point when a user upvotes" do 
        Story.upvote(@story, @user.id)
        @story = Story.find(@story.id)
        assert_equal 2, @story.votes
        assert @story.voters.include?(@user.id)
      end

      should "ignore upvote if user has already upvoted" do 
        @story.upvote(@user)
        assert_equal 2, @story.votes
        @story.upvote(@user)
        assert_equal 2, @story.votes
      end

      should "ignore update if user who posted tries to vote" do
        assert_equal 1, @story.votes
        @story.upvote(@story.user)
        assert_equal 1, @story.votes
      end
    end
  end
end
