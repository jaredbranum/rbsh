module RbshHelper
  def self.rbshrc_syntax_error
    unless @dotfile_error
      puts "There was a problem with the syntax in your .rbshrc file. Please ensure the file contains valid Ruby."
      @dotfile_error = true
    end
  end
  
  def self.parse_ps1(ps1)
    ps1.gsub(/%./) do |chr|
      case chr
      when '%%' then '%'
      when '%u' then ENV['USER']
      when '%w' then (!ENV['PWD'].nil?) ? ENV['PWD'].gsub(ENV['HOME'],'~') : ''
      when '%h' then `hostname`.chomp.split('.').first
      when '%$' then ENV['USER'] == 'root' ? '#' : '$'
      when '%[' then 1.chr
      when '%]' then 2.chr
      end
    end
  end
  
  def self.ruby_indentation_level(str)
    #return 1 unless remove_strings!(str) == 0
    level = 0
    level += (str.count('{') - str.count('}') >= 0) ? str.count('{') - str.count('}') : 0
    level += (str.count('(') - str.count(')') >= 0) ? str.count('(') - str.count(')') : 0
    level += (str.count('[') - str.count(']') >= 0) ? str.count('[') - str.count(']') : 0
    
    str.split("\n").each do |line|
      if has_keyword?(line)
        level += 1 unless line =~ /\send(\s|$).*/
      end
    end
    level
  end
  
  private

  # this string parsing is going to get pretty complicated.
  # do it later
  #
  # def remove_strings(str)
  #   str = remove_empty_strings(str)
  #   while true
  #     first_char = "'"
  #     first_pos = str.index("'")
  #     if first_pos && (str.index('"') < first_pos)
  #       first_char = '"'
  #       first_pos = str.index('"')
  #     end
  #     if first_pos && (str.index('/') < first_pos)
  #       first_char = '/'
  #       first_pos = str.index('/')
  #     end
  #     return 0 if first_pos.nil?
  #     return 1 if str.count(first_char) == 1
  #     first_char = Regexp.quote(first_char)
  #     str = str.gsub(/#{first_char}[^\\]+#{first_char}/)
  #   end
  # end
  # 
  # def remove_empty_strings(str)
  #   str = str.gsub(/""/,'')
  #   str = str.gsub(/''/,'')
  #   str = str.gsub(/\/\//,'')
  #   str.gsub(/\\\\/,'')
  # end
  
  def self.has_keyword?(str)
    !!(str =~ /(.*(\s|^)do\s+|^\s*(module|class|def|if|unless|case|while|until|for|begin))/)
  end
  
  def num_chars(str,chr)
    #str.each
  end
end