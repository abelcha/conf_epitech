;;
;; protected.el for q in /home/tovazm/.emacs.d
;; 
;; Made by chalie_a
;; Login   <abel@chalier.me>
;; 
;; Started on  Tue Apr 15 06:12:59 2014 chalie_a
;; Last update Tue Apr 15 08:53:49 2014 chalie_a
;;

(global-set-key (kbd"C-c !") 'insert-struct)
(global-set-key (kbd"C-c p") 'insert-dll)


;;
;; DOUBLE LINKED LIST
;;

(defun insert-dll ()
  (interactive)
  (insert (get-dll))
  (forward-line -4)
  )

(defun get-dll ()
  (setq str (read-from-minibuffer
                    (format "How do you want to call your list : ")))
  (concat "typedef struct\t\ts_" str 
	  "\n{\n\n"
	  "  struct s_" str "\t\t\*prev;\n"
	  "  struct s_" str "\t\t\*next;\n"
	  "}\t\t\t" "t_" str ";\n")
)

;;
;; SIMPLE STRUCT
;;

(defun insert-struct ()
  (interactive)
  (insert (get-struct))
  (forward-line -2)
  )

(defun get-struct ()
  (setq str (read-from-minibuffer
                    (format "How do you want to call your list : ")))
  (concat "typedef struct\t\ts_" str 
	  "\n{\n\n"
	  "}\t\t\t" "t_" str ";\n")
)
