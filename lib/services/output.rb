# frozen_string_literal: true

module CodebreakerConsole
  module Output
    def message(type)
      puts I18n.t(type)
    end

    def rules
      message(:rules)
    end

    def stats
      if File.exist?(storage.storage_file)
        winners = YAML.load_file(storage.storage_file)[:winners]
        sorted_winners = Codebreaker::Statistics.sorted_winners(winners)
        tp Codebreaker::Statistics.decorated_top_users(sorted_winners)
      else
        message(:'statistics.no_data')
      end
    end

    def lost
      message(:'play.lost')
      puts game.secret_code
      main_menu
    end
  end
end
