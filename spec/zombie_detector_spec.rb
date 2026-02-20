# zombie_detector/spec/zombie_detector_spec.rb
require "zombie_detector" # 自分のGemを読み込む

RSpec.describe ZombieDetector do
  let(:zombie_data) do
    {
      'followers_count' => 10,       # キーを文字列にして detector.rb の @user['...'] に合わせる
      'following_count' => 1000,     # friends_count ではなく following_count にする
      'description' => "相互フォロー、副業、稼ぐ",
      'created_at' => "2026-02-01"
    }
  end

  it "スコアが正しく計算されること" do
    expect(ZombieDetector.score(zombie_data)).to be > 50
  end

  it "ゾンビ判定が true になること" do
    expect(ZombieDetector.zombie?(zombie_data)).to be true
  end
end