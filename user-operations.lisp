

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
    
(define-url-fn (process-auth)
  "Обработчик запроса авторизации"
  (let* ((login (post-parameter "login"))
	 (password (post-parameter "password"))
	 (user-in-db (find-one *users* (son "email" login) (son)))
	 ) 
    (if (and user-in-db (string= (encrypt password) (gethash "password" user-in-db)))
	(progn (setf (session-value 'user) user-in-db)
	       (str (format nil "{status : \"done\", user : ~a}" (encode-json-to-string user-in-db))) )
	(error 'request-processing-error :text "Авторизация не удалась. Возможно вы что-то напутали"))
   ))


(define-url-fn (logout-from-site)
  "Обработчик запроса логаута"
  (delete-session-value 'user)
  (str "null")
  )

(defun current-user-f ()
  "Возвращает сессию user"
  (encode-json-to-string (session-value 'user))
)


(define-url-fn (current-user)
  "Отправляет в сеть current-user"
  (str (current-user-f))
  )


(defun revert-user-f ()
  "Перечитывает из базы поля текущего юзера"
  (setf (session-value 'user) (find-one *users* (son "email" (gethash "email" cu)) (son)))
  (current-user-f)
)

(define-url-fn (revert-user)
  "Обновляет данные текущего пользователя из базы"
  (str (revert-user-f))
)


(define-url-fn (set-photo-with-valums)
  "Хандлер для аплода при помощи плагина valums"
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

(define-url-fn (apply-profile)
  "Прием и сохранение данных профиля юзера"
  (let*
      ((data (alist-hash-table (post-parameters*))))
    ;;Неустановленные чекбоксы просто не передаются и не учитываются
    (update-op *users* (son "key" (gethash "key" (session-value 'user))) (son "$set" data))
    (str (format nil "{status : 'done', user : ~a, 'sms-comp-flag': '~a'}" (revert-user-f) (gethash "sms-comp-flag" data)))
    ))

(defun moder-request-list-f ()
    (encode-json-to-string (find-list *users* :query (son "moderRqst" "true") :fields (son)))
  )
(define-url-fn (moder-request-list)
  "Вернет список заявок на повышение полномочий. Осуществляется проверка на суперюзерность текущего оператора"
  (if (/= 1 (gethash "type" (session-value 'user)))
      (error 'request-processing-error :text "Текущий пользователь не обладает необходимыми полномочиями"))
  (let ((moder-requesters (moder-request-list-f)))
    (str (format nil "{status : 'done', list : ~a }"
		 moder-requesters))
    )
  )

(define-url-fn (moders-approve)
  (let ((rqsts (alist-hash-table (post-parameters*))))
    (loop for k being the hash-keys in rqsts using (hash-value v)
       if (= (parse-integer v) 0)
       do (update-op *users* (son "key" k) (son "$set" (son "type" 2)))
       end
       if (= (parse-integer v) 2)
       do (update-op *users* (son "key" k) (son "$set" (son "moderBan" T)))
       end
       do (update-op *users* (son "key" k) (son "$unset" (son "moderRqst" T)))
    )
    (format nil "{status : 'done', list : ~a, data : ~a}" (moder-request-list-f) (encode-json-to-string rqsts)) 

  ))