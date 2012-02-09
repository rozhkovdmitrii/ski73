(make-instance 'mongo:database :name "ski73" )

(defmacro with-competitions-collection (name &body body)
  (let ((blog-symbol (gensym)))
    `(let* ((,blog-symbol (apply 'make-instance 'mongo:database '(:name "ski73")))
            (,name (mongo:collection ,blog-symbol "competitions")))
       (unwind-protect
            (progn ,@body)
         (mongo:close-database ,blog-symbol)))))

(with-competitions-collection cmptt (list :cmpttlen (mongo:collection-count cmptt)))





