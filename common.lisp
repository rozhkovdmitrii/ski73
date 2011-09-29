(defun encrypt (stuff)
  "Возращает хеш переданной строки"
  (ironclad:byte-array-to-hex-string 
   (ironclad:digest-sequence
    :sha1 (flexi-streams:string-to-octets stuff)))
  )