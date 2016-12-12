;; -*- Mode: lisp; -*-
(in-package "CL-USER")

;; load all LispWorks patches
(load-all-patches)
;;; The following lines added by ql:add-to-init-file:
#-quicklisp
(let ((quicklisp-init (merge-pathnames ".quicklisp/setup.lisp"
                                       (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

;; add Sources/ directory to quicklisp local directories
(push (pathname "~/Sources/lisp") ql:*local-project-directories*)

;; update list of QuickLisp projects
(ql:register-local-projects)

;; to avoid printing circular references. See heap overflow example
;; http://paste.lisp.org/+31DI
;; Here, in the parent I have a reference to the children. In a child I have
;; a reference to the parent.  Therefore when printing I get infinite
;; loops.
;; With *print-circle* the print algorithm takes care of that, and uses the
;; #= ## syntax to denote shared structures including circles.
(setf *print-circle* t)

;; do not produce error when unbalanced right paren inserted
(setf system:*right-paren-whitespace* :warn)

;; Indent as in Emacs
(editor:setup-indent "if" 2 4 4)

;; Run GUI inspect when called from REPL
(setf *inspect-through-gui* t)

;; When recompiling a file with an existing defpackage, do not warn
;; when the defpackage is modified
;; Default value: (:WARN :MODIFY)
;; See http://www.lispworks.com/documentation/lw61/LW/html/lw-803.htm
;; for details
(setf hcl:*handle-existing-defpackage* '(:MODIFY))

;; Fix for OSX El Captain 
#+cocoa(remhash "NSGlyphStorage" objc::*interned-protocols*)

;; default external file format
(setf stream::*default-external-format* '(:utf-8 :eol-style :lf))

;; editor file format
(setf (editor:variable-value 'editor:output-format-default
                             :global) '(:utf-8 :eol-style :lf))

;; maximum editor windows
#+lw-editor
(setf editor:*maximum-ordinary-windows* nil)

;; turn off editor coloring of parenthesis
(editor::set-parenthesis-colours nil)

(require "delete-selection")
(editor:delete-selection-mode-command t)

;; turn off backup files
(setf (editor:variable-value `editor:backups-wanted) nil)

;; do not highlight found source and show found definition at 4th line
(setf editor:*source-found-action* '(4 nil))

;; aliases for upcase/downcase region commands
(editor:define-command-synonym "Upcase Region" "Uppercase Region")
(editor:define-command-synonym "Downcase Region" "Lowercase Region")

;; the following two forms make sure the "Find Source" command works
;; with the editor source
#-:lispworks-personal-edition
(load-logical-pathname-translations "EDITOR-SRC")

#-:lispworks-personal-edition
(setf dspec:*active-finders*
        (append dspec:*active-finders*
                (list "EDITOR-SRC:editor-tags-db")))



(ql:quickload "cl-fad")


(flet ((load-config-file (filename)
        (let ((file-full-path (cl-fad:merge-pathnames-as-file (cl-fad:pathname-directory-pathname *load-truename*) filename)))
          (compile-file file-full-path :load t))))
  (load-config-file "editor-extensions.lisp")
  (load-config-file "dvorak-binds.lisp")
  (load-config-file "other-binds.lisp")
  (load-config-file "lw-editor-color-theme/editor-color-theme.lisp")
  (load-config-file "darkula-theme.lisp")
  ;; TODO: isolate echo area colors, listener colors and add them to editor-color-theme
  (load-config-file "colors.lisp"))



;; Set the IDEA-style color theme
(editor-color-theme:color-theme "darkula")
;; Change the background colors of LispWorks' In-place completion and
;; 'Function Arglist Displayer' windows:
;; (setf capi::*editor-pane-in-place-background* :black)
;; (setf capi-toolkit::*arglist-displayer-background* :black)

;; start the Editor after the startup
(define-action "Initialize LispWorks Tools" "Ensure an Editor"
  (lambda (&optional screen) (capi:find-interface 'lw-tools:editor :screen screen)))
