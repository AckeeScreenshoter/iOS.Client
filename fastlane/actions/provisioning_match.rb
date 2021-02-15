module Fastlane
  module Actions
    class ProvisioningMatchAction < Action
      def self.run(params)

        if params[:use_wildcard]
          identifier = ENV["ACK_ENTERPRISE_WILDCARD"]
        else
          identifier = params[:app_identifier]
        end

        UI.user_error!("No app identifier given, pass using `app_identifier: 'identifier'`") unless (identifier and not identifier.empty?)


        git_branch = params[:team_id] == params[:default_team_id] ? "master" : params[:team_id]
        readonly =  params[:readonly]

        ENV["MATCH_FORCE_ENTERPRISE"] = params[:type] == "enterprise" ? "1" : "0"

        begin
          other_action.match(
            type: params[:type],
            app_identifier: identifier,
            git_url: params[:git_url],
            username: params[:username],
            team_id: params[:team_id],
            git_branch: git_branch,
            readonly: readonly,
            force_for_new_devices: !readonly
            )
        rescue StandardError => e
          if (e.message.include? "readonly") && readonly == true && !other_action.is_ci
            if e.message.include? "code signing"
              confirm_text = "No code signing identity found, do you wish to create it?"
            elsif e.message.include? "provisioning"
              confirm_text = "No matching #{params[:type]} provisioning profile for #{identifier} found, do you wish to create it?"
            else
              raise
            end

            if UI.confirm(confirm_text)
              readonly = false
              retry
            end
          else
            raise
          end
        end


        #Force the selected provisioning profile in xcode (only for CI)
        if params[:configuration] && (other_action.is_ci || params[:update_xcodeproj])
        #   require 'match/generator'

        #   project_file = "../" + Dir["*.xcodeproj"].first

        #   type_name = Match::Generator.profile_type_name(params[:type].to_sym)
        #   profile = "match #{type_name} #{identifier}"

        #   puts profile

        #   other_action.update_provisioning_name(
        #       xcodeproj: project_file,
        #       profile: profile, # Have to pass Profile name to force use this profile instead whatever is set in xcode
        #       build_configuration: params[:configuration]
        #   )

          # other_action.update_project_provisioning(
          #     xcodeproj: project_file,
          #     profile: profile, # Have to pass Profile path to force use this profile instead whatever is set in xcode
          #     build_configuration: params[:configuration]
          # )
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Provisioning using match"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
         FastlaneCore::ConfigItem.new(key: :configuration,
                                     description: "Configuration to set the provisioning profile to",
                                     optional: true),
         FastlaneCore::ConfigItem.new(key: :use_wildcard,
                                     description: "Set true to use the enterprise wildcard",
                                     default_value: false,
                                     is_string: false,
                                     optional: true),
         FastlaneCore::ConfigItem.new(key: :git_url,
                                     env_name: "MATCH_GIT_URL",
                                     description: "URL to the git repo containing all the certificates",
                                     optional: false,
                                     short_option: "-r"),
        FastlaneCore::ConfigItem.new(key: :type,
                                     env_name: "MATCH_TYPE",
                                     description: "Create a development certificate instead of a distribution one",
                                     is_string: true,
                                     short_option: "-y",
                                     default_value: 'development'
                                     ),
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "MATCH_APP_IDENTIFIER",
                                     is_string: false,
                                     type: Array,
                                     description: "The bundle identifiers used by your app",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
                                     ),
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "MATCH_USERNAME",
                                     description: "Your Apple ID Username",
                                     optional: true
                                     ),
        FastlaneCore::ConfigItem.new(key: :readonly,
                                     env_name: "MATCH_READONLY",
                                     description: "Only fetch existing certificates and profiles, don't generate new ones",
                                     is_string: false,
                                     default_value: true),
        FastlaneCore::ConfigItem.new(key: :update_xcodeproj,
                                     env_name: "MATCH_UPDATEXCODEPROJ",
                                     description: "Update xcodeproj, configuration has to be set",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :default_team_id,
                                     env_name: "MATCH_DEFAULT_TEAM_ID",
                                     description: "The ID of the default team",
                                     optional: false,
                                     verify_block: proc do |value|
                                        UI.user_error!("No default team id given, pass using `default_team_id: 'id'`") unless (value and not value.empty?)
                                     end),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-b",
                                     env_name: "FASTLANE_TEAM_ID",
                                     description: "The ID of your team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_ID"] = value
                                     end)
        ]
      end

      def self.output
        [
        ]
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["tkohout"]
      end

    end
  end
end

