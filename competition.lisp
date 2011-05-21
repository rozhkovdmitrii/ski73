(in-package :webserver)
(defclass competition () 
	     ((title :initarg :title :initform "undefined" :accessor title :documentation "The title of competition") 
	     (date :initarg :date :initform "undefinded" :accessor date :documentation "When the competition was")
	     (begin-time :initarg :begin-time :initform "undefinded" :accessor begin-time :documentation "What time competition began")
	     (end-time :initarg :end-time :initform "undefinded" :accessor end-time :documentation "What time competition ended")

	      (judge :initarg :judje :initform "undefined" :accessor judje)
	      (secretary :initarg :secretary :initform "undefined" :accessor secretary)
	      )
	     )


(defclass roundc ()
  (
   (group :initarg :group :initform "undefined" :accessor group)
   (round-type :initarg :round-type :initform "undefined" :accessor round-type)
   (results :initarg :results :initform nil :accessor results)
   )
  
)





(defparameter *comp* (make-instance 'competition :title "test-title of test competition"))
(defparameter *round* (make-instance 'roundc :group "Юноши 5 лет" :round-type "100 км марафон" :results '(1 2 3)))

(defgeneric mongo-doc (object) (:documentation "Генерирует kv структуру для записи в БД mongo"))

(defmethod mongo-doc ((object competition))
  (kv (kv "title" (title object))
      (kv "date" (date object))
      (kv "begin-time" (begin-time object))
      (kv "end-time" (end-time object))
      ))

(defmethod mongo-doc ((object roundc))
  (kv (kv "group" (group object))
      (kv "round-type" (round-type object))
      (kv "results" (map 'list #'(lambda (res) (mongo-doc (alist-hash-table res))) (results object)))
  ))

(defmethod mongo-doc ((reshash hash-table))
  (apply #'kv (loop for k being the hash-keys in reshash using (hash-value v)
	 collect (kv k v))
    )
  )