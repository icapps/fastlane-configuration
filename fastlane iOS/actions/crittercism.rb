require 'json'

module Fastlane
  module Actions
    class CrittercismAction < Action
      def self.run(params)
        parse_resource_id(retrieve_resource_id(params))
        zip_file(params)
        upload_file(params)
        verify_upload(params)
      end

      def self.retrieve_resource_id(params)
        command = []
        command << "curl"
        command << verbose(params)
        command += upload_options_one(params)
        command << upload_url(params, false)

        shell_command = command.join(' ')
        result = Helper.is_test? ? shell_command : `#{shell_command}`
        UI.message result
        result
      end

      def self.zip_file(params)
        file_path = dsym_path(params).shellescape
        command = []
        command << "zip"
        command << "-r"
        command << "#{file_path}.zip #{file_path}"

        shell_command = command.join(' ')
        Helper.is_test? ? shell_command : `#{shell_command}`
      end

      def self.upload_file(params)
        command = []
        command << "curl"
        command << verbose(params)
        command += upload_options_two(params)
        command << upload_url(params, true)

        shell_command = command.join(' ')
        result = Helper.is_test? ? shell_command : `#{shell_command}`
        fail_on_error(result)
        UI.success 'Verify Upload.'
      end

      def self.verify_upload(params)
        command = []
        command << "curl"
        command << verbose(params)
        command += upload_options_three(params)
        command << proces_url(params)

        shell_command = command.join(' ')
        result = Helper.is_test? ? shell_command : `#{shell_command}`
        fail_on_error(result)
        UI.success 'Upload to Crittercism complete.'
      end

      def self.fail_on_error(result)
        if result.include?("20") == false
          UI.user_error!(result)
          UI.user_error!("Server error, failed to upload the dSYM file")
        end

      end

      def self.parse_resource_id(result)
        if result.include?("Invalid token specified")
          UI.user_error!("Server error, failed to upload the dSYM file")
        else
          dict = JSON.parse(result)
          resource_id = dict["resource-id"]
          UI.success 'Retrieved resource ID: ' + resource_id
          UI.success 'Uploading dSMY file...'
          @resource_id = resource_id
        end
      end

      def self.upload_url(params, resource_id)
        if resource_id
          "https://files.crittercism.com/api/v1/applications/#{params[:app_id].shellescape}/symbol-uploads/#{@resource_id}"
        else
          "https://files.crittercism.com/api/v1/applications/#{params[:app_id].shellescape}/symbol-uploads"
        end

      end

      def self.proces_url(params)
        "https://app.crittercism.com/v1.0/app/#{params[:app_id].shellescape}/symbols/uploads"
      end

      def self.verbose(params)
        params[:verbose] ? "--verbose" : ""
      end

      def self.dsym_path(params)
        file_path = params[:dsym]
        file_path ||= Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] || ENV[SharedValues::DSYM_OUTPUT_PATH.to_s]
        file_path ||= Actions.lane_context[SharedValues::DSYM_ZIP_PATH] || ENV[SharedValues::DSYM_ZIP_PATH.to_s]

        if file_path
          expanded_file_path = File.expand_path(file_path)
          UI.user_error!("Couldn't find file at path '#{expanded_file_path}'") unless File.exist?(expanded_file_path)

          return expanded_file_path
        else
          UI.user_error!("Couldn't find any dSYM file")
        end
      end

      def self.upload_options_one(params)
        options = []
        options << "-X POST --silent"
        options << authorization_header(params)

        options
      end

      def self.upload_options_two(params)
        file_path = dsym_path(params).shellescape

        options = []
        options << "-X PUT"
        options << "--write-out %{http_code} --silent --output /dev/null -F name=symbolUpload"
        options << "-F filedata=@#{file_path}.zip"
        options << authorization_header(params)

        options
      end

      def self.upload_options_three(params)
        file_path = dsym_path(params).shellescape

        options = []
        filename = File.basename file_path
        filename += ".zip"
        options << "-X POST"
        data = {:uploadUuid => @resource_id, :filename => filename}
        options << "--data '#{data.to_json}'"
        options << "-H 'Content-Type: application/json'"
        options << authorization_header(params)

        options
      end

      def self.authorization_header(params)
        "-H 'Authorization: Bearer #{params[:oauth_token].shellescape}'"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload dSYM file to Crittercism"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dsym,
                                       env_name: "FL_CRITTERCISM_FILE",
                                       description: "dSYM.zip file to upload to Crittercism",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :oauth_token,
                                       env_name: "FL_CRITTERCISM_OAUTH_TOKEN",
                                       description: "Crittercism App API key e.g. f57a57ca",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :app_id,
                                       env_name: "FL_CRITTERCISM_APP_ID",
                                       description: "Crittercism App ID e.g. e05ba40754c4869fb7e0b61",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_CRITTERCISM_VERBOSE",
                                       description: "Make detailed output",
                                       is_string: false,
                                       default_value: false,
                                       optional: true)
        ]
      end

      def self.authors
        ["dgyesbreghs"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
