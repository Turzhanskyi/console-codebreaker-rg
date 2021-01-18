# frozen_string_literal: true

shared_context 'with game creation' do
  let(:game_level) { { easy: :easy, medium: :medium, hell: :hell } }
  let(:user) { Codebreaker::User.new('user_test') }
  let(:difficulty) { Codebreaker::Difficulty.new(game_level[:easy]) }
  let(:game) { Codebreaker::Game.new(user, difficulty) }
  let(:console) { described_class.new('spec/fixtures/test_statistics.yml') }
end
