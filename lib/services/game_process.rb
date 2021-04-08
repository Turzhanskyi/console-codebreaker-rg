# frozen_string_literal: true

module CodebreakerConsole
  module GameProcess
    def game_process
      loop do
        return lost unless game.attempts_available?

        message(:'play.enter_guess')
        process_answer_game(user_enter)
      end
    end

    def process_answer_game(answer)
      guess = Codebreaker::Guess.new(answer)
      if guess.valid?
        puts compare(guess.value)
      elsif guess.value == I18n.t(:'play.hint')
        request_of_hint
      else
        message(:'errors.message.wrong_command')
      end
    end

    def process_answer_menu(answer)
      send(answer)
      main_menu if answer != I18n.t(:'play.start_command')
    end

    def compare(answer)
      return won if game.win?(answer)

      Codebreaker::Guess.decorate(game.compare(answer))
    end

    def request_of_hint
      return message(:'errors.message.no_hints') unless game.hints_available?

      puts "#{I18n.t(:'play.hint')}: #{game.hint}"
    end

    def describe_difficulty_levels
      Codebreaker::Constants::LEVELS.each do |_, difficulty|
        args = { name: difficulty[:name], attempts: difficulty[:attempts],
                 hints: difficulty[:hints] }
        puts I18n.t(:'registration.difficulty_description', **args)
      end
    end
  end
end
