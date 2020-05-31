(setq waiting-for-compile nil)
(setq hypertest-enabled nil)
(setq lisp-package nil)
(setq upcase-package t)
(setq upcase-symbol t)

(defun hypertest/set-lisp-package ()
  (interactive)
  (setq lisp-package (read-string "Enter default Common Lisp package> " "CL-USER"))
  (when upcase-symbol
    (setq lisp-package (upcase lisp-package))))

(defun ensure-lisp-package-set ()
  (unless lisp-package
    (hypertest/set-lisp-package))
  lisp-package)

(defun ensure-lisp-package (symbol-string)
  (let ((split (split-string symbol-string ":")))
    (cond
     ((= 1 (length split))
      (concat (ensure-lisp-package-set) "::" (if upcase-symbol
                                                 (upcase symbol-string)
                                               symbol-string)))
     ((= 2 (length split))
      (concat (if upcase-package
                  (upcase (first split))
                (first split))
              ":"
              (if upcase-symbol
                  (upcase (second split))
                (second split))))
     ((= 3 (length split))
      (concat (if upcase-package
                  (upcase (first split))
                (first split))
              "::"
              (if upcase-symbol
                  (upcase (third split))
                (third split))))
     (t
      (error "too many colons in symbol %s" symbol-string)))))

(defun extract-cl-function-name (region)
  (let* ((split (split-string region " "))
         (form-name? (first split))
         ;; how... do we actually get the package of this symbol/function?
         (function-name? (first (read-from-string (second split))))
         (is-defun (string= form-name? "(defun"))
         )
    (when (and is-defun
               (> (length split) 1))
      function-name?)))

;; doesn't work for REPL evaluation...

(defun watch-compile-finish (&rest args)
  (let* ((compiled-region (apply #'buffer-substring-no-properties args))
         (split (split-string compiled-region " "))
         (form-name? (first split))
         (function-name? (first (read-from-string (second split))))
         (is-defun (string= form-name? "(defun")))
    (when is-defun
      (if (> (length split) 1)
          (push function-name? waiting-for-compile)
        (message "[watch-compile-finish] not enough arguments to defun: %s" function-name?)))))

(defun compile-finish (&rest args)
  ;; SYMBOL-NAME here returns the function name as given in the source code itself, ignoring the actual package (which might be set by IN-PACKAGE)
  ;; ...of course. because all we're doing is parsing the name out from the source code and interning it. of course the package wouldn't be included.
  ;; how does slime do it?
  (when waiting-for-compile
    (let ((name (pop waiting-for-compile)))
      (message "recompiled %s" (symbol-name name))
      (slime-interactive-eval (concat "(when (find-package :fouric) (funcall (intern \"RUN-TESTS\" :fouric) :function '" (symbol-name name) "))")))))

;; ERROR, these don't work!
(add-hook 'slime-connected-hook (lambda ()
                                  (unless (fboundp 'watch-compile-finish)
                                    (add-hook 'slime-before-compile-functions 'watch-compile-finish))))
;;(add-hook 'slime-before-compile-functions 'watch-compile-finish)
(add-hook 'slime-connected-hook (lambda ()
                                  (unless (fboundp 'watch-compile-finish)
                                    (add-hook 'slime-compilation-finished-hook 'compile-finish))))
;;(add-hook 'slime-compilation-finished-hook 'compile-finish)

(defun hypertest/enable (&rest args)
  (interactive)
  (if (not hypertest-enabled)
      (progn
        (setf hypertest-enabled t)
        (add-hook 'slime-before-compile-functions 'watch-compile-finish)
        (add-hook 'slime-compilation-finished-hook 'compile-finish)
        (message "hypertest enabled"))
    (message "hypertest already enabled")))

(defun hypertest/disable (&rest args)
  (interactive)
  (setf hypertest-enabled nil)
  (remove-hook 'slime-before-compile-functions 'watch-compile-finish)
  (remove-hook 'slime-compilation-finished-hook 'compile-finish)
  (message "hypertest disabled"))

(defun hypertest/add-function-test-interactively (&rest args)
  (interactive)
  ;; what if we want to hover over the tester function and supply the testee function name?
  ;; FIXME: hardcoded UPCASE
  (let ((testee (upcase (extract-cl-function-name (apply #'buffer-substring-no-properties (slime-region-for-defun-at-point)))))
        (tester (read-string "test function name: ")))))

(defun hypertest/add-package-test-interactively (&rest args)
  (interactive)
  ;; what if we want to hover over the tester function and supply the testee function name?
  ;; FIXME: hardcoded UPCASE
  (let ((tester (upcase (symbol-name (extract-cl-function-name (apply #'buffer-substring-no-properties (slime-region-for-defun-at-point))))))
        (package (upcase (read-string "package: " (or lisp-package "")))))
    (slime-interactive-eval (concat "(when (find-package :hypertest) (funcall (intern \"COMMON-CASE\" :hypertest) \"" package "\" '" tester "))"))))
