# lib/zombie_detector/duplicate_checker.rb
require 'time'

module ZombieDetector
  class DuplicateChecker
    def initialize(replies)
      # 🌟 1. 投稿時間が古い順（昇順）に並び替える
      # これにより「本家（オリジナル）」が必ず先頭に来るようにします
      @replies = replies.sort_by { |r| Time.parse(r['created_at']) }
    end

    def analyze
      seen_texts = [] # すでに出現した文章を記録するリスト
      
      @replies.map do |reply|
        text = reply['text']
        
        # 🌟 2. 前提条件：認証済み（verified）でなければコピペ判定すらしない
        # （一般ユーザーがたまたま同じことを言ってもゾンビとはみなさない）
        is_verified = reply['verified'] == true
        
        # 🌟 3. 重複チェック
        # すでに同じ文章（seen_texts）が存在し、かつ認証済みなら「ゾンビ」
        if is_verified && seen_texts.include?(text)
          reply['is_zombie_copy'] = true
          reply['zombie_score'] = 100
        else
          # 初めて見る文章なら「オリジナル」候補としてリストに追加
          seen_texts << text
          reply['is_zombie_copy'] = false
          reply['zombie_score'] = 0
        end
        reply
      end
    end
  end
end