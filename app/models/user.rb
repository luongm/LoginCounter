class User < ActiveRecord::Base
	attr_accessible :count, :password, :username

	validates :username, presence: true, length: {maximum: 128}, uniqueness: true
	validates :password, length: {maximum: 128}, on: :create
	# has_secure_password
end
