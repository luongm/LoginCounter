require 'spec_helper'

describe UsersController do
	context "When adding a user" do
		it "should get err_code 1 and count 1 with valid username and valid password" do
			post :add, { format: 'json', user: "c", password: "b" }
			response.should be_success # response code of 200

			response_body = JSON.parse response.body
			response_body.should have(2).items

			response_body.should include('err_code')
			response_body['err_code'].should == 1

			response_body.should include('count')
			response_body['err_code'].should == 1
		end

		it "should get err_code -4 with valid username and invalid password" do
			post :add, { format: 'json', user: "c", password: "b"*129 }
			response.should be_success # response code of 200

			response_body = JSON.parse response.body
			response_body.should have(1).item

			response_body.should include('err_code')
			response_body['err_code'].should == -4
		end

		it "should get err_code -3 with invalid username and valid password" do
			post :add, { format: 'json', user: "", password: "b" }
			response.should be_success # response code of 200

			response_body = JSON.parse response.body
			response_body.should have(1).item

			response_body.should include('err_code')
			response_body['err_code'].should == -3
		end

		it "should get err_code -2 if username already existed" do
			2.times {
				post :add, { format: 'json', user: "a", password: "b" }
			}
			response.should be_success # response code of 200

			response_body = JSON.parse response.body
			response_body.should have(1).item

			response_body.should include('err_code')
			response_body['err_code'].should == -2
		end
	end

	context "When logging in" do
		it "should get err_code 1 and count incremented if valid credentials" do
			post :add, { format: 'json', user: "a", password: "b" }

			post :login, { format: 'json', user: "a", password: "b" }
			response.should be_success # response code of 200

			response_body = JSON.parse response.body
			response_body.should have(2).item

			response_body.should include('err_code')
			response_body.should include('count')
			response_body['err_code'].should == 1

			expect {
				post :login, { format: 'json', user: "a", password: "b" }
			}.to change { JSON.parse(response.body)['count'] }.by(1)
		end

		it "should get err_code -1 if invalid credentials" do
			post :login, { format: 'json', user: "a", password: "b" }
			response.should be_success # response code of 200

			response_body = JSON.parse response.body
			response_body.should have(1).item

			response_body.should include('err_code')
			response_body['err_code'].should == -1
		end
	end
end