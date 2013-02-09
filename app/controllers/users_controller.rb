class UsersController < ApplicationController
  # POST /users/login
  def login
    user = User.where("username = ? AND password = ?", params[:user], params[:password])[0]
    if !user.nil?
      user.count += 1
      user.save
      err_code = 1 # SUCCESS
      respond_to do |format|
        format.json { render json: {err_code: err_code, count: user.count} }
      end
    else
      err_code = -1 # ERR_BAD_CREDENTIALS
      respond_to do |format|
        format.json { render json: {err_code: err_code} }
      end
    end
  end

  # POST /users/add
  def add
    @user = User.new
    @user.username = params[:user]
    @user.password = params[:password]
    @user.count = 1

    err_code = 1 # SUCCESS
    if @user.save
      respond_to do |format|
        format.json { render json: {err_code: err_code, count: 1} }
      end
    else
      if not @user.username or @user.username == ""
        err_code = -3 # ERR_BAD_USERNAME
      elsif not @user.password or @user.password == ""
        err_code = -4 # ERR_BAD_PASSWORD
      else
        err_code = -2 # ERR_USER_EXISTS
      end
      respond_to do |format|
        format.json { render json: {err_code: err_code} }
      end
    end
  end

  # POST /TESTAPI/resetFixture
  def reset
    @user = User.delete_all
  end

  # POST /TESETAPI/unitTests
  def unitTests
  end
end
