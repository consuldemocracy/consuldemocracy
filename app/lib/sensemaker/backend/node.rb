# frozen_string_literal: true

require "shellwords"

module Sensemaker
  module Backend
    class Node
      attr_reader :job, :artefacts, :runtime_config

      def initialize(job, runtime_config:)
        @job = job
        @artefacts = job.artefacts
        @runtime_config = runtime_config
      end

      def build_command
        return build_report_ui_command if report?

        model_name = runtime_config.model
        additional_context = job.additional_context.presence if requires_input?

        command_parts = ["npx ts-node #{script_path}"]
        command_parts << "--modelName #{Shellwords.escape(model_name)}" if model_name.present?

        append_llm_flags(command_parts)

        command = command_parts.join(" ")
        command += " --inputFile #{artefacts.input_path}" if requires_input?
        if additional_context.present?
          command += " --additionalContext #{Shellwords.escape(additional_context.to_s)}"
        end
        if ScriptRegistry.output_flag(job.script) == :output_basename
          command += " --outputBasename #{output_file}"
        else
          command += " --outputFile #{output_file}"
        end

        command
      end

      def script_path
        if report?
          "#{Sensemaker::Paths.report_ui_folder}/bin/cli.js"
        else
          "#{Sensemaker::Paths.sensemaker_package_folder}/runner-cli/#{job.script}"
        end
      end

      def working_directory
        if report?
          Rails.root
        else
          Sensemaker::Paths.sensemaker_package_folder
        end
      end

      def check_runtime_dependencies?
        unless system("which node > /dev/null 2>&1")
          job.record_error!(
            "Node.js not found. Install Node.js to use the Sensemaker feature.\nPATH: #{ENV["PATH"]}"
          )
          return false
        end

        unless system("which npx > /dev/null 2>&1")
          job.record_error!(
            "NPX not found. Install NPX to use the Sensemaker feature.\nPATH: #{ENV["PATH"]}"
          )
          return false
        end

        return false unless file_exists?(Sensemaker::Paths.sensemaker_package_folder,
                                         description: "sensemaking-tools package folder")
        return false unless file_exists?(Sensemaker::Paths.sensemaker_data_folder,
                                         description: "Sensemaker data folder")

        if report?
          return false unless file_exists?(Sensemaker::Paths.report_ui_folder,
                                           description: "sensemaking-report-ui package folder")

          artefacts.input_artefact_paths.each do |artefact_path|
            return false unless file_exists?(artefact_path, description: "Report input artefact")
          end
        else
          return false unless file_exists?(artefacts.input_path, description: "Input file")
        end

        return false unless file_exists?(script_path, description: "Script file")

        true
      end

      def after_input_prepared
        if logical_name == :advanced
          return Sensemaker::CsvExporter.provide_defaults_for_zero_vote_comments(artefacts.input_path)
        end

        write_report_metadata if report?
        nil
      end

      def redact_command(command)
        command.to_s.gsub(/--apiKey\s+\S+/, "--apiKey [REDACTED]")
      end

      def output_file_name
        artefacts.output_file_name
      end

      private

        def logical_name
          ScriptRegistry.logical_name(job.script)
        end

        def report?
          logical_name == :report
        end

        def requires_input?
          ScriptRegistry.requires_input?(job.script)
        end

        def output_file
          artefacts.default_output_path
        end

        def build_report_ui_command
          conversation = job.conversation
          target_label = conversation.target_label(format: :full)
          base = artefacts.input_path

          [
            "npx sensemaking-report-ui inline",
            "--topics #{Shellwords.escape("#{base}-topic-stats.json")}",
            "--summary #{Shellwords.escape("#{base}-summary.json")}",
            "--comments #{Shellwords.escape("#{base}-comments-with-scores.json")}",
            "--metadata #{Shellwords.escape(artefacts.metadata_path)}",
            "--reportTitle #{Shellwords.escape("Report for #{target_label}")}",
            "--outputDir #{Shellwords.escape(artefacts.job_directory.to_s)}",
            "--outputFile #{Shellwords.escape(output_file_name)}"
          ].join(" ")
        end

        def append_llm_flags(command_parts)
          case runtime_config.adapter
          when "vertex"
            command_parts << "--adapter vertex"
            command_parts << "--vertexProject #{Shellwords.escape(runtime_config.vertex_project_id)}"
            command_parts << "--vertexLocation #{Shellwords.escape(runtime_config.vertex_location)}"
          when "openai-compatible"
            command_parts << "--adapter openai-compatible"
            command_parts << "--provider #{Shellwords.escape(runtime_config.compat_provider)}"
            api_key = runtime_config.api_key
            command_parts << "--apiKey #{Shellwords.escape(api_key)}" if api_key.present?
          when "ollama"
            command_parts << "--adapter ollama"
          end

          base_url = runtime_config.base_url
          command_parts << "--baseUrl #{Shellwords.escape(base_url)}" if base_url.present?
        end

        def write_report_metadata
          artefacts.ensure_directory!
          metadata_path = artefacts.metadata_path
          return if File.exist?(metadata_path)

          title = job.conversation.target_label(format: :full)
          File.write(metadata_path, { title: title }.to_json)
        end

        def file_exists?(file_path, description: "File or directory")
          return true if File.exist?(file_path)

          job.record_error!("#{description} not found: #{file_path}")
          false
        end
    end
  end
end
