(defun news-piece-data ()
  "Возращает хэш всех текстовых полей новости"
  (son
   "title" (post-parameter "title")
   "sms-flag" (post-parameter "sms-flag")
   "sms" (post-parameter "sms")
   "onlinereg" (post-parameter "onlinereg")
   "email-flag" (post-parameter "email-flag")
   "its-comp" (post-parameter "itscomp")
   "message" (url-encode (post-parameter "message"))
   "site-post-flag" (post-parameter "site-post-flag")
   )
  )

(define-url-fn (add-piece-of-news)
  "Добавление новости"
  (let*
      (
       (title-image (post-parameter "title-image"))
       (tmp-file (first title-image))
       (new-image-name nil)
       (post-hash (news-piece-data))
       )
    (when tmp-file
      (setf new-image-name (write-to-string (get-universal-time)))
      (let* ((source-path (merge-pathnames +tmp-path+ tmp-file))
	     (dest-path (merge-pathnames +static-tmp-path+  new-image-name)))
	
	(rename-file source-path dest-path)
	(defered-rm-file dest-path +remove-timeout+) 
	))
    (setf (gethash 'image post-hash) new-image-name)
    (encode-json-to-string post-hash)))


(define-url-fn (approve-piece-of-news)
  "Добавление новости"
  ;(check-adm)
  (let* (
	 (title-image (first (post-parameter "title-image")))
	 (post-hash (news-piece-data))
	 (new-image-name (write-to-string (get-universal-time)))
	 (adm-key (gethash "key" (session-value 'user)))
	 )
    (rename-file  title-image (merge-pathnames +news-img-path+ new-image-name))
    (setf (gethash "title-image" post-hash) new-image-name)
    (setf (gethash "adm-key" post-hash) adm-key)
    (insert-op *news* post-hash)
    (str (encode-json-to-string post-hash))
    )
)