;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; append-tuareg.el - Tuareg quick installation: Append this file to .emacs.

(setq make-backup-files nil) ; stop creating those backup~ files
(setq auto-save-default nil) ; stop creating those #autosave# files
(column-number-mode 1)
;;(global-linum-mode 1) ; display line numbers in margin. Emacs 23 only.
;;(cua-mode 1)

(transient-mark-mode 1) ; highlight text selection
(delete-selection-mode 1) ; delete seleted text when typing
(add-to-list 'auto-mode-alist '("\\.ml[iylp]?" . tuareg-mode))
;;(autoload 'tuareg-mode "tuareg" "Major mode for editing Caml code" t)
;;(autoload 'camldebug "camldebug" "Run the Caml debugger" t)
;(dolist (ext '(".cmo" ".cmx" ".cma" ".cmxa" ".cmi"))
;  (add-to-list 'completion-ignored-extensions ext))
(setq column-number-mode t)
;;(setq line-number-mode t)
(setq user-full-name "chalie_a")
;;(setq user-mail-address "chalie_a@epitech.eu")
(load-file "~/.emacs.d/std_comment.el")
(global-set-key [f11] 'std-file-header)
