(require 'hunchentoot)
(require 'cl-who)
(require 'trivial-shell)
(require 'cl-ppcre)
(require 'cl-json)
(require 'alexandria)
(require 'mongo-cl-driver)
;(require 'yason)
;(require 'yason)
*;(require 'hunchentoot-test)
(defpackage :webserver
  (:use :common-lisp :hunchentoot :cl-who
:mongo :mongo-cl-driver.son-sugar
:trivial-shell :cl-ppcre :json :alexandria))

(in-package :webserver)

(defparameter +root-path+ #p"/home/rds/devel/lisp/skisite/")
(defparameter +tmp-relative-path+ #p"tmp")
(defparameter +tmp-path+ (merge-pathnames +tmp-relative-path+ +root-path+))
