(define-url-fn (add-peace-of-news)
  "Добавление новости"
  (let*
      (
       (title-image (post-parameter "title-image"))
       (tmpfile (first title-image))
       (origin (nth 2 title-image))
       (mime-type (third title-image))
       (max-size (post-parameter "MAX_FILE_SIZE"))
       (len (post-parameter "Content-Length"))
       )
    (str (format nil "{status : 'done', type : '~a', origin: '~a', tmpfile : '~a', maxsize : '~a', len : '~a'}"
		 mime-type origin tmpfile max-size (content-length*))
    
    )))