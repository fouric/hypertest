(in-package #:hypertest)

(defparameter *package-tests* (make-hash-table :test 'equal))
(defparameter *function-tests* nil)

(defun run-tests (test-type name)
  ;;(format t "~&running tests for ~a::~s~%" (package-name (symbol-package name)) name)
  (ecase test-type
    (:function
     (run-tests-for-function name))
    (:package
     (run-tests-for-package name))))

(defun run-tests-for-function (function-name)
  (let ((plist (get function-name 'function-tests))
        (package-name (package-name (symbol-package function-name))))
    (run-tests-for-package package-name)
    (a:doplist (test-name test-function plist)
               ;;(format t "~&running test named ~s~%" test-name)
               (funcall test-function))))

(defun run-tests-for-package (package-name)
  (format t "~&run-tests-for-package: ~s~%" package-name)
  (a:when-let ((tests (gethash package-name *package-tests*)))
    (a:doplist (test-name test-function tests)
               (funcall test-function package-name))))

(defun common-case (package-name test-name)
  "the common case is that we want to run a test every time any function in a package is recompiled, we want to name the test the same as the name as the test function, and we want to access the test function by name instead of function object"
  (format t "~&common case: will run test ~s when anything in package ~s recompiled~%" test-name package-name)
  (add-test :package package-name test-name)
  (list-tests package-name :package))

(defun add-test (test-type name test-name &optional test)
  ;; (get function-name 'function-tests) returns the property list value for 'function-tests for the symbol given in FUNCTION-NAME
  ;; now that we have the 'function-tests property, we're going to store a plist in it
  ;; the keys of the plist are going to be symbols naming tests, and the values are going to be functions to be run
  (ecase test-type
    (:function
     (setf (getf (get name 'function-tests) test-name) (or test (symbol-function test-name))))
    (:package
     (when (symbolp name)
       (setf name (string name)))
     (format t "add-test on package; name: ~s; test-name: ~s~%" name test-name)
     (setf (getf (gethash name *package-tests*) test-name) (or test (symbol-function test-name))))))

(defun remove-test (test-type name test-name)
  (ecase test-type
    (:function
     (a:remove-from-plistf (get name 'function-tests) test-name))
    (:package
     (when (symbolp name)
       (setf name (string name)))
     (a:remove-from-plistf (gethash name *package-tests*) test-name))))

(defun list-tests (name &optional (test-type :all))
  (ecase test-type
    (:function
     (get name 'function-tests))
    (:package
     (gethash name *package-tests*))
    (:all
     (list-tests name :function)
     (list-tests (symbol-package name) :package))))

(defun clear-tests (test-type name)
  (ecase test-type
    (:function
     (setf (get name 'function-tests) nil))))


(defpackage #:hypertest/foo
  (:use #:cl))

(defun hypertest/foo::baz (x)
  (* x 2))
(defun test-foobaz ()
  (format t "running test-foobaz~%")
  (assert (= 4 (hypertest/foo::baz 2)))
  t)
(defpackage #:hypertest/bar
  (:use #:cl))
(defun hypertest/bar::baz (x)
  (* x 3))
(defun test-barbaz ()
  (format t "running test-barbaz~%")
  (assert (= 6 (hypertest/bar::baz 2)))
  t)

(add-test :function 'hypertest/foo::baz 'test-foobaz)
(add-test :function 'hypertest/bar::baz 'test-barbaz)

(defun my-doubler (x)
  (* 2 x))
(defun test-my-doubler ()
  (assert (= (my-doubler 5) 10)))
