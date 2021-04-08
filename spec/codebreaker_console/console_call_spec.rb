# frozen_string_literal: true

RSpec.describe CodebreakerConsole::Console do
  include_context 'with game creation'

  context 'when run console' do
    it 'call main menu' do
      expect(console).to receive(:main_menu)
      console.call
    end
  end

  describe '#registration' do
    context 'when correct user enter' do
      let(:user_name) { 'user_test' }

      it 'return name' do
        allow(console).to receive(:user_enter).and_return(user_name)
        allow(console).to receive(:message).with(:'registration.enter_user_name')
        expect(user.name).to eq(user_name)
      end

      it 'return difficulty level' do
        console.instance_variable_set(:@difficulty, game.difficulty)
        allow(console).to receive(:select_difficulty_level).and_return(game.difficulty)
        expect(game.difficulty[:name]).to eq(:easy)
      end
    end

    context 'when incorrect user enter' do
      let(:min_length_and_correct_user_names) { %w[a user_test] }
      let(:max_length_and_correct_user_names) { ['a' * 21, 'user_test'] }
      let(:incorrect_correct_difficulty_names) { ['abcdf', game_level[:easy]] }

      it 'show error message when short name length' do
        allow(console).to receive(:user_enter).and_return(*min_length_and_correct_user_names)
        allow(console).to receive(:message).with(:'registration.enter_user_name').twice
        expect(console).to receive(:message).with(:'errors.message.user').once
        console.send(:enter_name)
      end

      it 'show error message when too long name' do
        allow(console).to receive(:user_enter).and_return(*max_length_and_correct_user_names)
        allow(console).to receive(:message).with(:'registration.enter_user_name').twice
        expect(console).to receive(:message).with(:'errors.message.user').once
        console.send(:enter_name)
      end

      it 'show error message when wrong difficulty selected' do
        allow(console).to receive(:user_enter).and_return(*incorrect_correct_difficulty_names)
        allow(console).to receive(:message).with(:'registration.select_difficulty').twice
        expect(console).to receive(:message).with(:'errors.message.difficulty').once
        console.send(:select_difficulty_level)
      end
    end
  end

  describe '#game_process' do
    let(:secret_code) { '6543' }

    before do
      allow(console).to receive(:loop).and_yield
      game.instance_variable_set(:@secret_code, secret_code)
      console.instance_variable_set(:@game, game)
      allow(console).to receive(:registration).and_return(game)
      allow(console).to receive(:user_enter).and_return(I18n.t(:'play.start_command'))
    end

    after do
      console.send(:start)
    end

    context 'when correct user guess entered' do
      let(:secret_code) { '6543' }
      let(:hint_value) { '1' }

      it 'show win' do
        allow(console).to receive(:user_enter).and_return(secret_code)
        allow(console).to receive(:message).with(:'play.enter_guess')
        allow(console).to receive(:save_result?).and_return(I18n.t(:'play.yes'))
        allow(console).to receive(:main_menu)
        expect(console).to receive(:message).with(:'play.win')
      end

      it 'show hint if available for user' do
        allow(console).to receive(:user_enter).and_return(I18n.t(:'play.hint'))
        allow(game).to receive(:hint).and_return(hint_value)
        allow(console).to receive(:message).with(:'play.enter_guess')
        expect(console).to receive(:puts).with("#{I18n.t(:'play.hint')}: #{hint_value}")
      end

      it 'show message when no hints available' do
        allow(game).to receive(:hints_available?).and_return(false)
        allow(console).to receive(:user_enter).and_return(I18n.t(:'play.hint'))
        allow(console).to receive(:message).with(:'play.enter_guess')
        expect(console).to receive(:message).with(:'errors.message.no_hints')
      end

      it 'lost game when all attempts used' do
        allow(game).to receive(:attempts_available?).and_return(false)
        allow(console).to receive(:message).with(:'play.lost')
        allow(console).to receive(:puts).with(game.secret_code)
        expect(console).to receive(:main_menu)
      end
    end

    context 'when incorrect command entered' do
      let(:user_name) { 'user_test' }

      it 'show corresponding message' do
        allow(game).to receive(:hints_available?).and_return(false)
        allow(console).to receive(:user_enter).and_return(user_name)
        allow(console).to receive(:message).with(:'play.enter_guess')
        expect(console).to receive(:message).with(:'errors.message.wrong_command')
      end
    end
  end

  describe '#request_of_hints' do
    let(:secret_code) { '1234' }

    context 'when call request of hint' do
      before do
        console.instance_variable_set(:@game, game)
        game.instance_variable_set(:@secret_code, secret_code)
        allow(console).to receive(:loop).and_yield
      end

      it 'give a hint if available' do
        allow(console).to receive(:user_enter).and_return(I18n.t(:'play.hint'))
        expect(console).to receive(:request_of_hint).and_call_original
        console.send(:request_of_hint)
      end

      it 'show error message for hints not available' do
        allow(game).to receive(:hints_available?).and_return(false)
        allow(console).to receive(:user_enter).and_return(I18n.t(:'play.hint'))
        expect(console).to receive(:message).with(:'errors.message.no_hints')
        allow(console).to receive(:request_of_hint).and_call_original
        console.send(:request_of_hint)
      end
    end
  end
end
