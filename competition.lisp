(in-package :webserver)
(defclass competition () 
	     ((title :initarg :title :initform "undefined" :accessor title :documentation "The title of competition") 
	     (date :initarg :date :initform "undefinded" :accessor date :documentation "When the competition was")
	     (begin-time :initarg :begin-time :initform "undefinded" :accessor begin-time :documentation "What time competition began")
	     (end-time :initarg :end-time :initform "undefinded" :accessor end-time :documentation "What time competition ended")

	      (judge :initarg :judje :initform "undefined" :accessor judje)
	      (secretary :initarg :secretary :initform "undefined" :accessor secretary)
	      (captions :initarg :captions :initform "undefined" :accessor captions)
	      )
  )


(defclass roundc ()
  (
   (group :initarg :group :initform "undefined" :accessor group)
   (round-type :initarg :round-type :initform "undefined" :accessor round-type)
   (results :initarg :results :initform nil :accessor results)
   )
  
)


(defun floatstr2time (floatstr)
  
  ) 

;(defmethod initialize-instance :after ((cmptt competition) &key) );
	
;  (when opening-bonus-percentage
;    (incf (slot-value account 'balance)
;          (* (slot-value account 'balance) (/ opening-bonus-percentage 100)))))




(defparameter *comp* (make-instance 'competition :title "test-title of test competition"))
(defparameter *round* (make-instance 'roundc :group "Юноши 5 лет" :round-type "100 км марафон" :results '(1 2 3)))

(defgeneric mongo-doc (object) (:documentation "Генерирует kv структуру для записи в БД mongo"))

(defmethod mongo-doc ((object competition))
  (son "title" (title object)
       "date" (date object)
       "begin-time" (begin-time object)
       "end-time" (end-time object)
       "captions" (captions object)
       )
  )


(defmethod mongo-doc ((object roundc))
  (son "group" (group object)
      "round-type" (round-type object)
      "results" (map 'list #'(lambda (res) (alist-hash-table res)) (results object))
  ))

;(defmethod mongo-doc ((reshash hash-table))
;  (apply #'son (loop for k being the hash-keys in reshash using (hash-value v)
;	 collect (son k v))
;    )
;  )