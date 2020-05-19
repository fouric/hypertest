(in-package #:hypertest)

;; TODO: everyone says to use symbol-plists, with a key in our package (and not the keyword package), and i agree

(defparameter *package-tests* (make-hash-table :test 'equal))

(defun run-tests (test-type name)
  ;;(format t "~&running tests for ~a::~s~%" (package-name (symbol-package name)) name)
  (ecase test-type
    (:function
     (let ((plist (get name 'function-tests))
           (package-name (package-name (symbol-package name))))
       (a:when-let ((tests (gethash package-name *package-tests*)))
         (a:doplist (test-name test-function tests)
             (funcall test-function name)))
       (a:doplist (test-name test-function plist)
           ;;(format t "~&running test named ~s~%" test-name)
           (funcall test-function))))
    (:package
     (a:when-let ((tests (gethash name *package-tests*)))
       (a:doplist (test-name test-function tests)
           (funcall test-function name))))))

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
