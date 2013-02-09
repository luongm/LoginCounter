require 'test_helper'

class UserTest < ActiveSupport::TestCase
	def setup
		@user = User.new
	end

	test "username can't be null" do
		@user.password = "blah"
		assert !@user.save, "username can't be saved as null"
	end

	test "username can't be empty" do
		@user.username = ""
		@user.password = "blah"
		assert !@user.save, "username can't be saved as empty"
	end

	test "username can't be longer than 128 characters" do
		@user.username = "a"*129
		@user.password = "blah"
		assert !@user.save, "username can't be shorter than 128 characters"
	end

	test "password can't be null" do
		@user.username = "gau"
		assert !@user.save, "password can't be saved as null"
	end

	test "password can't be empty" do
		@user.username = "gau"
		@user.password = ""
		assert !@user.save, "username can't be saved as empty"
	end

	test "password can't be longer than 128 characters" do
		@user.username = "gau"
		@user.password = "a"*129
		assert !@user.save, "username can't be shorter than 128 characters"
	end

	test "cannot signup with duplicated username" do
		user1 = User.new
		user1.username = "gau"
		user1.password = "blah"
		assert user1.save
		user2 = User.new
		user2.username = "gau"
		user2.password = "foo"
		assert !user2.save
	end
end
