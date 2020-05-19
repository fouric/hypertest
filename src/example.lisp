(in-package #:hypertest)

(defun rove-notify-test (function-name rove-test-name)
  (add-test :function function-name rove-test-name (lambda () (unless (rove:run-test rove-test-name :style :none)
                                                                (trivial-shell:shell-command (format nil "notify-send \"test ~s for ~s failed\"" rove-test-name function-name))
                                                                (format t "notify-send \"test ~s for ~s failed\"" rove-test-name function-name)))))

;;; example

(defun one-plus (x)
  (+ 1 x))

(ql:quickload :rove)
(use-package :rove)

(deftest plus-one-test
  (testing "positive numbers"
    (ok (= 2 (one-plus 1)))
    (let ((n (random 100)))
      (ok (= (1+ n) (one-plus n)))))
  (testing "negative numbers"
    (ok (= -2 (one-plus -3)))))
(fouric::rove-notify-test 'one-plus 'plus-one-test)

(defun one-plus-test ()
  (let ((n (- (random 100))))
    (assert (= (1+ n) (one-plus n)))))
(defun print-recompiled (name)
  (format t "~&recompiled FOURIC:~s~%" name))
(fouric:add-test :function 'one-plus 'one-plus-test)
(fouric:add-test :package "FOURIC" 'print-recompiled)

;; break it
(defun one-plus (x)
  (+ 2 x))
;; recompile

;; how to remove them afterward
(fouric:clear-tests :function 'one-plus)

;; want to develop a wrapper around ROVE:DEFTEST that takes the parameter
#++(defmacro defftest (name functions &body body)
     (a:once-only (name functions)
       (a:with-gensyms (really-list function)
         `(progn
            (rove:deftest ,name
              ,@body)
            (let ((,really-list (if (listp ,functions) ,functions (list ,functions))))
              (dolist (,function ,really-list)
                (format t "function: ~s~%" ,function)
                (remove-test ,function ,name)
                (rove-notify-test ,function ,name)))))))

(add-test :package "FOURIC" 'print-it (lambda (name)
                                        (format t "~&recompiled: ~s~%" name)))
