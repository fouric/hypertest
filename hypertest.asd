;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(asdf:defsystem hypertest
  :name "hypertest"
  :description "automatically run tests when redefining functions"
  :version "0.0.0"
  :maintainer "fouric <fouric@protonmail.com>"
  :author "fouric <fouric@protonmail.com>"
  :license "MIT"

  :serial t
  :pathname "src"
  :components ((:file "package")
               (:file "hypertest")
               )

  :depends-on (:alexandria))
