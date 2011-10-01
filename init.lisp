(require 'hunchentoot)
(require 'cl-who)
(require 'trivial-shell)
(require 'cl-ppcre)
(require 'cl-json)
(require 'alexandria)

(require 'ironclad)
(require 'iolib)
(require 'local-time)
(require 'closer-mop)
(require 'ieee-floats)
(require 'iterate)


(require 'mongo-cl-driver)

(require 'cl-mime)
(require 'cl-smtp)

(defpackage :webserver
  (:use :common-lisp :hunchentoot :cl-who
:mongo :mongo-cl-driver.son-sugar
:trivial-shell :cl-ppcre :json :alexandria))

(in-package :webserver)

(defparameter +root-path+ #p"/home/user/devel/ski73/")
(defparameter +tmp-relative-path+ #p"tmp")
(defparameter +tmp-path+ (merge-pathnames +tmp-relative-path+ +root-path+))
