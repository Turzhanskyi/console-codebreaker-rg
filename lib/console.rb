# frozen_string_literal: true

module CodebreakerConsole
  class Console
    include Output
    include Input
    include GameProcess

    STORAGE_FILE = 'statistics.yml'

    attr_reader :game, :storage

    def initialize(storage_file = STORAGE_FILE)
      @storage = Codebreaker::Storage.new(storage_file)
    end

    def call
      message(:welcome)
      main_menu
    end

    private

    def main_menu
      message(:main_menu)
      answer = user_enter
      return process_answer_menu(answer) if MAIN_MENU_COMMANDS.key?(answer.to_sym)

      message(:'errors.message.unexpected_command')
      main_menu
    end

    def start
      registration
      game_process
    end

    def registration
      enter_name
      describe_difficulty_levels
      select_difficulty_level
      @game = Codebreaker::Game.new(@user, @difficulty)
    end

    def enter_name
      message(:'registration.enter_user_name')
      @user = Codebreaker::User.new(user_enter)
      return @user if @user.valid?

      message(:'errors.message.user')
      enter_name
    end

    def select_difficulty_level
      message(:'registration.select_difficulty')
      @difficulty = Codebreaker::Difficulty.new(user_enter.to_sym)
      return @difficulty if @difficulty.valid?

      message(:'errors.message.difficulty')
      select_difficulty_level
    end

    def won
      message(:'play.win')
      if save_result?
        @yml_store = @storage.new_store
        save_storage unless @storage.storage_exists?
        synchronize_storage
        @winners << game
        save_storage
      end
      main_menu
    end

    def save_result?
      message(:'play.save_results')
      user_enter == I18n.t(:'play.yes_command')
    end

    def save_storage
      @yml_store.transaction { @yml_store[:winners] = @winners || [] }
    end

    def synchronize_storage
      @yml_store.transaction(true) { @winners = @yml_store[:winners] }
    end
  end
end
