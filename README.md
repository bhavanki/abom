# abom

A TUI (text UI) framework for bash.

## To start with

This is an **abomination**, hence the project name. The nearly universal advice for anyone considering using this library is: Use a different, real language like Python or Go or Rust or Ruby or Javascript or Java or C# or C++ or Haskell or Scala or Scheme or Ada or PHP or Perl or ... because a script with a TUI has grown too complex to be suitable for bash. The resulting script will be nearly impossible to maintain, rife with hidden bugs, brittle, inextensible, non-portable, and slow. Frankly, even contemplating the idea casts doubt on your integrity and professionalism as a so-called software developer, and there is a special place reserved in hell for yours truly who has authored this monstrosity. There is something wrong with you if you even start to think that this framework could be used for anything at all.

I wrote the paragraph above to satisfy those who take offense at this library. You're right, I'm wrong.

OK, now that all of that is out of the way, let's talk about the code here.

## About

abom is a framework to create a TUI (tui) for bash scripts. The idea is to move the presentation a little beyond strictly line-by-line interactivity for scripts that humans will be working with, to present information a little more clearly and perhaps a little more nicely.

Scripts that will be writing to logs non-interactively shouldn't use this framework, because the output will be garbled by the various escape codes used to control the terminal contents.

The basic idea is to first set aside some number of lines in the terminal as the bounds for the TUI, and then render content into that area when desired. Once the need for the TUI has passed, it can be closed, and ordinary terminal output resumes.

**much more to come**

## License

[MIT](LICENSE.md)
