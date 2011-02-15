require './lib/rbsh_variables'

module RbshBuiltins
  
  def rvm(arg='')
    File.open(@HOME + '/.rbsh_bash_command', 'w') do |file|
      file.write("rvm #{arg}")
    end
    exit(2)
  end
  
  def quit(*args)
    exit(0)
  end
  
  def cd(dir=nil)
    begin
      old_prev_dir = @OLD_PWD
      if dir.nil? || dir.empty?
        @OLD_PWD = Dir.pwd
        ENV['OLD_PWD'] = Dir.pwd
        Dir.chdir(@HOME)
      else
        dir = dir.gsub('~', @HOME)
        dir = @OLD_PWD if dir == '-'
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
    return nil
  end
  
end
