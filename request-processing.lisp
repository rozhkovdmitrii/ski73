

(defun gen-symbolic-key (email)
    "Генерация произвольной текстовой последовательности"
    (encrypt email) 
    )


(defun .qprint-encode/utf-8 (string)
  (qprint:encode (map 'string
                      'code-char
                      (trivial-utf-8:string-to-utf-8-bytes string))))

(defun registration-mail-message (sym-key)
  "Сообщение отправляемой на адрес электронной почты для подтверждения регистрации"
  (concatenate 'string "Следуйте по ссылке для регистрации http://" (host) "?op=aprove&key=" sym-key)
  )

(define-url-fn (process-registration)
  "Обработчик запроса первой стадии регистрации"
  (let* (
	 (email (post-parameter "email"))
	 (pass (post-parameter "pass"))
	 (key (gen-symbolic-key email))
	 )
    (if (find-one *users* (son "key" key))
	(error 'request-processing-error
	       :text (concatenate 'string "Почта " email " уже занята.")))
    
    (cl-smtp:send-email "smtp.gmail.com" "noreply@ski73.ru"
			email "Registration"
			(.qprint-encode/utf-8 (registration-mail-message key))
			:ssl :tls
			:authentication '("noreply@ski73.ru" "fjmb58vc")
			:extra-headers '((:content-transfer-encoding "quoted-printable")
					 (:content-type "text/html; charset=utf-8"))
    )
    (insert-op *registrations*
	       (son "email" email "key" key "pwd" (encrypt pass))) 

    
    (str (format nil
		 "{status : \"done\", message: \"На адрес ~a было отправлено соответсвующее письмо\"}" email
		 ))
    ))


;(cl-smtp:send-email 
;	  "smtp.gmail.com" 
;	  "noreply@ski73.ru" 
;	  "rozhkovdmitriy@gmail.com"
;	  "registration"
;	  (.qprint-encode/utf-8 "<h1>ПРИВЕТ С ЛЫЖНИ!!!</h1>")
;	  :extra-headers '((:content-transfer-encoding "quoted-printable")
;			   (:content-type "text/html; charset=utf-8"))
;	  :ssl :tls
;	  :authentication '("noreply@ski73.ru" "fjmb58vc"))