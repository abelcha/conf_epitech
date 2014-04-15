;;
;; protected.el for q in /home/tovazm/.emacs.d
;; 
;; Made by chalie_a
;; Login   <abel@chalier.me>
;; 
;; Started on  Tue Apr 15 06:12:59 2014 chalie_a
;; Last update Tue Apr 15 08:10:20 2014 chalie_a
;;

(global-set-key (kbd"C-c !") 'insert-struct)
(global-set-key (kbd"C-c p") 'insert-dll)


;;
;; DOUBLE LINKED LIST
;;

(defun insert-dll ()
  "Inserts a define to protect the header file."
  (interactive)
  (insert (get-dll))
  (forward-line -4)
  )

(defun get-dll ()
  "Return a protection for header files."
  (setq str (read-from-minibuffer
                    (format "How do you want to call your list : ")))
  (concat "typedef struct\t\t\ts_" str 
	  "\n{\n\n"
	  "  struct s_" str "\t\t\t*prev;\n"
	  "  struct s_" str "\t\t\t*next;\n"
	  "}\t\t\t\t" "t_" str ";\n")
)

;;
;; SIMPLE STRUCT
;;

(defun insert-struct ()
  "Inserts a define to protect the header file."
  (interactive)
  (insert (get-struct))
  (forward-line -2)
  )

(defun get-struct ()
  "Return a protection for header files."
  (setq str (read-from-minibuffer
                    (format "How do you want to call your list : ")))
  (concat "typedef struct\t\t\ts_" str 
	  "\n{\n\n"
	  "}\t\t\t\t" "t_" str ";\n")
)
