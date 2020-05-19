# hypertest

automatically run tests when redefining common lisp functions

## overview

hypertest aims to integrate testing into the standard slime-based common lisp development flow.

progress:

- [x] basic concept works with common lisp, slime, emacs
- [x] both per-function and whole-package tests
- [ ] emacs integration
  - [x] slime-compile-defun
  - [ ] slime-compile-file
  - [ ] repl compilation - will have additional benefit of working with other swank frontends e.g. slimv
  - [ ] automatically load when slime loaded
  - [ ] work when compiling functions using something other than defun
- [ ] convenience
  - [ ] automatic/persistent test adding
  - [ ] ergonomic test adding
- [ ] test success/failure reporting
  - [ ] in-repl report - printf
  - [ ] in-repl report - conditions
  - [ ] linux pop-up notification - notify-send
  - [ ] push notification to phone - pushover
  - [ ] blink(1)
  - [ ] separate GUI/TUI report window

## install

src/hypertest.el contains the elisp code, which isn't well-packaged, correct, or complete. right now, you just have to manually evaluate the contents of the file, plus the commented ADD-HOOK forms, when you want to enable hypertest.

the entire hypertest repository contains an asdf package. clone it to your quicklisp/local-projects, add a symlink there, or set the asdf search path to find it.

## usage

open slime, load the hypertest common lisp asdf package, run the code in hypertest.el to add the hooks to the slime compilation functions, then look at src/example.lisp for examples as to how to add tests to be run. you can either bind a test to a particular function recompilation, or you can bind it to be run when anything inside a package is recompiled.

## license

Copyright © fouric <fouric@protonmail.com>. Licensed under the MIT License.