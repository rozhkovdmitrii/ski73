(defparameter +remove-timeout+ 10)

(define-url-fn (add-peace-of-news)
  "Добавление новости"
  (let*
      (
       (title-image (post-parameter "title-image"))
       (tmp-file (first title-image))
       (new-image-name nil)
       )
    (when tmp-file
      (setf new-image-name (write-to-string (get-universal-time)))
      (let* ((source-path (merge-pathnames +tmp-path+ tmp-file))
	     (dest-path (merge-pathnames +tmp-static-path+  new-image-name)))
	
	(rename-file source-path dest-path)
	(defered-rm-file dest-path +remove-timeout+) 
	))
    (encode-json-to-string (son
			    'title (post-parameter "title")
			    'image new-image-name
			    'smsFlag (post-parameter "sms-flag")
			    'sms (post-parameter "sms")
			    'onlinereg (post-parameter "onlinereg")
			    'emailFlag (post-parameter "email-flag")
			    'itsComp (post-parameter "itscomp")
			    'message (url-encode (post-parameter "message"))
			    ))))


