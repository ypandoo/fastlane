# Based on: https://gist.github.com/rgm/5377144
# Requires ImageMagick: `brew install imagemagick ghostscript`

module Fastlane
  module Actions

    class NoSourceFileError < ArgumentError; end

    class Icon
      attr_accessor :src, :dst
      def src= path
        if File.exist? path
          @src = path
        else
          raise NoSourceFileError, "no icon file at #{path}"
        end
      end
      def color_icon modulation
        #{}`convert "#{@src}" -fuzz 25% -fill '#{to}' -opaque '#{from}' "#{@dst}"`
        `convert "#{@src}" -modulate 100,100,#{modulation} "#{@dst}"`
      end
    end

    class ColorIconAction < Action
      def self.run(params)
        icons = sh("find . -iname 'Icon-*'")
        icons.each_line do |stem|
          begin
            source = stem.strip
            i = Icon.new
            i.src = source
            i.dst = "#{source}-edit"
            i.color_icon "#{params[:modulation]}"
            FileUtils.cp i.dst, i.src
            FileUtils.rm i.dst
          rescue NoSourceFileError => msg
            STDERR.puts "Warning: #{msg}"
          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Changes the color of all Icon* files with a modulation degree"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :modulation,
                                       env_name: "COLOR_MODULATION",
                                       description: "Modulation degrees",
                                       verify_block: proc do |value|
                                          raise "No from color `modulation: '33.3'`".red unless (value and not value.empty?)
                                       end)
        ]
      end

      def self.authors
        ["@r0derik"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end