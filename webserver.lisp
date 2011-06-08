(defpackage :webserver
  (:use :common-lisp :hunchentoot :cl-who
	:mongo :mongo-cl-driver.son-sugar
	:trivial-shell :cl-ppcre :json :alexandria))

(in-package :webserver)

;(defparameter *mconn* (mongo :db "ski73" :name :mconn))

(setf *hunchentoot-default-external-format* hunchentoot::+utf-8+)
;(setf *default-content-type* "text/html;charset=utf-8")

;;Инициализируем web сервис
(defparameter *server-instance* (make-instance 'hunchentoot:acceptor :port 4242) "my web server")
(hunchentoot:start *server-instance*)

;;Создаем подключение к БД

;;Коллекция competitions - соревнования
(defparameter *competitions* (mongo:collection (make-instance 'mongo:database :name "ski73") "competitions"))

;; Карта трансляции имен из xls в имена БД
(defparameter namesmap nil)


(load "/home/rds/devel/lisp/skisite/competition.lisp")

(setf *default-pathname-defaults* #P"/home/rds/devel/lisp/skisite/")
(setf *tmp-directory* #P"tmp/")
(push (namestring *default-pathname-defaults*) trivial-shell:*shell-search-paths*)
(trivial-shell:shell-command (concatenate 'string "cd " (namestring *default-pathname-defaults*)))

(setf *show-lisp-errors-p* t
)

(hunchentoot:define-easy-handler (say-yo :uri "/yo") (name patronimic)
  (setf (hunchentoot:content-type*) "text/html;charset=utf-8")
  (format nil "<h1>Привет~@[ ~A~]! ~a</h1>" name patronimic))

(setf *dispatch-table*
      (list (create-folder-dispatcher-and-handler
             "/" "/home/rds/devel/lisp/skisite/")))


(define-easy-handler (easy-demo :uri "/lisp/hello" :default-request-type :get)
  ()
  (no-cache)
  (setf (header-out "Content-Type") "text/html; charset=utf-8")
  (with-html-output-to-string (*standard-output* nil :prologue t)
			      (:html
			       (:head (:meta :charset "UTF-8") (:title "HW!!!") )
			       (:body
				(:h1 "Привет мир!")
				(:p "This is my Lisp web server, running on Hunchentoot,"
				    " as described in "
				    (:a :href
					"http://newartisans.com/blog_files/hunchentoot.primer.php"
					"this blog entry")
				    " on Common Lisp and Hunchentoot.")))))

;;Создание и регистрация функции обработчика в диспатчер
(defmacro define-url-fn ((name) &body body)
  `(progn (defun ,name ()
	  (no-cache)
	  (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
	  (with-html-output (*standard-output* nil :prologue nil) ,@body) )
	  (push
	  (create-prefix-dispatcher ,(format nil "/~(~a~)" name) ',name) *dispatch-table*)))





(define-url-fn (auth-form)
  (:html (:head (:title "Авторизация") (:META :HTTP-EQUIV "Content-Type" :CONTENT "text/html;charset=utf-8"))
	 (:body
	  (:div "Здесь будет авторизация")
	  (:ul (:li "Первый пункт") (:li "Пункт два"))
	  )))


(defun file-content (filepath)
  "Просто возращает строку с содержимым файла"
  (let ((path (pathname filepath)))
    (with-output-to-string (out) 
      (with-open-file (stream path) 
	(loop for line = (read-line stream nil)
	   while line do (format out "~a<br>~%" line))))))

;; Вычленяет из строки все подряд идущие ^, после этого тримит строку
(defun non-empty-cells-list (line) "This function remove excess commas from line from csv"
       (let ((result (concatenate 'string (string-trim " " (regex-replace-all "\\^+" line "" :preserve-case t)) ". ")))
	 result
	 ))


(defun mypairlis (keys values) "Моя реализация pairlis, которая расширяет в случае необходимости список values"
		  (let* ((kl (length keys)) (vl (length values)) (diff (- kl vl)))
		    (if (> diff 0) (setf values (append values (make-list diff :initial-element 0))))
		    (reverse (pairlis keys values))
		    ))


(load "/home/rds/devel/lisp/skisite/parse-competition-xls.lisp")

;Список троек {id, title, date} для передачи списка соревнований
(define-url-fn (competitions-list)
  (str (encode-json-to-string (find-list *competitions* :query (son) :fields (son "title" 1 "date" 1))))
  )

;Более подробная информацию по соревнованию
(define-url-fn (competition-info)
  (let ((id (post-parameter "id")) )
    (str
     (encode-json-to-string (find-one *competitions* 
				      (son "_id" (make-instance 'object-id :raw (flexi-streams:string-to-octets id))) 
				      (son "rounds" 1 "captions" 1 "title" 1)))
     )))
    
