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
   "date" (get-universal-time)
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
    (let ((users-hash (find-list *users* :query query :fields (son "email" 1))))
      (map 'list #'(lambda (htable) (gethash "email" htable)) users-hash)
      )
    )
  )

(defun news-sms-recipients (news-peace)
  "Извлечение списка получателей смс"
  (let ((comp (gethash "its-comp" news-peace))
	(query (son "phone" (son "$ne" ""))))
    (if comp
	(setf (gethash "sms-comp-flag" query) "on")
	(setf (gethash "sms-other-news-flag" query) "on")
	)
    (let ((phones-hash (find-list *users* :query query :fields (son "phone" 1))))
      (map 'list #'(lambda (phones) (gethash "phone" phones)) phones-hash)
      )))

(defun smsc-mail-request (&key message recipients)
  "Текст письма для смс рассылки"
  (check-adm)
  (format nil "ski73:~a:::,,ski73.ru:~{~a~^,~}:~a" +smsc-pass+ recipients message)
  )

		     
(defun prepare-mailing-subject (subject)
    (let ((encoded-subj (cl-smtp:rfc2045-q-encode-string subject))) 
      (cl-ppcre:regex-replace-all "\\?=\\s+=\\?UTF-8\\?Q\\?" encoded-subj  "=20")
	  ))



(defun sms-news-delivery (news-peace)
  "Рассылка новости по смс"
  (let* ((sms-text (gethash "sms" news-peace))
	 (smsc-mail-text (smsc-mail-request :message sms-text :recipients (news-sms-recipients news-peace))))
    (mailing
     :theme "sms-delivery"
     :email "send@send.smsc.ru"
     :text smsc-mail-text)
    ))

(defun email-news-delivery (news-peace)
  "Рассылка новости по email"
  (mailing
   :theme (gethash "title" news-peace)
   :html (url-decode (gethash "message" news-peace)) :bcc (news-mailing-list news-peace) :email "noreply@ski73.ru")
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
	 (sms-flag (gethash "sms-flag" post-hash))
	 )
    (when title-image
      (rename-file title-image (merge-pathnames +news-img-path+ new-image-name)))
    (setf (gethash "title-image" post-hash) new-image-name)
    (setf (gethash "adm-key" post-hash) adm-key)
    (insert-op *news* post-hash)
    (when email-flag
      (email-news-delivery post-hash))
    (when sms-flag
      (sms-news-delivery post-hash))
    (str (encode-json-to-string post-hash)) )
)


(define-url-fn (news-banch)
    "Возвращает в поток пачку новостей размещенных в промежутке времени между from и to"
  (let* ((from (post-parameter "from"))
	 (to (post-parameter "to"))
	 (news (find-list *news* :query (son) :fields (son))))
    (str (encode-json-to-string news))
  ))