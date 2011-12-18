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
(require 'timer)




(require 'mongo-cl-driver)


(defpackage :webserver
  (:use :common-lisp :hunchentoot :cl-who
:mongo :mongo-cl-driver.son-sugar
:trivial-shell :cl-ppcre :json :alexandria)
  (:import-from :cl-user :posix-getenv)
  )

(in-package :webserver)
(unless (posix-getenv "SKI73_HOME") (error 'error :text "SKI73_HOME has to been set"))

(defparameter +root-path+ (truename (posix-getenv "SKI73_HOME")))

(unless (posix-getenv "MAIL_PASS") (error 'error :text "MAIL_PASS has to been set"))
(defparameter +mail-pass+ (posix-getenv "MAIL_PASS"))

(defparameter +static-path+ (merge-pathnames #p"static/" +root-path+))
(defparameter +photo-path+ (merge-pathnames #p"photo/" +static-path+))
(defparameter +news-img-path+ (merge-pathnames #p"news-images/" +static-path+))
(defparameter +tmp-path+ (merge-pathnames #p"tmp/" +root-path+))

(defparameter +static-tmp-relative-path+ #p"static/tmp/")
(defparameter +static-tmp-path+ (merge-pathnames +static-tmp-relative-path+ +root-path+))

(defparameter +remove-timeout+ 10)

(timer:enable-timers)