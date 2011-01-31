## rbsh
### A Ruby Shell

Usage: ./rbsh 

Use the shell as you would any shell (bash, zsh, ksh). Lots of things don't work yet. Ruby does, which is pretty sweet. You can do either:

<pre>
echo hi</pre>
or
<pre>
puts 'hi'</pre>

Preference is given to ruby methods over shell commands and programs, so if you have a binary named _public_methods_, you'll need to pass it to sh or bash or whatever to get it to run for now.

Input is limited to a single line by default. In order to write Ruby across multiple lines, you must enter multi-line mode. To enter multi-line mode, input either 'multi_line' or '#' at the terminal prompt. To end multi-line mode and evaluate the Ruby code entered thus far, enter '#' on a line by itself.  
Example:
<pre>
$ #
> class Klass
>   def self.sweet
>     puts 'super sweet'
>     nil
>   end
> end
> #
$ Klass.sweet
super sweet</pre>
Multi-line input is not (yet) supported for non-Ruby commands.

New methods can be defined in a .rbshrc file (with an optional.rb extension) in your home directory.  
Example:
<pre>
# contents of ~/.rbshrc
def amazing
  puts 'so cool!!!!!!'
  return nil
end</pre>
<pre>
$ amazing
so cool!!!!!!</pre>
_If you have both .rbshrc and rbshrc.rb in your home directory, both will be loaded. In the case of the same names for methods and variables, the contents of .rbshrc.rb will override those of .rbshrc._

Improvements coming soon. Updates will appear here before anywhere else.

Licensed under the MIT license. See LICENSE for details.
