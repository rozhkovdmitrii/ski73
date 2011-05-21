(require 'hunchentoot)
(require 'cl-who)



(require 'trivial-shell)
(require 'cl-ppcre)
(require 'cl-json)
(require 'alexandria)
;(require 'yason)
(push (truename #P"/home/rds/devel/lisp/libs/mongo-cl-driver") asdf:*central-registry*)
(asdf:oos 'asdf:load-op :mongo-cl-driver)

;(require 'yason)
*;(require 'hunchentoot-test)
