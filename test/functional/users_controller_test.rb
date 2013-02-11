require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should add user" do
    assert_difference('User.count') do
      post :add, { user: "c", password: "b" }
    end
  end

  test "should increment count with valid credentials for each login" do
    assert_difference('User.find_by_username("user_one").count', +3) do
      3.times do
        post 'login', { user: "user_one", password: "MyString1" }
      end
    end
  end

  test "should reset" do
    post 'reset'
    assert_equal User.count, 0
  end

  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:users)
  # end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  # test "should create user" do
  #   assert_difference('User.count') do
  #     post :create, user: { count: @user.count, password: @user.password, username: @user.username }
  #   end

  #   assert_redirected_to user_path(assigns(:user))
  # end

  # test "should show user" do
  #   get :show, id: @user
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get :edit, id: @user
  #   assert_response :success
  # end

  # test "should update user" do
  #   put :update, id: @user, user: { count: @user.count, password: @user.password, username: @user.username }
  #   assert_redirected_to user_path(assigns(:user))
  # end

  # test "should destroy user" do
  #   assert_difference('User.count', -1) do
  #     delete :destroy, id: @user
  #   end

  #   assert_redirected_to users_path
  # end
end
