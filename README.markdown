# rbsh
## A Ruby Shell

Usage: ./rbsh 

Use the shell as you would any shell (bash, zsh, ksh). Lots of things don't work yet. Ruby does, which is pretty sweet. You can do either:

<pre>
echo hi</pre>
or
<pre>
puts 'hi'</pre>

Preference is given to ruby methods over shell commands and programs, so if you have a binary named `public_methods`, you'll need to pass it to sh or bash or whatever to get it to run for now.

### History
Your shell history is saved in ~/.rbsh_history as plain text. Each time the shell is launched, the history buffer is prepopulated by the contents of this file, if it exists. This allows you to use the up arrow to scroll through previous commands, even upon exiting and restarting the shell.

### Multi-line input
Input is limited to a single line by default. In order to write Ruby across multiple lines, you must enter multi-line mode. To enter multi-line mode, simply input `#` at the terminal prompt. To end multi-line mode and evaluate the Ruby code entered thus far, enter another `#` on a line by itself.  
Example:
<pre>
$ #
> class Klass
>   def self.sweet
>     puts 'super sweet'
>   end
> end
> #
$ Klass.sweet
super sweet
$ </pre>
Multi-line input is not (yet) supported for non-Ruby commands.

### Passing values to methods
Parenthesized arguments are always taken as you passed them. Non-parenthesized arguments (to methods defined within the shell context) will be interpreted as a single string and passed as the first argument. This may seem unusual at a glance, but for built-in methods like `cd`, it ends up being quite natural. This allows you to type `cd /etc` instead of `cd('/etc')`. You can always parenthesize arguments if you need to pass other types of objects.

### Built-in methods
Currently rbsh has 4 built-in methods:

* `cd`
* `quit`
* `reload!`
* `rvm`

`cd` takes one argument. It will change your working directory to the specified directory. All instances of the ~ character will be taken to mean your home directory. Passing a dash (hyphen) as the only argument will return you to your last working directory. No argument (or a nil argument) will take you to your home directory.

`quit` just calls `exit(0)`. `reload!` will set all your shell instance variables to matching environment variables (which is already done when starting the shell) and reload your .rbshrc file (discussed below). Information on `rvm` can be found under the header _RVM Support_.

### Custom .rbshrc file
New methods, aliases, and shell variables can be defined in a .rbshrc file (with an optional .rb extension) in your home directory. This file can contain any valid Ruby code, which will be evaluated within the context of your shell. Instance variables set here will translate to shell environment variables. The `Shell.alias` method is provided as a convenience, and takes 2 arguments (a symbol and a string).  
Example:
<pre>
# contents of ~/.rbshrc
@PS1 = '[$] '
Shell.alias(:gst, "git status")

def amazing(n)
  10*n
end</pre>
<pre>
[$] amazing(5)
=> 50
[$] gst
# On branch master
nothing to commit (working directory clean)
[$] </pre>
_If you have both .rbshrc and rbshrc.rb in your home directory, both will be loaded. In the case of the same names for methods and variables, the contents of .rbshrc.rb will override those of .rbshrc._

### RVM support
The built-in `rvm` method behaves a lot differently than other built-in methods. Since rbsh is written in ruby, switching ruby versions while the shell is running is kinda problematic. Additionally, rvm is written almost entirely in (bash-like) shell scripts, requiring the use of another shell (unless I intend to rewrite rvm) (I don't). To circumvent these issues, the rbsh ruby environment runs inside its own instance of bash. When an rvm command is encountered, rbsh writes it to a temporary file in your home directory, exits from the ruby context, executes the rvm command within its bash environment, deletes the temporary file, then creates a new ruby shell. While this does allow you to change ruby versions on the fly, any variables or methods that you had previously defined during that session will disappear.


Improvements coming soon. Updates will appear here before anywhere else.

Licensed under the MIT license. See LICENSE for details.
