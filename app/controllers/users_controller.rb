class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  
  def test
    # @user = User.new
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      
      ### sessionを使っていない場合は、新規ユーザー登録直後に、再度ログインが必要になってしまうので
      ### ここでsessionを使っておく！
      session[:user_id] = @user.id
      redirect_to @user, notice: "会員登録が完了しました"
    else
      render 'new'
    end
  end
  
  def show
    #@items = @user.items.group(:item_id)
    # PG::GroupingError: ERROR:  column "items.id" must appear in the GROUP BY clause or be used in an aggregate function
    # 上記の場合だと、Herokuにデプロイ後、グルーピングエラーが出てしまった
    # 下記のようにするとエラーが出なくなったが、その理由がわからない。
    # @items = @user.items
    @items = @user.items.group("items.id")
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
end
