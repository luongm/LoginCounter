class UsersController < ApplicationController
  # GET /
  def home
    @user = User.new
    
    if params[:commit] == 'Login'
      login
    elsif params[:commit] == 'Add'
      add
    else
      respond_to do |format|
        format.html # home.html.erb
      end
    end
  end

  # POST /users/login
  def login
    @user = User.where("username = ? AND password = ?", params[:user], (params[:password] or ""))[0]

    errCode = 0
    jsonResult = {}
    
    if @user.nil?
      errCode = -1 # ERR_BAD_CREDENTIALS
      flash[:notice] = "Can't login because of invalid credentials!."
    else
      errCode = 1 # SUCCESS
      flash[:notice] = nil

      @user.count += 1
      @user.save
      jsonResult[:count] = @user.count
    end

    jsonResult[:errCode] = errCode
    respond_to do |format|
      format.html { render (errCode == 1 ? :profile : :home) }
      format.json { render json: jsonResult }
    end
  end

  # POST /users/add
  def add
    @user = User.new
    @user.username = params[:user]
    @user.password = params[:password]
    @user.count = 1
    
    errCode = 0
    jsonResult = {}

    if @user.save
      errCode = 1 # SUCCESS
      flash[:notice] = nil

      jsonResult[:count] = 1
    elsif @user.username.nil? or @user.username == "" or @user.username.length > 128
      errCode = -3 # ERR_BAD_USERNAME
      flash[:notice] = "Can't add user because of bad input username '#{@user.username}'."
    elsif @user.password.length > 128
      errCode = -4 # ERR_BAD_PASSWORD
      flash[:notice] = "Can't add user because of bad input password '#{@user.password}'."
    else
      errCode = -2 # ERR_USER_EXISTS
      flash[:notice] = "Can't add user because user '#{@user.username}' already existed."
    end

    jsonResult[:errCode] = errCode
    respond_to do |format|
      format.html { render (errCode == 1 ? :profile : :home) }
      format.json { render json: jsonResult }
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
