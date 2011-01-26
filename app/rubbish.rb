require 'readline'
require 'etc'

class Rubbish
  def main
    @running = true
    @pwd = ENV['PWD']
    @previous_dir = @pwd
    while @running
      hostname = `hostname`.chomp.split('.').first
      @pwd = @pwd.gsub(Etc.getpwuid.dir, '~')
      @prompt = "#{ENV['USER']}@#{hostname}:#{@pwd}$ "
      
      arr = Readline.readline(@prompt, true)
      if arr.nil?
        print "\n"
        exit
      else      
        arr = arr.chomp.split(' ')
        begin
          @command = arr.first
          if @command
            @command = @command.to_sym
          else 
            next
          end
        rescue ArgumentError => e
          puts 'ERROR ERROR ERROR'
        end
        if arr[1..-1].empty?
          @arguments = nil
        else
          @arguments = arr[1..-1]
        end
      
        @system_command = false
      
        if @command == :main
          output = method_missing(@command, @arguments)
        else
          output = send(@command, @arguments).inspect
        end
        if @system_command
          puts "No command or method found: #{@command}" unless output
        elsif output && !output.empty?
          puts '=> ' + output
        end
      end
    end
  end
  
  def exit(*args)
    @running = false
  end
  
  def cd(dir)
    begin
      home = Etc.getpwuid.dir
      old_prev_dir = @previous_dir
      if dir.nil?
        @previous_dir = Dir.pwd
        Dir.chdir(home)
      else
        dir = dir.first.gsub('~', home)
        dir = @previous_dir if dir == '-'
        @previous_dir = Dir.pwd
        Dir.chdir(dir)
      end
    rescue Errno::ENOENT => e
      puts "No such directory: #{dir}"
      @previous_dir = old_prev_dir
    end
    @pwd = Dir.pwd
    return nil
  end
  
  def method_missing(sym, *args, &block)
    @system_command = true
    exec = sym.to_s
    if args && !args.empty?
      args.each { |arg| exec += " #{arg.to_s}" }
    end
    system "#{exec}"
  end
  
end