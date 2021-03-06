(declaim (optimize (debug 0) (speed 3) (safety 0)))

(in-package :cl-apple-plist-decode)

(defun pair-list (lst)
  (if (null lst)
      nil
      (cons (cons (first lst) (second lst)) (pair-list (cddr lst)))))

(defun switch-to-cl-type (lst)
  (if (listp lst)
      (let ((type (car lst)))
        (cond ((eql type :|dict|)
               (let ((answer (make-hash-table :test 'equal)))             
                 (dolist (pair (pair-list (cdr lst)))
                   (when (listp (car pair))
                     (setf (gethash (second (car pair)) answer)
                           (switch-to-cl-type (cdr pair)))))
                 answer))
              ((eql type :|array|)
               (coerce (mapcar #'switch-to-cl-type (cdr lst)) 'vector))
              ((eql type :|integer|)
               (read-from-string (second lst)))
              ((eql type :|string|)
               (second lst))
              ((eql type :|real|)
               (read-from-string (second lst)))
              (t 
               (error "unsupproted type")
               nil)))
      (cond ((eql lst :|false|)
             nil)
            ((eql lst :|true|)
             t)
            ((eql lst :|string|)
             "")
            (t
             (error "unknown type")
             nil))))
  
(defun aplist-decode-file (path)
  (let ((xml (s-xml:parse-xml-file path)))
    (switch-to-cl-type (cadr xml))))

