(in-package :webserver)

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
	  for cmpt = (make-instance 'competition
				    :title (cdr (assoc "cc-title" round :test #'string=))
				    :date (cdr (assoc "date" round  :test #'string=))
				    :begin-time (cdr (assoc "begining-time" round  :test #'string=))
				    :end-time (cdr (assoc "end-time" round  :test #'string=))
				    :captions (cdr (assoc "captions" round :test #'string=))
				    )
	  for roundcls = (make-instance 'roundc :group (cdr (assoc "group" round  :test #'string=))
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
	  (cl-who:str (encode-json-to-string (find-list *competitions*  :query (son) :fields (son "title" 1)))))))


(push (create-prefix-dispatcher "/handlexls" 'handlexls) *dispatch-table*)
