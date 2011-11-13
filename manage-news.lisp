
(define-url-fn (news-file-upload)
  "Обработчик запроса первой стадии регистрации"
  (let* (
	 (len (parse-integer (header-in* "Content-Length")))
	 (input-stream (raw-post-data :want-stream t))
	 (key (gethash "key" (session-value 'user)))
	 (res-file (concatenate 'string "pht" key ))
	 (out-file-path (merge-pathnames res-file +photo-path+))
	 )
    (cpBytesStreamToFile input-stream out-file-path len)
    (update-op *users*  (son "key" key) (son "$set" (son "photo" res-file)))
    (revert-user-f)
    (str (format nil "{success : true, user : ~a}"
		 (encode-json-to-string (session-value 'user))
		 )
	 )
    ))
  (str "{status: 'done'}")
)