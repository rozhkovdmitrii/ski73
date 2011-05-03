(defpackage :webserver
  (:use :common-lisp :hunchentoot :cl-who :cl-mongo :trivial-shell cl-ppcre))

(in-package :webserver)

(defparameter *mconn* (mongo :db "skiing" :name :mconn))

(setf *hunchentoot-default-external-format* hunchentoot::+utf-8+)
;(setf *default-content-type* "text/html;charset=utf-8")

(defparameter *server-instance* (make-instance 'hunchentoot:acceptor :port 4242) "my web server")
(hunchentoot:start *server-instance*)

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
  (setf (hunchentoot:header-out "Content-Type") "text/plain; charset=utf-8")
  (with-html-output-to-string (*standard-output* nil :prologue t)
			      (:html
			       (:head (:meta :charset "UTF-8") (:title "HW!!!") )
			       (:body
				(:h1 "Привет мир!")
				(:p "This is my вввввLisp web server, running on Hunchentoot,"
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
       (string-trim " " (regex-replace-all "\\^+" line "" :preserve-case t)))

(defun analyse-competition (csvfilename)
	     (let ((path (pathname csvfilename)) 
		   (cc-title)) ;;current competition title
	       (with-open-file (stream path)
		 (loop named cc-walk for line = (read-line stream nil)
		    for i from 0 to 100
		    when (or (= i 0) (= i 1)) collect (non-empty-cells-list line) into  cc-title
		    finally (return-from cc-walk (reduce #'(lambda (x y) (concatenate 'string x ". " y)) cc-title))  
		 ))))




(defun handlexls ()
  (no-cache)
  (setf (hunchentoot:content-type*) "text/html;charset=utf-8")
  (let* ((relatedxls (post-parameter "relatedxls"))
	 (path (pathname (first relatedxls)))
	 (name (second relatedxls))
	 (pfx (directory-namestring *default-pathname-defaults*))
	 (newxlspath (concatenate 'string "tmp/" name ".csv"))
	 (command  (concatenate 'string "cd " pfx  "; xls2csv -q0 -c^ -b\"__newsheet\" "  (namestring path) " 2>/dev/null | grep -vE \"^([0-9]+)?\\^+$\" >" newxlspath))
	 )
     
	(trivial-shell:shell-command command)
	(with-html-output-to-string (*standard-output* nil :prologue nil :indent t)
	  (:html-file :XMLNS "http://www.w3.org/1999/xhtml" :|XML:LANG| "ru" :LANG "ru" 
		      (:head (:title "Обработка xls"))
		      (:body (:h1 "Обработка xls")
			     (:h2 (cl-who:str (format nil "<br>PATH is ~a<br>Name is ~a<br>Comand is ~a<br>Title:~a" (namestring path)  name command
						      (analyse-competition newxlspath)
						      )))
			     (:p (str  (file-content newxlspath)))
			     )))))

(push (create-prefix-dispatcher "/handlexls" 'handlexls) *dispatch-table*)


