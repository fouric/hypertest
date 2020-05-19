(defun get-all-symbols (&optional package)
  (let ((lst ())
        (package (find-package package)))
    (do-all-symbols (s lst)
      (when (fboundp s)
        (if package
            (when (eql (symbol-package s) package)
              (push s lst))
            (push s lst))))
    lst))

(defun get-all-function-names ()
  (let (functions)
    (dolist (package (list-all-packages) functions)
      (dolist (symbol (get-all-symbols package))
        (when (fboundp symbol)
          (push symbol functions))))))

(defun get-all-functions (names)
  (let (functions)
    (dolist (name names (nreverse functions))
      (push (symbol-function name) functions))))

(defun check-updated-functions (names functions)
  (loop for name in names for function in functions do (unless (eq (symbol-function name) function) (format t "function ~s has been changed~%" function))))

;; idea: store in either hash table, linked list, or array
;; if you store in linked list or array, then every time a function changes, move to the head of the list! then as you're going through the functions, you can hit the stuff that's most likely to have been changed first
;; if you use a hash table, keep a separate list or array
