;;Использование mysql
(require :cl-mysql)

(in-package :cl-mysql)

(defvar *db* (connect :user "root" :password "7d5bcd02" :database "test_table"))

(defvar *result* (query "select * from test_table"))


;;Использование mongodb
(ql:quickload "cl-mongo")
;;Создаем подключение к БД
(defparameter  *mongo-ski73-conn* (cl-mongo:mongo :name "mongo-ski73-conn" :db "ski73") "Подключение к mongo-db базе ski73" )
;;Закрываем подключение к БД
;(mongo-close (mongo-registered "mongo-ski73-conn"))
(setf *mresult* (db.find "competitions" :all))
(= (ret (db.count "competitions" (kv "name" "Соревнование такое-т"))) 1)

