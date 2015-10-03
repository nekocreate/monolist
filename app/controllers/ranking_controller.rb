class RankingController < ApplicationController
    
    # haved数 wanted数 による並び替え処理は、既に存在しているモデルのテーブルを使えばよいので
    # あえてrankingモデルを作らなかった。
    
    def have
        @haved_ranks = Have.group(:item_id).order("count_all desc").limit(10).count
    end
    
    def want
        @wanted_ranks = Want.group(:item_id).order("count_all desc").limit(10).count
    end
end
