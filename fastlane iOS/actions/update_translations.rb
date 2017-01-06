module Fastlane
  module Actions
    class UpdateTranslationsAction < Action
      def self.run(params)
        Actions.verify_gem!('icapps-translations')

        project_root = params[:project_root]
        # Check if the project root exists.
        raise "Couldn't find a directory at path '#{project_root}'".red unless Dir.exist?(project_root)

        # Navigate to the correct folder.
        command_prefix = [
          'cd',
          File.expand_path(project_root).shellescape,
          '&&'
        ].join(' ')

        # Run the translations import command.
        command = [
          command_prefix,
          'translations',
          'import'
        ].join(' ')
        Actions.sh command

        # Lookup the changed .strings files.
        changed_files = Actions.sh('git diff --name-only HEAD').split("\n").select { |f| f[%r{\.strings$}] }
        if changed_files.count == 0
          Helper.log.info "Didn't commit any changes, no translations were updated.".yellow
        else
          begin
            Actions.sh("git add #{changed_files.map(&:shellescape).join(' ')}")
            Actions.sh("git commit -m '#{params[:commit_message]}'")

            Helper.log.info "Committed \"#{params[:commit_message]}\" 💾.".green
          rescue => ex
            Helper.log.error ex
            Helper.log.info "Didn't commit any changes.".yellow
          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Fetch the translations with the iCapps translations tool.'
      end

      def self.details
        'Fetch the translations with the iCapps translations tool.'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :project_root,
            env_name: 'FL_TRANSLATIONS_PROJECT_ROOT',
            description: 'Define the root of the project directory. If not set we use the repository root as the project root directory',
            is_string: true,
            optional: true,
            default_value: Dir.pwd
          ),
          FastlaneCore::ConfigItem.new(
            key: :commit_message,
            env_name: 'FL_TRANSLATIONS_COMMIT_MESSAGE',
            description: 'Define a commit message that you want to use when updating the translations files',
            is_string: true,
            optional: true,
            default_value: 'Update translations'
          )
        ]
      end

      def self.output
        []
      end

      def self.return_value
      end

      def self.authors
        ["fousa/fousa"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end

