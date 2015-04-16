module Fastlane
  module Actions
    # --object-directory=OBJDIR      Specify the directory that contains the gcov data files.
    # -o OUTPUT, --output=OUTPUT     Print output to this filename Keep the temporary *.gcov files generated by gcov.
    # -k, --keep                     Keep the temporary *.gcov files generated by gcov.
    # -d, --delete                   Delete the coverage files after they are processed.
    # -f FILTER, --filter=FILTER     Keep only the data files that match this regular expression
    # -e EXCLUDE, --exclude=EXCLUDE  Exclude data files that match this regular expression
    # --gcov-filter=GCOV_FILTER      Keep only gcov data files that match this regular expression
    # --gcov-exclude=GCOV_EXCLUDE    Exclude gcov data files that match this regular expression
    # -r ROOT, --root=ROOT           Defines the root directory for source files.
    # -x, --xml                      Generate XML instead of the normal tabular output.
    # --xml-pretty                   Generate pretty XML instead of the normal dense format.
    # --html                         Generate HTML instead of the normal tabular output.
    # --html-details                 Generate HTML output for source file coverage.
    # --html-absolute-paths          Set the paths in the HTML report to be absolute instead of relative
    # -b, --branches                 Tabulate the branch coverage instead of the line coverage.
    # -u, --sort-uncovered           Sort entries by increasing number of uncovered lines.
    # -p, --sort-percentage          Sort entries by decreasing percentage of covered lines.
    # --gcov-executable=GCOV_CMD     Defines the name/path to the gcov executable [defaults to the GCOV environment variable, if present; else 'gcov'].
    # --exclude-unreachable-branches Exclude from coverage branches which are marked to be excluded by LCOV/GCOV markers or are determined to be from lines containing only compiler-generated "dead" code.
    # -g, --use-gcov-files           Use preprocessed gcov files for analysis.
    # -s, --print-summary            Prints a small report to stdout with line & branch percentage coverage

    class GcovrAction < Action
      ARGS_MAP = {
        object_directory: "--object-directory",
        output: "-o",
        keep: "-k",
        delete: "-d",
        filter: "-f",
        exclude: "-e",
        gcov_filter: "--gcov-filter",
        gcov_exclude: "--gcov-exclude",
        root: "-r",
        xml: "-x",
        xml_pretty: "--xml-pretty",
        html: "--html",
        html_details: "--html-details",
        html_absolute_paths: "--html-absolute-paths",
        branches: "-b",
        sort_uncovered: "-u",
        sort_percentage: "-p",
        gcov_executable: "--gcov-executable",
        exclude_unreachable_branches: "--exclude-unreachable-branches",
        use_gcov_files: "-g",
        print_summary: "-s"
      }

      def self.is_supported?(type)
        type == :ios
      end

      def self.run(params)
        unless Helper.test?
          raise "gcovr not installed".red if `which gcovr`.length == 0
        end

        # The args we will build with
        gcovr_args = nil

        # Allows for a whole variety of configurations
        if params.first.is_a? Hash
          params_hash = params.first

          # Check if an output path was given
          if params_hash.has_key? :output
            create_output_dir_if_not_exists(params_hash[:output])
          end

          # Maps parameter hash to CLI args
          gcovr_args = params_hash_to_cli_args(params_hash)
        else
          gcovr_args = params
        end

        # Joins args into space delimited string
        gcovr_args = gcovr_args.join(" ")

        command = "gcovr #{gcovr_args}"
        Helper.log.info "Generating code coverage.".green
        Helper.log.debug command
        Actions.sh command
      end

      def self.create_output_dir_if_not_exists(output_path)
        output_dir = File.dirname(output_path)

        # If the output directory doesn't exist, create it
        unless Dir.exists? output_dir
          FileUtils.mkpath output_dir
        end
      end

      def self.params_hash_to_cli_args(params)
        # Remove nil value params
        params = params.delete_if { |_, v| v.nil? }

        # Maps nice developer param names to CLI arguments
        params.map do |k, v|
          v ||= ""
          if args = ARGS_MAP[k]
            value = (v != true && v.to_s.length > 0 ? "\"#{v}\"" : "")
            "#{args} #{value}".strip
          end
        end.compact
      end

      def self.description
        "Runs test coverage reports for your Xcode project"
      end

      def self.available_options
        [
          ['object_directory', 'Specify the directory that contains the gcov data files.'],
          ['output', 'Print output to this filename Keep the temporary *.gcov files generated by gcov.'],
          ['keep', 'Keep the temporary *.gcov files generated by gcov.'],
          ['delete', 'Delete the coverage files after they are processed.'],
          ['filter', 'Keep only the data files that match this regular expression'],
          ['exclude', 'Exclude data files that match this regular expression'],
          ['gcov_filter', 'Keep only gcov data files that match this regular expression'],
          ['gcov_exclude', 'Exclude gcov data files that match this regular expression'],
          ['root', 'Defines the root directory for source files.'],
          ['xml', 'Generate XML instead of the normal tabular output.'],
          ['xml_pretty', 'Generate pretty XML instead of the normal dense format.'],
          ['html', 'Generate HTML instead of the normal tabular output.'],
          ['html_details', 'Generate HTML output for source file coverage.'],
          ['html_absolute_paths', 'Set the paths in the HTML report to be absolute instead of relative'],
          ['branches', 'Tabulate the branch coverage instead of the line coverage.'],
          ['sort_uncovered', 'Sort entries by increasing number of uncovered lines.'],
          ['sort_percentage', 'Sort entries by decreasing percentage of covered lines.'],
          ['gcov_executable', 'Defines the name/path to the gcov executable].'],
          ['exclude_unreachable_branches', 'Exclude from coverage branches which are marked to be excluded by LCOV/GCOV markers'],
          ['use_gcov_files', 'Use preprocessed gcov files for analysis.'],
          ['print_summary', 'Prints a small report to stdout with line & branch percentage coverage']
        ]
      end

      def self.author
        "dtrenz"
      end
    end
  end
end
