
;(define-url-fn (news-file-upload)
;  "Обработчик запроса первой стадии регистрации"
;  (let* (
;	 (len (parse-integer (header-in* "Content-Length")))
;	 (input-stream (raw-post-data :want-stream t))
;	 (res-file (format nil "news~a" (random 1000000)))
;	 (out-file-path (merge-pathnames res-file +news-img-path+))
;	 )
;    (cpBytesStreamToFile input-stream out-file-path len)
;    (str (format nil "{success : true}"))
;    ))
;)

(define-url-fn (add-peace-of-news)
  "Добавление новости"
  (let*
      (
       (title-image (post-parameter "title-image"))
       (tmpfile (first title-image))
       (origin (second title-image))
       (mime-type (third title-image))
       )
    (str (format nil "{status : 'done', type : '~a', origin: '~a', tmpfile : '~a'}"
		 mime-type origin tmpfile) )
    
    ))