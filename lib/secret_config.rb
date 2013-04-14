require "secret_config/version"
require 'yaml'
require 'erb'
require 'fileutils'
require 'rubygems'
require 'zipruby'

class SecretConfig
  class << self
    def source(value = nil)
      @source ||= value
    end

    def load!(password = nil)
      if File.exist? compressed_source
        decompress!(password)
      elsif !File.exist? decompressed_source
        raise Errno::ENOENT, 'No file specified as SecretConfig source'
      end
      return YAML::load(ERB.new(File.read(decompressed_source)).result)
    end

    def compress!(password = nil)
      if File.exist? decompressed_source
        password ||= get_password("Compress source")
        dir, source = File.split(decompressed_source)
        compressed = compressed_source
        Dir.chdir dir do
          Zip::Archive.open(compressed, Zip::CREATE) do |arc|
            arc.add_file source
          end
          Zip::Archive.encrypt(compressed, passowrd)
          FileUtils.rm(source)
        end
      else
        raise Errno::ENOENT, 'No file specified as SecretConfig decompressed source'
      end
    end

    def decompress!(password = nil)
      if File.exist? compressed_source
        password ||= get_password("Decompress source")
        dir, source = File.split(compressed_source)
        Dir.chdir dir do
          Zip::Archive.decrypt(source, password)
          Zip::Archive.open(source) do |archives|
            archives.each do |a|
              File.open(a.name, 'w') { |f| f.write a.read }
            end
          end
          FileUtils.rm(source)
        end
      else
        raise Errno::ENOENT, 'No file specified as SecretConfig compressed source'
      end
    end

    private

    def decompressed_source
      @source + '.yml'
    end

    def compressed_source
      @source + '.zip'
    end

    def get_password(message)
      passwd = HighLine.new.ask("#{message}, please enter password:") do |q|
        q.echo= false
      end
      return passwd
    end
  end
end
