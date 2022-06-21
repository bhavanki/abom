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

The content of the TUI is just a string. So, all elements of the user interface are simply strings arranged into one or more lines on the terminal. The TUI content starts as some initial string, and then changes into different strings as things happen, like user input or time passing by or data arriving, until the conditions are appropriate to close the TUI.

The skeleton of this basic loop looks like this:

```bash
source ./abom.bash

abom_init 3 "$initial_content"
while true; do
  # wait for input / changes
  if [[ -n $should_close ]]; then
    break
  fi
  # update the content
  abom_render "$updated_content"
done
abom_close
```

## Example 1: Timed wait

[example_spinner.sh](examples/example_spinner.sh) waits a few seconds while displaying a spinner to pass the time. This example does not take any input, but instead uses a sleep to proceed from one iteration to the next.

## Components

abom supplies a number of reusable UI _components_. The spinner is one of them. Most components has a similar set of functions.

* `amod_make_xyz` creates a new component. This function usually takes arguments to describe the component's initial state. Some of these values are modified over the lifetime of the component.
* `amod_render_xyz` produces the string form of the component, based on its current state. This string is what gets included in the TUI content.
* One or more additional functions modify the component's state. The functions available depend on the component. For example, the spinner has `amod_tick_spinner` which causes the spinner's internal counter to advance by one.

You don't have to use any components in a TUI, but they are designed to mimic those in graphical UIs.

## Structs

bash doesn't natively support a typical struct/object data structure very well (associative arrays notwithstanding). abom rolls its own support that encodes a struct into a string. So, each abom component is a string, and the framework knows how to work with struct fields in the string - that is, it knows how to treat such a string as a struct.

See [abom_struct.bash](abom_struct.sh) to learn how structs work. You are free to use them for your own components, or other purposes.

## Example 2: Text input

[example_text_input.sh](examples/example_text_input.sh) gets the answer to a question using a text input component. Once the user enters a newline, the TUI closes and the script retrieves the text content.

The `amod_modify_text_input` function updates the text input component based on the key that was entered. For example, the component content may get a new character added to it, or removed from it.

## Keys

To support navigation and fine-grained editing, abom has a dedicated `read_key` function which attempts to read a single key pressed by the user. This is similar to other languages' support for receiving abstract keycodes from standard input.

```
key=$(read_key)
```

Ordinary characters are represented as themselves, e.g., "a", "X", "1", "&". Many special keys are represented instead as codes starting with an underscore. (The actual underscore character is represented as itself, "\_".)

* "\_tab" = tab
* "\_shift_tab" = shift+tab
* "\_nl" = newline (Enter / Return)
* "\_bs" = backspace
* "\_up" = up arrow
* "\_down" = down arrow
* "\_right" = right arrow
* "\_left" = left arrow
* "\_home" = home
* "\_end" = end
* "\_pgup" = page up
* "\_pgdn" = page down
* "\_ins" = insert
* "\_del" = delete
* "\_?" = an unsupported key

At this time, abom does not support key presses with control, alt, or command, nor the escape key or function keys.

**more to come**

## License

[MIT](LICENSE.md)
