(defun gen-symbolic-key (email)
    "Генерация произвольной текстовой последовательности"
    (encrypt email) 
    )

(defun registration-mail-message (sym-key)
  "Сообщение отправляемой на адрес электронной почты для подтверждения регистрации"
  (concatenate 'string "Please follow by this link : http://" (host) "?op=aprove&key=" sym-key)
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
			(registration-mail-message key)
			:ssl :tls
			:authentication '("noreply@ski73.ru" "fjmb58vc"))
    (insert-op *registrations*
	       (son "email" email "key" key "pwd" (encrypt pass))) 

    
    (str (format nil
		 "{status : \"done\", message: \"На адрес ~a было отправлено соответсвующее письмо\"}" email
		 ))
    ))

