# 12 01 2024

## adventure 01: make break.sh windows-compatible
- brushing off an old bash script that i wrote for a mac
- basically my problem is that me saying "just 5 more minutes and then i will get lunch" easily becomes me never getting lunch... so this script strongly nudges me to take that break that i said i would, by putting the laptop to sleep and breaking my flow pretty abruptly (and annoyingly). ideally this snaps me out of whatever trance i am in
- this is also a good excuse to try out [ShellCheck – shell script analysis tool](https://www.shellcheck.net/)
- this was helpful for development: [How to Put a Windows 11 PC to Sleep](https://www.howtogeek.com/763430/how-to-put-a-windows-11-pc-to-sleep/)
    - `rundll32.exe powrprof.dll, SetSuspendState Sleep`
    - if i was willing to download separate tools, could use [PsShutdown - Sysinternals | Microsoft Learn](https://learn.microsoft.com/en-us/sysinternals/downloads/psshutdown) -- to avoid [hibernation and elevated prompt issues](https://winaero.com/how-to-sleep-windows-10-from-the-command-line/) and [task scheduling issues](https://stackoverflow.com/questions/32360306/sleep-via-shortcut-causes-schedule-tasks-to-not-wake-computer) -- however, decided i want to get as close as possible to letting this run on any windows machine without extra dependencies
    - that said, the hibernate issue _is_ pretty annoying lol

til (via asking [perplexity.ai](https://www.perplexity.ai/))
```markdown
- Use `#!/usr/bin/env bash` for scripts intended for portability and public distribution
- Use `#!/bin/bash` when security is a priority or when you need to pass additional parameters to the interpreter

sources:
- https://codejunction.hashnode.dev/the-advantage-of-using-usrbinenv-bash-over-binbash
- https://www.baeldung.com/linux/bash-shebang-lines
```

improvements:
- better logging with log levels
- better error handling
    - stricter error checking with `set -euo pipefail`
        - `-e` exits on errors
        - `-u` exits on undefined variables
        - `-o pipefail` exits if any command in a pipe fails
    - added error messages
- added validation for time input
- added command line options, including help text `--help` and a test mode `--no-lock` that doesn't actually lock computer
- cleaner script organization (better scoped functions, simpler logic, using constants, fewer globals, formatting time nicely)
- fixed all [shellcheck](https://www.shellcheck.net/) issues!
    - ^-- [SC2004](https://www.shellcheck.net/wiki/SC2004) (style): $/${} is unnecessary on arithmetic variables.
        - inside of any "arithmetic expansion" `$(( ))`, like within my `floor` function, the braces syntax was unnecessary
    - ^-- [SC2086](https://www.shellcheck.net/wiki/SC2086) (info): Double quote to prevent globbing and word splitting.
        - it seems the rule of thumb here is to quote variables when passing them to commands
    - ^-- [SC2294](https://www.shellcheck.net/wiki/SC2294) (warning): eval negates the benefit of arrays. Drop eval to preserve whitespace/symbols (or eval as string).
        - `"$@"` is a special parameter in bash that represents all positional parameters passed to a script or function, starting from `$1`.
        - script went from `eval "$@"` to `eval "$lock_command"`
        - why? this script didn't need to pass a well-defined lock command around as parameters. we can treat the command as a single string, preserve space appropriately, by switching to storing and evaluating the command directly
- switched from `#!/bin/bash` to `#!/usr/bin/env bash` for better portability and compatibility across systems, sacrificing some security (no longer specifying an exact executable) and the ability to additional parameters to the interpreter
- more emojis
- tangible improvement: my simple `floor` function looks less insane

will add linux support if i ever start using linux as my main driver again 😄
