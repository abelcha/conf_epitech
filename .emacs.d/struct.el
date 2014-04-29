;;
;; protected.el for q in /home/tovazm/.emacs.d
;; 
;; Made by chalie_a
;; Login   <abel@chalier.me>
;; 
;; Started on  Tue Apr 15 06:12:59 2014 chalie_a
;; Last update Fri Apr 25 23:21:09 2014 chalie_a
;;

(global-set-key (kbd"C-x k") 'insert-struct)
(global-set-key (kbd"C-x j") 'insert-dll)
(global-set-key (kbd"C-x c") 'insert-init)
(global-set-key (kbd"C-x C-a") 'insert-add)


;; ADD IN LIST
;;

(defun insert-add ()
  (interactive)
  (insert (get-add))
  (forward-line -7)
  )

(defun get-add ()
  (setq str (read-from-minibuffer
                    (format "How do you want to call your list : ")))
  (concat 
  
   "int\t\t\tadd_elem(t_" str " *elem)\n"
   "{\n"
   "  t_" str "\t\t*newelem;\n\n"
   "  if (!(newelem = malloc(sizeof(t_" str "))))\n"
   "    return (FAILURE);\n"
   "  newelem->prev = elem->prev;\n"
   "  newelem->next = elem;\n"
   "  elem->prev->next = newelem;\n"
   "  elem->prev = newelem;\n"
   "  return (SUCCESS);\n"
   "}\n"
   )
  )


;;
;; INIT ROOT
;;

(defun insert-init ()
  (interactive)
  (insert (get-init))
  (forward-line -7)
  )

(defun get-init ()
  (setq str (read-from-minibuffer
                    (format "How do you want to call your list : ")))
  (concat 
   "t_" str "\t\t*init_root()\n"
   "{\n"
   "  t_" str "\t\t*root;\n\n"
   "  if (!(root = malloc(sizeof(t_" str "))))\n"
   "    return (NULL);\n"
   "  root->prev = root;\n"
   "  root->next = root;\n"
   "  return (root);\n"
   "}\n"
   )
  )

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
	  "  struct s_" str "\t*prev;\n"
	  "  struct s_" str "\t*next;\n"
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
