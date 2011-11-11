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


;;mailing
(require 'cl-qprint)
(require 'trivial-utf-8)
(require 'cl-mime)
(require 'cl-smtp)





(require 'mongo-cl-driver)


(defpackage :webserver
  (:use :common-lisp :hunchentoot :cl-who
:mongo :mongo-cl-driver.son-sugar
:trivial-shell :cl-ppcre :json :alexandria))

(in-package :webserver)

(defparameter +root-path+ #p"/home/rds/devel/lisp/skisite/")
(defparameter +tmp-relative-path+ #p"tmp/")
(defparameter +static-relative-path+ #p"static/")
(defparameter +static-path+ (merge-pathnames +static-relative-path+ +root-path+))

(defparameter +photo-relative-path+ #p"photo/")
(defparameter +photo-path+ (merge-pathnames +photo-relative-path+ +static-path+))

(defparameter +tmp-path+ (merge-pathnames +tmp-relative-path+ +root-path+))
