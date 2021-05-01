# frozen_string_literal: true

module Hoboken
  module AddOns
    # Github action that runs CI task.
    #
    class GithubAction < ::Hoboken::Group
      def add_action_yml_file
        empty_directory('.github/workflows')
        template('hoboken/templates/github_action.tt', '.github/workflows/ruby.yml')
      end
    end
  end
end
