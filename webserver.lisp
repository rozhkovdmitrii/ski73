(in-package :webserver)

;(defparameter *mconn* (mongo :db "ski73" :name :mconn))

(setf *hunchentoot-default-external-format* hunchentoot::+utf-8+)
;(setf *default-content-type* "text/html;charset=utf-8")

;;Инициализируем web сервис
(defparameter *server-instance* (make-instance 'hunchentoot:acceptor :port 4242) "my web server")
(hunchentoot:start *server-instance*)

;;Создаем подключение к БД

;;Коллекция competitions - соревнования
(defparameter *db* (make-instance 'database :name "ski73"))
(defparameter *competitions* (collection *db* "competitions"))
(defparameter *registrations* (collection *db* "registrations"))
(defparameter *users* (collection *db* "users"))

;; Карта трансляции имен из xls в имена БД
(defparameter namesmap nil)


(setf *default-pathname-defaults* +root-path+)

(load (merge-pathnames #p"common.lisp" +root-path+))

(load (merge-pathnames #p"competition.lisp" +root-path+))
(load (merge-pathnames #p"manage-news.lisp" +root-path+))

(setf *tmp-directory* #P"tmp/")


(push (namestring *default-pathname-defaults*) trivial-shell:*shell-search-paths*)
(trivial-shell:shell-command (concatenate 'string "cd " (namestring *default-pathname-defaults*)))

(setf *show-lisp-errors-p* t
)

(define-condition request-processing-error (error)
  ((text :initarg :text :reader text)))

(hunchentoot:define-easy-handler (say-yo :uri "/yo") (name patronimic)
  (setf (hunchentoot:content-type*) "text/html;charset=utf-8")
  (format nil "<h1>Привет~@[ ~A~]! ~a</h1>" name patronimic))

; привязка корня сайта
(push (create-static-file-dispatcher-and-handler "/" "static/hello.html") *dispatch-table*)

; привязка для всей статики на сайте
(push (create-folder-dispatcher-and-handler "/static/" #p"static/") *dispatch-table*)



(defun file-content (filepath)
  "Просто возращает строку с содержимым файла"
  (let ((path (pathname filepath)))
    (with-output-to-string (out) 
      (with-open-file (stream path) 
	(loop for line = (read-line stream nil)
	   while line do (format out "~a<br>~%" line))))))

;; 
(defun non-empty-cells-list (line)
  "This function remove excess commas from line from csv. Вычленяет из строки все подряд идущие ^, после этого тримит строку"
       (let ((result (concatenate 'string (string-trim " " (regex-replace-all "\\^+" line "" :preserve-case t)) ". ")))
	 result
	 ))


(defun mypairlis (keys values)
  "Моя реализация pairlis, которая расширяет в случае необходимости список values"
		  (let* ((kl (length keys)) (vl (length values)) (diff (- kl vl)))
		    (if (> diff 0) (setf values (append values (make-list diff :initial-element 0))))
		    (reverse (pairlis keys values))
		    ))


(load (merge-pathnames #p"parse-competition-xls.lisp" +root-path+))

(define-url-fn (competitions-list)
  "Список троек {id, title, date} для передачи списка соревнований"
  (str (encode-json-to-string (find-list *competitions* :query (son) :fields (son "title" 1 "date" 1))))
  )

(define-url-fn (competition-info)
  "Более подробная информацию по соревнованию"
  (let ((id (post-parameter "id")) )
    (str
     (encode-json-to-string (find-one *competitions* 
				      (son "_id" (make-instance 'object-id :raw (flexi-streams:string-to-octets id))) 
				      (son "rounds" 1 "captions" 1 "title" 1)))
     )))

    

;; Обработчики веб запросов
(load "request-processing.lisp")
;; Обработка юзер-ориентированных запросов
(load "user-operations.lisp")



