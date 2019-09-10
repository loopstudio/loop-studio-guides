# The Ruby Style Guide

### Table of Contents
* [Source Code Layout](#source-code-layout)


## Source Code Layout

#### [Source Encoding](#utf-8)
Use `UTF-8` as the source file encoding.

#### [Tabs or Spaces?](#tabs-or-spaces)
Use only spaces for indentation. No hard tabs.

#### [Indentation](#spaces-indentation)
Use two **spaces** per indentation level (aka soft tabs). No hard tabs.

```Ruby
# bad - four spaces
def some_method
    do_something
end

# good
def some_method
  do_something
end
```

#### [Maximum Line Length](#100-character-limits)
Limit lines to 100 characters.

#### [No Trailing Whitespace](#no-trailing-whitespace)
Avoid trailing whitespace.

#### [Line Endings](#crlf)
Use Unix-style line endings. (BSD/Solaris/Linux/macOS users are covered by default, Windows users have to be extra careful).

#### [Should I Terminate Files with a Newline?](#newline-eof)
End each file with a newline.

#### [Should I Terminate Expressions with ;?](#no-semicolon)
Don’t use ; to terminate statements and expressions.

```Ruby
# bad
puts 'foobar'; # superfluous semicolon

# good
puts 'foobar'
```

#### [One Expression Per Line](#one-expression-per-line)
Use one expression per line.

```Ruby
# bad
puts 'foo'; puts 'bar' # two expressions on the same line

# good
puts 'foo'
puts 'bar'

puts 'foo', 'bar' # this applies to puts in particular
```

#### [Spaces and Operators](#spaces-operators)
Use spaces around operators, after commas, colons and semicolons. Whitespace might be (mostly) irrelevant to the Ruby interpreter, but its proper use is the key to writing easily readable code.

```Ruby
sum = 1 + 2
a, b = 1, 2
class FooError < StandardError; end
```

There are a few exceptions. One is the exponent operator:

```Ruby
# bad
e = M * c ** 2

# good
e = M * c**2
```

Another exception is the slash in rational literals:

```Ruby
# bad
o_scale = 1 / 48r

# good
o_scale = 1/48r
```

Another exception is the safe navigation operator:

```Ruby
# bad
foo &. bar
foo &.bar
foo&. bar

# good
foo&.bar
```
