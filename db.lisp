;;Использование mysql
(require :cl-mysql)

(in-package :cl-mysql)

(defvar *db* (connect :user "root" :password "7d5bcd02" :database "test_table"))

(defvar *result* (query "select * from test_table"))


;;Использование mongodb
(ql:quickload "cl-mongo")