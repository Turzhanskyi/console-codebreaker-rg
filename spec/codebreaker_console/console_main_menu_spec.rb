# frozen_string_literal: true

RSpec.describe CodebreakerConsole::Console do
  include_context 'with game creation'

  after(example: :calls_exit) do
    console.send(:start)
  end

  context 'when correct user enter' do
    let(:user_name) { 'user_test' }

    before do
      allow(console).to receive(:message).with(:main_menu)
      allow(console).to receive(:enter_name).and_return(user_name)
      allow(console).to receive(:select_difficulty_level) { game_level[:easy] }
    end

    it 'call method start' do
      allow(console).to receive(:user_enter).and_return(I18n.t(:'play.start_command'))
      allow(console).to receive(:message).and_return(:welcome)
      allow(console).to receive(:loop).and_yield
      expect(console).to receive(:start)
      console.call
    end
  end

  context 'when correct method calling' do
    let(:secret_code) { '1234' }
    let(:incorrect_correct_start_commands) { ['star', I18n.t(:'play.exit_command')] }

    before(:example, :start) do
      console.instance_variable_set(:@user, game.user)
      allow(console).to receive(:enter_name).and_return(game.user)
      console.instance_variable_set(:@difficulty, difficulty)
      allow(console).to receive(:select_difficulty_level) { difficulty }
    end

    it 'call method start', :start do
      allow(console).to receive(:loop).and_yield
      allow(console).to receive(:user_enter).and_return(secret_code)
      allow(console).to receive(:message).with(:'play.enter_guess')
      expect(console).to receive(:start).and_call_original
      console.send(:start)
    end

    it 'call method rules' do
      allow(console).to receive(:user_enter).and_return(I18n.t(:'play.rules_command'))
      allow(console).to receive(:rules).and_call_original
      expect { console.rules }.to output(/Codebreaker is a logic game/).to_stdout
    end

    it 'call method stats' do
      allow(console).to receive(:user_enter).and_return(I18n.t(:'play.stats_command'))
      expect(console).to receive(:stats).and_call_original
      console.stats
    end

    it 'call method exit', :calls_exit do
      allow(console).to receive(:gets).and_return(I18n.t(:'play.exit_command'))
      expect(console).to receive(:message).with(:goodbye)
      allow(console).to receive(:exit)
      console.user_enter
    end

    it 'checks main menu command', :calls_exit do
      allow(console).to receive(:user_enter).and_return(*incorrect_correct_start_commands)
      allow(console).to receive(:message).with(:main_menu).twice
      expect(console).to receive(:message).with(:'errors.message.unexpected_command').once
      allow(console).to receive(:message).and_return(I18n.t(:welcome))
      console.call
    end
  end
end
