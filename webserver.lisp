(defpackage :webserver
  (:use :common-lisp :hunchentoot :cl-who :cl-mongo :trivial-shell :cl-ppcre :json :alexandria))

(in-package :webserver)

;(defparameter *mconn* (mongo :db "ski73" :name :mconn))

(setf *hunchentoot-default-external-format* hunchentoot::+utf-8+)
;(setf *default-content-type* "text/html;charset=utf-8")

;;Инициализируем web сервис
(defparameter *server-instance* (make-instance 'hunchentoot:acceptor :port 4242) "my web server")
(hunchentoot:start *server-instance*)

;;Создаем подключение к БД
(defparameter  *mongo-ski73-conn* (cl-mongo:mongo :name :default :db "ski73") "Подключение к mongo-db базе ski73" )

;; Карта трансляции имен из xls в имена БД
(defparameter namesmap nil)


(load "/home/rds/devel/lisp/skisite/competition.lisp")



(setf *default-pathname-defaults* #P"/home/rds/devel/lisp/skisite/")
(setf *tmp-directory* #P"tmp/")
(push (namestring *default-pathname-defaults*) trivial-shell:*shell-search-paths*)
(trivial-shell:shell-command (concatenate 'string "cd " (namestring *default-pathname-defaults*)))

;(setf *dispatch-table*
;      (list #'dispatch-easy-handlers
;            #'default-dispatcher))

(setf *show-lisp-errors-p* t
);
;(setf *show-lisp-backtraces-p* t)


(hunchentoot:define-easy-handler (say-yo :uri "/yo") (name patronimic)
  (setf (hunchentoot:content-type*) "text/plain;charset=utf-8")
  (format nil "<h1>Привет~@[ ~A~]! ~a</h1>" name patronimic))

;(setf *dispatch-table*
;      (list (create-static-file-dispatcher-and-handler
;             "/hello.html" "/home/rds/devel/lisp/skisite/hello.html")))

(setf *dispatch-table*
      (list (create-folder-dispatcher-and-handler
             "/" "/home/rds/devel/lisp/skisite/")))

(define-easy-handler (easy-demo :uri "/lisp/hello" :default-request-type :get)
  ()
  (no-cache)
  (setf (header-out "Content-Type") "text/plain; charset=utf-8")
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



(defmacro standard-page ((&key title) &body body)
	 `(with-html-output-to-string (*standard-output* nil :prologue t :indent t)
	   (:html :xmlns "http://www.w3.org/1999/xhtml"
		  :xml\:lang "en" 
		  :lang "en"
		  (:head 
		   (:meta :http-equiv "Content-Type" 
			  :content    "text/html;charset=utf-8")
		   (:title ,title)
		   (:link :type "text/css" 
			  :rel "stylesheet"
			  :href "/retro.css"))
		  (:body 
		   (:div :id "header" ; Retro games header
			 (:img :src "/logo.jpg" 
			       :alt "Commodore 64" 
			       :class "logo")
			 (:span :class "strapline" 
				"Vote on your favourite Retro Game"))
		   ,@body))))

(defun retro-games ()
	 (standard-page (:title "Retro Games")
			(:h1 "Top Retro Games")
			(:p "We'll write the code later...")))

(push (create-prefix-dispatcher "/retro-games.htm" 'retro-games) *dispatch-table*)

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

;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
(defun trial-page ()
	     (with-html-output-to-string (*standard-output* nil :prologue t)
	       (:html (:head (:title "This a trial"))
		      (:body (:h1 "Combine Parenscript with cl-who")
			     (:p "Please click the link below." ))))) 
(push (create-prefix-dispatcher "/trial-page" 'trial-page) *dispatch-table*)

(defun auth ()
  (no-cache)
  (setf (hunchentoot:content-type*) "text/plain;charset=utf-8")
  (with-html-output (*standard-output* nil :prologue nil :indent t)
    (:html :XMLNS "http://www.w3.org/1999/xhtml" :|XML:LANG| "ru" :LANG "ru" 
	   (:head (:title "Привет лисперы!!!"))
	   (:body (:h1 "Привет лисперы!!!")))
))

(push (create-prefix-dispatcher "/auth" 'auth) *dispatch-table*)



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
		    (pairlis keys values)
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
				   (when line (push comp-round-result result)) line)
		      with result = '()
		      while line
		      finally (return-from file-walk result)
		 ))))



(defun secondary-analyse (rounds) "Вторичная обработка данных полученных при чтении xls файла с результатми соревнований на этом этапе должна производиться запись в БД, создание объектов CLOS"
       (loop for round in rounds
	  and cmpt = (make-instance 'competition
				    :title (cdr (assoc "cc-title" round :test #'string=))
				    :date (cdr (assoc "date" round  :test #'string=))
				    :begin-time (cdr (assoc "begining-time" round  :test #'string=))
				    :end-time (cdr (assoc "end-time" round  :test #'string=))
				    )
	  and roundcls = (make-instance 'roundc :group (cdr (assoc "group" round  :test #'string=))
					:round-type (cdr (assoc "round-type" round :test #'string=))
					:results  (cdr (assoc "results" round :test #'string=)))
	    
	  if (= (ret (db.count "competitions" (kv "title" (title cmpt)))) 0) do (db.insert "competitions" (mongo-doc cmpt))
	  do (db.update "competitions" (kv "title" (title cmpt)) (kv "$push" (kv "rounds" (mongo-doc roundcls))))
	    )
       (pp (iter (db.find "competitions" :all :skip 0)) :stream nil)
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
	(with-html-output-to-string (*standard-output* nil :prologue nil :indent t)
	  (cl-who:str (format nil "~a"
			      (secondary-analyse (analyse-competition newxlspath))
	  )))))
(push (create-prefix-dispatcher "/handlexls" 'handlexls) *dispatch-table*)

