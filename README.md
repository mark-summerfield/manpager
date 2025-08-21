# Manpager

A GUI Unix man page viewer (an alternative to gman).

Manpager presents a browsable tree view of the system’s man pages.

It also supports apropos (keyword), full text, and man page name searches.

Man page links (e.g., `man(7)`) that appear in pages are clickable links
which change the display to the clicked man page. Similarly web links are
clickable (using showing pages in your web browser).

![Screenshot](images/screenshot.png)

When launched from the command line you can provide a word (apropos) to
search for in which case Manpager will begin with that search. Otherwise at
startup it will show either a random man page or the last viewed page
depending on your Config preference.

Note: I use [Store](https://github.com/mark-summerfield/store) for version
control so github is only used to make the code public.

## Dependencies

Tcl/Tk >= 9.0.2; Tcllib >= 2.0; Tklib >= 0.9; `man` executable.

## License

GPL-3

---
