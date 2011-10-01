
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

(defun set-user-in-db (reg-item)
    "Создание юзера по ключу"
    (let ((email (gethash "email" reg-item))
	  (key (gethash "key" reg-item))
	  (pwd (gethash "pwd" reg-item))
	  )
      (insert-op *users* (son "email" email "type" 3 "key" key "password" pwd "regdate" (get-universal-time)))
      )
    )


(define-url-fn (registration-approve)
  "Обработчик запроса подтверждения регистрации"
  (let* (
	 (key      (post-parameter "key"))
	 (reg-item (find-one *registrations* 
			     (son "key" key) (son))))
    (unless reg-item
      (error 'request-processing-error :text "Процесс регистрации по данному ключу неактивен"))
    (when (find-one *users* (son "key" key))
      (error 'request-processing-error
	     :text "Уже существует пользователь с такой же почтой"))
    (encode-json-to-string (set-user-in-db reg-item))
    (str "{status : 'done'}")
    ))
    
