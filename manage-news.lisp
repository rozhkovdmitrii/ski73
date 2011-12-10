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

(defun news-mailing-list (news-peace)
  "Вытаскиваем из базы список юзеров которые подписались на рассылку"
  (let ((comp (gethash "its-comp" news-peace))
	(query (son)))
    (if comp
      (setf (gethash "email-comp-flag" query) "on")
      (setf (gethash "email-other-news-flag" query) "on")
      )
    (let ((users-hash (find-list *users* :query query :fields (son "email" 1)))
	  )
      (map 'list #'(lambda (htable) (gethash "email" htable)) users-hash)
      )
    )
  ;(find
  )

(defun prepare-mailing-subject (subject)
    (let ((encoded-subj (cl-smtp:rfc2045-q-encode-string subject))) 
	  
	  (cl-ppcre:regex-replace-all "\\?=\\s+=\\?UTF-8\\?Q\\?" encoded-subj  "=20")
	  ))

(defun mailing (&key (theme "ski73 delivery") html (text "default delivery text") rcp )
  "Рассылка чего бы-то по всему списку рассылки"
  (cl-smtp:send-email
   "smtp.gmail.com"  
   "noreply@ski73.ru" 
   "noreply@ski73.ru"
   (prepare-mailing-subject theme)
   (make-utf8-string text) 
   :bcc rcp
   :ssl :tls
   :authentication '("noreply@ski73.ru" "fjmb58vc")
   :html-message (make-utf8-string html)
   ))


(defun sms-news-delivery (news-peace)
  "Рассылка новости по смс"
  )





(defun email-news-delivery (news-peace)
  "Рассылка новости по email"
  (mailing :theme (gethash "title" news-peace)
	   :html (url-decode (gethash "message" news-peace)) :rcp (news-mailing-list news-peace))
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
  (check-adm)
  (let* (
	 (title-image (first (post-parameter "title-image")))
	 (post-hash (news-piece-data))
	 (new-image-name (write-to-string (get-universal-time)))
	 (adm-key (gethash "key" (session-value 'user)))
	 (email-flag (gethash "email-flag" post-hash))
	 )
    (when title-image
      (rename-file title-image (merge-pathnames +news-img-path+ new-image-name)))
    (setf (gethash "title-image" post-hash) new-image-name)
    (setf (gethash "adm-key" post-hash) adm-key)
    (insert-op *news* post-hash)
    (when email-flag
      (email-news-delivery post-hash)
      )
    (str (encode-json-to-string post-hash))
    )
)