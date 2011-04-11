require File.expand_path(File.dirname(__FILE__) + '/context.rb')
require 'readline'

class Rbsh
  module Builtins
  
    # define sudo!! method
    def self.included(par)
      par.send :define_method, :"sudo!!" do
        system "sudo #{Readline::HISTORY[-2].to_s}"
        nil
      end
    end
  
    def bash!(arg=nil)
      return unless arg
      File.open(ENV['HOME'] + '/.rbsh_bash_command', 'w') do |file|
        file.write("rbsh_cmd='cd #{Dir.pwd}'\ncd #{Dir.pwd}\n#{arg}")
      end
      exit(2)
    end
  
    def rvm(arg='')
      bash! "rvm #{arg}"
    end
  
    def source(file=nil)
      return false unless file
      begin
        eval(File.read(File.expand_path(file).strip), Rbsh::Context.binding)
      rescue Exception => e
        return false
      end
      true
    end
  
    def quit(*args)
      exit(0)
    end
  
    def cd(dir=nil)
      begin
        old_prev_dir = ENV['OLD_PWD']
        if dir.nil? || dir.empty?
          @OLD_PWD = Dir.pwd
          ENV['OLD_PWD'] = Dir.pwd
          Dir.chdir(ENV['HOME'])
        else
          dir = dir.gsub('~', ENV['HOME'])
          dir = ENV['OLD_PWD'] if dir == '-'
          @OLD_PWD = Dir.pwd
          ENV['OLD_PWD'] = Dir.pwd
          Dir.chdir(dir)
        end
      rescue Errno::ENOENT => e
        puts "No such directory: #{dir}"
        @OLD_PWD = old_prev_dir
        ENV['OLD_PWD'] = old_prev_dir
      end
      @PWD = Dir.pwd
      ENV['PWD'] = Dir.pwd
      nil
    end
  
  end
end