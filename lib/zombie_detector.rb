# zombie_detector/lib/zombie_detector.rb
# Gemが読み込まれたときにいちばん最初に読み込まれるファイル
# gem 'zombie_detector' と書いたときに、RubyGemsは自動的に lib/zombie_detector.rb(Gemの名前.rb) を探しに行くルール（規約）がある

require "zombie_detector/version"
require "zombie_detector/detector"

module ZombieDetector
  class << self
    # ショートカットメソッド: ZombieDetector.score(user_data) で呼べるようにする
    def score(user_data)
      Detector.new(user_data).score
    end

    # ゾンビかどうかを真偽値で返す便利なメソッド
    def zombie?(user_data, threshold: 50)
      score(user_data) >= threshold
    end
  end
end