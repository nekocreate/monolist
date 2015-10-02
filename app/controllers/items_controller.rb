class ItemsController < ApplicationController
  before_action :logged_in_user , except: [:show]
  before_action :set_item, only: [:show]

  def new
    if params[:q] # 検索ワード(name=q)を指定したときはAPIを用いて商品検索結果を@amazon_itemsに渡す
      response = Amazon::Ecs.item_search(params[:q] , 
                                  :search_index => 'All' , 
                                  :response_group => 'Medium' , 
                                  :country => 'jp')
      @amazon_items = response.items
    end
  end

  def show
    @want_users = Want.where(item_id: @item.id) # Wantテーブルのitem_idカラムに@item.idの値を持つレコードをwant_usersに格納
    @have_users = Have.where(item_id: @item.id) # Haveテーブルのitem_idカラムに@item.idの値を持つレコードをhave_usersに格納
  end

  private
  def set_item
    @item = Item.find(params[:id])
  end
end
