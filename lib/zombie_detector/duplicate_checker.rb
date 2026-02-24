# lib/zombie_detector/duplicate_checker.rb
require 'time'
require 'set'

module ZombieDetector
  class DuplicateChecker
    def initialize(replies)
      # 🌟 1. 投稿時間が古い順（昇順）に並び替える
      # これにより「本家（オリジナル）」が必ず先頭に来るようにします
      @replies = replies.sort_by { |r| Time.parse(r['created_at']) }
    end

    def analyze
      seen_ngrams = [] 
      
      @replies.map do |reply|
        text = reply['text'] || ""
        is_verified = reply['verified'] == true
        current_ngrams = make_ngrams(text)
        
        # 🌟 類似度の最大値を保持
        max_similarity = 0.0
        
        if is_verified && !current_ngrams.empty?
          seen_ngrams.each do |target_ngrams|
            sim = calculate_similarity(current_ngrams, target_ngrams)
            max_similarity = sim if sim > max_similarity
          end
        end

        # 1. 小数点第3位までの類似度を記録 (例: 0.854)
        reply['similarity_rate'] = max_similarity.round(3)

        # 2. ゾンビスコアを「%」として算出 (例: 85.4)
        # 100を掛けて、より直感的なパーセンテージにします
        percentage_score = (max_similarity * 100).round(1)
        reply['zombie_score'] = percentage_score

        # 3. 最終的な「ゾンビフラグ」は当初の予定通り 80% 基準で判定
        if percentage_score >= 80.0
          reply['is_zombie_copy'] = true
        else
          # 似ていない（オリジナル）なら記憶に追加
          seen_ngrams << current_ngrams unless text.empty?
          reply['is_zombie_copy'] = false
        end
        
        reply
      end
    end

    private

    # 文章を2文字ずつのセットにバラバラにするメソッド(N-gram)
    def make_ngrams(text)
      text.chars.each_cons(2).map(&:join).to_set
    end

    # 2つのセットが何％一致しているか計算する（Jaccard係数）
    def calculate_similarity(set1, set2)
      return 0.0 if set1.empty? || set2.empty?
      intersection = (set1 & set2).size.to_f
      union = (set1 | set2).size.to_f
      intersection / union
    end
  end
end