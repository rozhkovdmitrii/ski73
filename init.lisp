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

(defparameter +root-path+ #p"/home/rozhkovdmitriy/ski73/")
(defparameter +tmp-relative-path+ #p"tmp/")
(defparameter +static-relative-path+ #p"static/")
(defparameter +static-path+ (merge-pathnames +static-relative-path+ +root-path+))

(defparameter +photo-relative-path+ #p"photo/")
(defparameter +photo-path+ (merge-pathnames +photo-relative-path+ +static-path+))

(defparameter +tmp-path+ (merge-pathnames +tmp-relative-path+ +root-path+))
