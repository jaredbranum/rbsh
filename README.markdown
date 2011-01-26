## Rubbish
### A Ruby Shell

Usage: ruby rubbish.rb

Use the shell as you would any shell (bash, zsh, ksh). Lots of things don't work yet. Ruby does, which is pretty sweet. You can do either:

<pre>
echo hi</pre>
or
<pre>
puts 'hi'</pre>

Preference is given to ruby methods over shell commands and programs, so if you have a binary named <pre>public_methods</pre>, you'll need to pass it to sh or bash to get it to run for now.

New methods can be defined in a .rubbishrc.rb file in your home directory. For example:
_~/.rubbishrc.rb_
<pre>
def amazing
  puts 'so cool!!!!!!'
end</pre>

_shell_
<pre>
$ amazing
so cool!!!!!!</pre>

Improvements coming soon (hopefully). Don't replace your default shell quite yet.

Licensed under the MIT license. See LICENSE for details.
