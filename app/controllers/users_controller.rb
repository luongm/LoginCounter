class UsersController < ApplicationController
  # POST /users/login
  def login
    user = User.where("username = ? AND password = ?", params[:user], (params[:password] or ""))[0]
    if user.nil?
      errCode = -1 # ERR_BAD_CREDENTIALS
      respond_to do |format|
        format.json { render json: {errCode: errCode} }
      end
    else
      user.count += 1
      user.save
      errCode = 1 # SUCCESS
      respond_to do |format|
        format.json { render json: {errCode: errCode, count: user.count} }
      end
    end
  end

  # POST /users/add
  def add
    user = User.new
    user.username = params[:user]
    user.password = params[:password]
    user.count = 1
    
    errCode = 1 # SUCCESS
    if user.save
      respond_to do |format|
        format.json { render json: {errCode: errCode, count: 1} }
      end
    else
      if user.username.nil? or user.username == "" or user.username.length > 128
        errCode = -3 # ERR_BAD_USERNAME
      elsif user.password.length > 128
        errCode = -4 # ERR_BAD_PASSWORD
      else
        errCode = -2 # ERR_USER_EXISTS
      end
      respond_to do |format|
        format.json { render json: {errCode: errCode} }
      end
    end
  end

  # POST /TESTAPI/resetFixture
  def reset
    User.delete_all
    respond_to do |format|
      format.json { render json: {errCode: 1} }
    end
  end

  # POST /TESETAPI/unitTests
  def unitTests
    output = `rspec`
    total = /(\d+) example[s]/.match(output)[1]
    failed = /(\d+) failure[s]/.match(output)[1]
    respond_to do |format|
      format.json { render json: {totalTests: total, nrFailed: failed, output: output} }
    end
  end
end
