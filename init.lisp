defpackage :webserver
  (:use :common-lisp :hunchentoot :cl-who
	:mongo :mongo-cl-driver.son-sugar
	:trivial-shell :cl-ppcre :json :alexandria))

(in-package :webserver)

(require 'hunchentoot)
(require 'cl-who)
(require 'trivial-shell)
(require 'cl-ppcre)
(require 'cl-json)
(require 'alexandria)

;;push (truename #P"/home/rozhkovdmitriy/lisp-packets/mongo-cl-driver/") asdf:*central-registry*)
(require 'mongo-cl-driver)
;(require 'yason)
;(require 'yason)
*;(require 'hunchentoot-test)
(
(defparameter +root-path+ #p"/home/rozhkovdmitriy/ski73/")
(defparameter +tmp-relative-path+ #p"tmp")
(defparameter +tmp-path+ (merge-pathnames +tmp-relative-path+ +root-path+))

;;(load (merge-pathnames "webserver.lisp" +root-path+))