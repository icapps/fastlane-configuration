require 'aws-sdk'

module Fastlane
  module Actions
    class AwsDeviceFarmAction < Action
      def self.run(params)
        Actions.verify_gem!('aws-sdk')
        Helper.log.info 'Preparing the upload to the device farm.'

        # Instantiate the client.
        @client = ::Aws::DeviceFarm::Client.new()

        # Fetch the project
        project = fetch_project params[:name]
        raise "Project '#{params[:name]}' not found." if project.nil?

        # Fetch the device pool.
        device_pool = fetch_device_pool project, params[:device_pool]
        raise "Device pool '#{params[:device_pool]}' not found. 🙈" if device_pool.nil?

        # Create the upload.
        path   = File.join Dir.pwd, params[:binary_path]
        type   = File.extname(path) == '.apk' ? 'ANDROID_APP' : 'IOS_APP'
        upload = create_project_upload project, path, type

        # Upload the application binary.
        Helper.log.info 'Uploading the application binary. ☕️'
        upload upload, path

        # Upload the test package if needed.
        test_upload = nil
        if params[:test_binary_path]
          test_path = File.join Dir.pwd, params[:test_binary_path]
          test_upload = create_project_upload project, test_path, 'INSTRUMENTATION_TEST_PACKAGE'

          # Upload the test binary.
          Helper.log.info 'Uploading the test binary. ☕️'
          upload test_upload, test_path

          # Wait for test upload to finish.
          Helper.log.info 'Waiting for the test upload to succeed. ☕️'
          test_upload = wait_for_upload test_upload
          raise 'Test upload failed. 🙈' unless test_upload.status == 'SUCCEEDED'
        end

        # Wait for upload to finish.
        Helper.log.info 'Waiting for the application upload to succeed. ☕️'
        upload = wait_for_upload upload
        raise 'Binary upload failed. 🙈' unless upload.status == 'SUCCEEDED'

        # Schedule the run.
        run = schedule_run project, device_pool, upload, test_upload

        # Wait for run to finish.
        if params[:wait_for_completion]
          Helper.log.info 'Waiting for the run to complete. ☕️'
          run = wait_for_run run
          raise "#{run.message} 🙈" unless %w(PASSED WARNED).include? run.result

          Helper.log.info 'Successfully tested the application on the AWS device farm. ✅'.green
        else
          Helper.log.info 'Successfully scheduled the tests on the AWS device farm. ✅'.green
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Upload the application to the AWS device farm.'
      end

      def self.details
        'Upload the application to the AWS device farm.'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key:         :name,
            env_name:    'FL_AWS_DEVICE_FARM_NAME',
            description: 'Define the name of the device farm project',
            is_string:   true,
            optional:    false
          ),
          FastlaneCore::ConfigItem.new(
            key:         :binary_path,
            env_name:    'FL_AWS_DEVICE_FARM_PATH',
            description: 'Define the path of the application binary (apk or ipa) to upload to the device farm project',
            is_string:   true,
            optional:    false,
            verify_block: proc do |value|
              path = File.join Dir.pwd, value
              raise "Application binary not found at path '#{path}'. 🙈".red unless File.exist?(path)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key:         :test_binary_path,
            env_name:    'FL_AWS_DEVICE_FARM_TEST_PATH',
            description: 'Define the path of the test binary (apk) to upload to the device farm project',
            is_string:   true,
            optional:    true,
            verify_block: proc do |value|
              path = File.join Dir.pwd, value
              raise "Test binary not found at path '#{path}'. 🙈".red unless File.exist?(path)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key:         :path,
            env_name:    'FL_AWS_DEVICE_FARM_PATH',
            description: 'Define the path of the application binary (apk or ipa) to upload to the device farm project',
            is_string:   true,
            optional:    false
          ),
          FastlaneCore::ConfigItem.new(
            key:         :device_pool,
            env_name:    'FL_AWS_DEVICE_FARM_POOL',
            description: 'Define the device pool you want to use for running the applications',
            is_string:   true,
            optional:    false
          ),
          FastlaneCore::ConfigItem.new(
            key:           :wait_for_completion,
            env_name:      'FL_AWS_DEVICE_FARM_WAIT_FOR_COMPLETION',
            description:   'Wait for the scheduled run to complete',
            is_string:     false,
            optional:      true,
            default_value: true
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
        platform == :ios || platform == :android
      end

      private

      POLLING_INTERVAL = 10

      def self.fetch_project(name)
        projects = @client.list_projects.projects
        projects.detect { |p| p.name == name }
      end

      def self.create_project_upload(project, path, type)
        @client.create_upload({
          project_arn:  project.arn,
          name:         File.basename(path),
          content_type: 'application/octet-stream',
          type:         type
        }).upload
      end

      def self.upload(upload, path)
        url = URI.parse(upload.url)
        contents = File.open(path, 'rb').read
        Net::HTTP.start(url.host) do |http|
          http.send_request("PUT", url.request_uri, contents, { 'content-type' => 'application/octet-stream' })
        end
      end

      def self.fetch_upload_status(upload)
        @client.get_upload({
          arn:  upload.arn
        }).upload
      end

      def self.wait_for_upload(upload)
        upload = fetch_upload_status upload
        while upload.status == 'PROCESSING'
          sleep POLLING_INTERVAL
          upload = fetch_upload_status upload
        end

        upload
      end

      def self.fetch_device_pool(project, device_pool)
        device_pools = @client.list_device_pools({
          arn: project.arn
        })
        device_pools.device_pools.detect { |p| p.name == device_pool }
      end

      def self.schedule_run(project, device_pool, upload, test_upload)
        # Prepare the test hash depening if you passed the test apk.
        test_hash = { type: 'BUILTIN_FUZZ' }
        if test_upload
          test_hash[:type]             = 'INSTRUMENTATION'
          test_hash[:test_package_arn] = test_upload.arn
        end

        @client.schedule_run({
          project_arn:     project.arn,
          app_arn:         upload.arn,
          device_pool_arn: device_pool.arn,
          test:            test_hash
        }).run
      end

      def self.fetch_run_status(run)
        @client.get_run({
          arn:  run.arn
        }).run
      end

      def self.wait_for_run(run)
        while run.status != 'COMPLETED'
          sleep POLLING_INTERVAL
          run = fetch_run_status run
        end
        Helper.log.info "The run ended with result #{run.result}."

        run
      end
    end
  end
end
