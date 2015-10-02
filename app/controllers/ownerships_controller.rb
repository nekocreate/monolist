class OwnershipsController < ApplicationController
  before_action :logged_in_user

  # HaveまたはWantボタンが押されたとき
  def create
    
    # render text: params
    # createアクションにpostされたときのparams
    # {"_method"=>"post", "authenticity_token"=>"bWM+d61ejMW1ZDCv56XbUGxVwikwalvNPBlnsJdAMqFylZ7TELg+oCcIWIygPTUqkZ9EdkjbYuzu2LSFBDEkDw==", "asin"=>"B00777SXPS", "type"=>"Want", "controller"=>"ownerships", "action"=>"create"}
    
    if params[:asin]
      # Itemをasinという値で検索して、存在する場合はそのデータを返し、それ以外は与えた値(今回はasin)でItem.newした状態のItemモデルを返します
      @item = Item.find_or_initialize_by(asin: params[:asin])
    else
      @item = Item.find(params[:item_id])
    end

    # itemsテーブルに存在しない場合はAmazonのデータを登録する。
    if @item.new_record?
      begin
        # TODO 商品情報の取得 Amazon::Ecs.item_lookupを用いてください
        # response = {}
        response = Amazon::Ecs.item_lookup(params[:asin], :response_group => 'Medium', :country => 'jp')
        # render text: response.inspect

      rescue Amazon::RequestError => e
        return render :js => "alert('#{e.message}')"
      end

      amazon_item       = response.items.first
      @item.title        = amazon_item.get('ItemAttributes/Title')
      @item.small_image  = amazon_item.get("SmallImage/URL")
      @item.medium_image = amazon_item.get("MediumImage/URL")
      @item.large_image  = amazon_item.get("LargeImage/URL")
      @item.detail_page_url = amazon_item.get("DetailPageURL")
      @item.raw_info        = amazon_item.get_hash
      @item.save!
    end

    # TODO ユーザにwant or haveを設定する
    # params[:type]の値ににHaveボタンが押された時には「Have」,
    # Wantボタンがされた時には「Want」が設定されています。

    type = params[:type]
    if type == "Have"
      current_user.have(@item)
      # flash[:success] = "アイテムをHaveしました" # Ajaxだとflashメッセージが表示されない
    end
    
    if type == "Want"
      current_user.want(@item)
      # flash[:success] = "アイテムをWantしました" # Ajaxだとflashメッセージが表示されない
    end
    
    # redirect_to request.referrer # remote true するときは redirectは必要ない
  end

  # Wantedまたは Havedボタンが押されたとき
  def destroy
    @item = Item.find(params[:item_id])

    # TODO 紐付けの解除。 
    # params[:type]の値ににHavedボタンが押された時には「Have」,
    # Wantedボタンがされた時には「Want」が設定されています。
    
    type = params[:type]
    if type == "Want"
      current_user.unwant(@item)
      # flash[:success] = "アイテムをunWantしました" # Ajaxだとflashメッセージが表示されない
    end
    
    if type == "Have"
      current_user.unhave(@item)
      # flash[:success] = "アイテムをunHaveしました" # Ajaxだとflashメッセージが表示されない
    end
    
    # redirect_to request.referrer # remote true するときは redirectは必要ない
  end

end
