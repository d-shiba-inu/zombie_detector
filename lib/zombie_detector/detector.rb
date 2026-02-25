# lib/zombie_detector/detector.rb
require 'time' # Railsの外では自分で呼ぶ必要がある

module ZombieDetector
  class Detector
    def initialize(user_data)
      @user = user_data
    end

    # 単体での合計スコア（最大50点）
    def score
      points = 0
      points += check_account_age     # 15点
      points += check_reciprocal_FF   # 20点
      points += check_verified_bonus  # 15点
      points
    end

    private

    # 🌟 キーが文字列でもシンボルでも取得できる補助メソッド
    def fetch(key)
      @user[key.to_s] || @user[key.to_sym]
    end

    # 条件2: アカウント作成が半年前以内
    def check_account_age
      return 0 if @user['created_at'].nil?
      # begin...rescue で囲むのが Ruby の最も標準的で安全な書き方です
      begin
        created_at = Time.parse(@user['created_at'])
        (Time.now - created_at) < 180 * 24 * 60 * 60 ? 15 : 0
      rescue
        0 # 解析に失敗したら 0点を返す
      end
    end

    # 条件3: 相互フォロー水増し判定
    def check_reciprocal_FF
      followers = @user['followers_count'].to_i
      following = @user['following_count'].to_i
      return 0 if following == 0
      # 500人以上 かつ FF比がほぼ1:1（0.8〜1.2）
      if followers >= 500 && (followers.to_f / following).between?(0.8, 1.2)
        20
      else
        0
      end
    end

    # 条件4: ブルーバッジ加点
    def check_verified_bonus
      # 🌟 verified の値が true もしくは "true" なら加点
      val = fetch('verified')
      (val == true || val == "true") ? 15 : 0
    end
  end
end