(defpackage #:hypertest
  (:use #:cl)
  (:local-nicknames (:a :alexandria))
  (:export
   #:run-tests
   #:run-all-tests
   #:add-test
   #:remove-test
   #:list-tests
   #:clear-tests
   #:rove-notify-test
   ))
