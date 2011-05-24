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

(defun read-till-break (istream)
  (let ((judge-reg "^Главный судья[ _]+(.*)$") (secretary-reg "^Главный секретарь[ _]+(.*)$"))
    (loop named cc-walk
       for line = (read-line istream nil) and i from 0 
       with cc-date and cc-title and group and begining-time and end-time and round-type and captions and judge-scan-res and judge and secretary-scan-res and secretary 
       while (and (string/= line "!newsheet!") line)
       if (<= i 1) do (setf cc-title (concatenate 'string cc-title (non-empty-cells-list line)))
       if (= i 2) do (setf cc-date (non-empty-cells-list line))
       if (= i 3) do (do-register-groups (gp bt) ("^\\^*([^^]+)\\^+([^^]+)\\^*$" line) 
			 (setf group (string-trim " " gp)) (setf begining-time (string-trim " " bt))) 
		       
       if (= i 4) do (do-register-groups (rt et) ("^\\^*([^^]+)\\^+([^^]+)\\^*$" line)
		       (setf round-type (string-trim " " rt)) (setf end-time (string-trim " " et)))
       if (= i 5) do (setf captions (split "\\^" line))
       if (and (> i 5) (> (length (split "\\^" line)) 1)) collect (mypairlis captions (split "\\^" line)) into results 
       if (first (setq judge-scan-res (multiple-value-list (scan-to-strings judge-reg line)))) do (setf judge (elt (second judge-scan-res) 0))
       if (first (setq secretary-scan-res (multiple-value-list (scan-to-strings secretary-reg line)))) do (setf secretary (elt (second secretary-scan-res) 0))
       finally (return-from cc-walk (values `(("cc-title" . ,cc-title)
					      ("date" . ,cc-date)
					      ("group" . ,group) 
					      ("begining-time" . ,begining-time)
					      ("end-time" . ,end-time)
					      ("round-type" . ,round-type)
					      ("captions" . ,captions)
					      ("results" . ,results)
					      ("judge" . ,judge)
					      ("secretary" . ,secretary)
					      ) line)) )))

(defun analyse-competition (csvfilename) "Функция получает на вход специализированный csv файл с результами соревнований. На выходе получаем соотв. списочную структуру"
	     (let ((path (pathname csvfilename)) 
		   
		   ) ;;current competition title
	       (with-open-file (stream path)
		 
		   (loop named file-walk 
		      for line = (multiple-value-bind (comp-round-result line) (read-till-break stream) 
				   (when line (setf result comp-round-result ) ) line)
		      with result = '()
		      while line
		      collect result into results
		      finally (return-from file-walk results)
		 ))))


(defun secondary-analyse (rounds) "Вторичная обработка данных полученных при чтении xls файла с результатми соревнований на этом этапе должна производиться запись в БД, создание объектов CLOS"
       (loop for round in rounds
	  and cmpt = (make-instance 'competition
				    :title (cdr (assoc "cc-title" round :test #'string=))
				    :date (cdr (assoc "date" round  :test #'string=))
				    :begin-time (cdr (assoc "begining-time" round  :test #'string=))
				    :end-time (cdr (assoc "end-time" round  :test #'string=))
				    :captions (cdr (assoc "captions" round :test #'string=))
				    )
	  and roundcls = (make-instance 'roundc :group (cdr (assoc "group" round  :test #'string=))
					:round-type (cdr (assoc "round-type" round :test #'string=))
					:results  (cdr (assoc "results" round :test #'string=)))
	    
	  if (= (collection-count *competitions* (son "title" (title cmpt))) 0)
		do (insert-op *competitions* (mongo-doc cmpt))
	  do (update-op *competitions* (son "title" (title cmpt)) (son "$push" (son "rounds" (mongo-doc roundcls))))
	 )
)

(defun handlexls ()
  (no-cache)
  (setf (hunchentoot:content-type*) "text/html;charset=utf-8")
  (let* ((relatedxls (post-parameter "relatedxls"))
	 (path (pathname (first relatedxls)))
	 (name (second relatedxls))
	 (pfx (directory-namestring *default-pathname-defaults*))
	 (newxlspath (concatenate 'string "tmp/" name ".csv"))
	 (command  (concatenate 'string "cd " pfx  "; xls2csv -q0 -c^ -b\"!newsheet!" '(#\Newline ) "\" "  (namestring path) " 2>/dev/null | grep -vE \"^([0-9]+)?\\^+$\" >" newxlspath))
	 )
     
	(trivial-shell:shell-command command)
	(secondary-analyse (analyse-competition newxlspath))
	(with-html-output-to-string (*standard-output* nil :prologue nil :indent t)
	  (cl-who:str (encode-json-to-string (find-list *competitions*  :query (son) :fields (son "title" 1)))
		      )
	  )))

(push (create-prefix-dispatcher "/handlexls" 'handlexls) *dispatch-table*)

;Список троек {id, title, date} для передачи списка соревнований
(define-url-fn (competitions-list)
  (str (encode-json-to-string (find-list *competitions* :query (son) :fields (son "title" 1 "date" 1))))
  )

(define-url-fn (competition-info)
  (let ((id (post-parameter "id")) )
    (str
     (encode-json-to-string (find-one *competitions* 
				      (son "_id" (make-instance 'object-id :raw (flexi-streams:string-to-octets id))) 
				      (son "rounds" 1 "captions" 1)))
     )))
    
