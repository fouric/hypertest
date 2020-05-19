(setq waiting-for-compile nil)

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
  (when waiting-for-compile
    (let ((name (pop waiting-for-compile)))
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

(defun hypertest/add-test-interactively (&rest args)
  )
