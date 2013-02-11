require 'spec_helper'
require 'user'

describe "A User" do
	subject { User.new }
	it { should respond_to(:username) }
	it { should respond_to(:password) }
	it { should respond_to(:count) }

	context 'with a valid password' do
		let(:user) { User.new }
		before { user.password = "a" }

		it 'is invalid without a name' do
			user.should_not be_valid
		end

		it 'is invalid with empty name' do
			user.username = ""
			user.should_not be_valid
		end

		it 'is invalid with name of more than 128 characters' do
			user.username = "b"*129
			user.should_not be_valid
		end

		it 'is valid with non-empty username' do
			user.username = "b"
			user.should be_valid
		end

		it 'is invalid with username already existed' do
			user1 = User.create(username: "b", password: "", count: 1)
			user.username = "b"
			user.should_not be_valid
		end
	end

	context 'with a valid username' do
		let(:user) { User.new }
		before { user.username = "a" }

		it 'is invalid with password of more than 128 characters' do
			user.password = "b"*129
			user.should_not be_valid
		end

		it 'is valid with no password' do
			user.should be_valid
		end

		it 'is valid with empty password' do
			user.password = ""
			user.should be_valid
		end

		it 'is valid with non-empty password' do
			user.password = "b"
			user.should be_valid
		end
	end
end