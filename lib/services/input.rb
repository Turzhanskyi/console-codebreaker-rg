# frozen_string_literal: true

module CodebreakerConsole
  module Input
    def user_enter
      enter = gets.chomp.downcase
      if exit?(enter)
        message(:goodbye)
        exit
      end
      enter
    end

    def exit?(answer)
      answer == I18n.t(:'play.exit_command')
    end
  end
end
