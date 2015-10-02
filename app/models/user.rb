class User < ActiveRecord::Base
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :following_relationships, class_name:  "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :following_users, through: :following_relationships, source: :followed
  has_many :followed_relationships, class_name:  "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followed_users, through: :followed_relationships, source: :follower

  has_many :ownerships , foreign_key: "user_id", dependent: :destroy
  has_many :items ,through: :ownerships
  
  # wants は、ownershipsテーブルでtypeがwantである行の集まりの仮想的な中間テーブルを指す
  # want_items で ownershipsテーブルからtypeがWantであるものを取得できる
  has_many :wants, class_name: "Want", foreign_key: "user_id", dependent: :destroy
  has_many :want_items, through: :wants, source: :item

  # haves は、ownershipsテーブルでtypeがhaveである行の集まりの仮想的な中間テーブル
  # Haveしたアイテムの一覧が have_itemsで取得できるようになる
  has_many :haves, class_name: "Have", foreign_key: "user_id", dependent: :destroy
  has_many :have_items, through: :haves, source: :item


  # 他のユーザーをフォローする
  def follow(other_user)
    following_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    following_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following_users.include?(other_user)
  end

  ## TODO 実装
  def have(item)
    # create でも良いが、念のために find_or_create_by を使ってみた。
    # haves.create(item_id: item.id)
    haves.find_or_create_by(item_id: item.id)
  end

  def unhave(item)
    haves.find_by(item_id: item.id).destroy
  end

  def have?(item)
    haves.find_by(item_id: item.id)
  end

  def want(item)
    # create でも良いが、念のために find_or_create_by を使ってみた。
    # wants.create(item_id: item.id)
    wants.find_or_create_by(item_id: item.id)
  end

  def unwant(item)
    wants.find_by(item_id: item.id).destroy
  end

  def want?(item)
    wants.find_by(item_id: item.id)
  end
end
