(defun gen-symbolic-key (email)
    "Генерация произвольной текстовой последовательности"
    (encrypt email) 
    )



(defun registration-mail-message (sym-key)
  "Сообщение отправляемой на адрес электронной почты для подтверждения регистрации"
  (concatenate 'string "Следуйте по ссылке для регистрации http://" (host) "?op=aprove&key=" sym-key)
  )

(defun registration-mail-html-message (sym-key)
  "Сообщение отправляемой на адрес электронной почты для подтверждения регистрации"
  (let ((link (format nil "http://~a?op=aprove&key=~a" (host) sym-key)))
    (concatenate 'string "Следуйте по ссылке для регистрации <a href='" link "'>ski73.ru</a><br>"
	       "Если по каким то причинам вы не можете произвести переход, то просто скопируйте следующий текст в адресную строку браузера<br>"
	       link)
  )
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
    
    (mailing
     :theme "Регистрация на ski73.ru"
     :text (registration-mail-message key)
     :html (registration-mail-html-message key)
     :email email)

    (insert-op *registrations*
	       (son "email" email "key" key "pwd" (encrypt pass))) 

    
    (str (format nil
		 "{status : \"done\", message: \"На адрес ~a было отправлено соответсвующее письмо\"}" email
		 ))
    ))


(define-url-fn (context)
  "Обеспечивает передачу некоторых серверных установок для нормального клиент-серверного взаимодействия"
  (str (format nil "{now : ~a}" (get-universal-time)))
  )