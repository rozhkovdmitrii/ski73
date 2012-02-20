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

(defgeneric mongo-doc (object) (:documentation "Генерирует kv структуру для записи в БД mongo"))





(defclass roundc ()
  (
   (group :initarg :group :initform "undefined" :accessor group)
   (round-type :initarg :round-type :initform "undefined" :accessor round-type)
   (results :initarg :results :initform '() :accessor results)
   (captions :initarg :captions :initform "undefined" :accessor captions)
   )
  
)


(defun exeltime2timestr (floatstr)
  (let ( (float (read-from-string floatstr)))
    (multiple-value-bind (h r) (floor (* float 24)) (cons h 
	(multiple-value-bind (m r1) (floor (* r 60)) (cons m 
		(let ((s (floor (* r1 60)))) (cons s nil)
		     (return-from exeltime2timestr
		       (format nil "~2,'0d:~2,'0d:~2,'0d" h m s)
		       )
		     )
		))))))

(defmethod initialize-instance :after ((round roundc) &key) 
  (loop for result in (results round)
     do (loop for cell in result
	   if (and (stringp  (cdr cell)) (scan "^\\d+\\.\\d+(e[+-]?\\d*)?$"  (cdr cell)))
		   do (setf (cdr cell) (exeltime2timestr  (cdr cell)))
	     )
       )
)


(defmethod mongo-doc ((object competition))
  (son "title" (title object)
       "date" (date object)
       "begin-time" (begin-time object)
       "end-time" (end-time object)
       "captions" (captions object)
       "utime" (get-universal-time)
       )
  )


(defmethod mongo-doc ((object roundc))
  (son "group" (group object)
      "round-type" (round-type object)
      "results" (map 'list #'(lambda (res) (alist-hash-table res)) (results object))
       "utime" (concatenate 'string (write-to-string (get-universal-time)) (group object))
       "captions" (captions object)
  ))


(defun remove-round-f (comp-id utime)
  "Удаляем раунд с группой round-group из соревнования идентифицируемого по id"
  (update-op *competitions*
	     (son "_id" comp-id)
	     (son "$pull" (son "rounds" (son "utime" utime)))
	     )
  )

(defun remove-competition-f (comp-id)
  "Удаляем соревнование по comp-id"
  (delete-op *competitions* (son "_id" comp-id))
  )
