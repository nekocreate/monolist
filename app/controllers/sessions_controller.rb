class SessionsController < ApplicationController
  def new
    redirect_to new_item_path if logged_in?
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      session[:user_id] = @user.id
      flash[:info] = "logged in as #{@user.name}"
      # redirect_to @user
      redirect_to new_item_path #ログイン後 items/new（アイテムを追加）ページへリダイレクト
    else
      flash[:danger] = 'invalid email/password combination'
      render 'new'
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end