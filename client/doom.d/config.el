;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Jay Zawrotny"
      user-mail-address "jayzawrotny@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/roam")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom Fonts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq doom-font (font-spec :family "operator mono" :size 14 :weight 'medium))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Comment macro
;; - Similar to Clojure's. Lets you wrap any elisp code without eval'ing it.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro comment (&rest _)
  `nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General Settings
;; - What can I say? I'm fussy.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq
 tab-always-indent          t
 make-backup-files          nil
 create-lockfiles           nil
 uniquify-buffer-name-style 'post-forward-angle-brackets
 +ivy-buffer-preview        t)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Window Bindings
;; - Appease my muscle memory for Spacemacs' window splitting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(map! :map evil-window-map
      "/" #'evil-window-vsplit
      "-" #'evil-window-split
      "x" #'kill-buffer-and-window)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Root bindings
;; - General bindings for evil modes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defadvice! j/comment-save-cursor-position (comment-fn beg end &optional arg)
  "Comment or uncomment the region but also restore cursor position"
  :around #'comment-or-uncomment-region
  (save-excursion
    (let ((coords (point)))
      (message "Args: %s %s %s" beg end arg)
      (funcall comment-fn beg end arg)
      (message "Original coords %s new coords %s" coords (point)))))

(comment
 (advice-remove #'comment-or-uncomment-region #'j/comment-save-cursor-position))
(map! :nv "s-;" #'comment-or-uncomment-region)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hydra Paste
;; - Create a hydra similar to paste-transient-state to allow me to cycle the
;;   kill ring
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defhydra hydra-paste
  (:color red
    :hint nil)
  "\n[%s(length kill-ring-yank-pointer)/%s(length kill-ring)] \
 [_C-j_/_C-k_] cycles through yanked text, [_p_/_P_] pastes the same text \
 above or below. Anything else exits."
  ("C-j" evil-paste-pop)
  ("C-k" evil-paste-pop-next)
  ("p"   evil-paste-after)
  ("P"   evil-paste-before))

(map!
  :after evil
  :nv [remap evil-paste-after] #'hydra-paste/evil-paste-after
  :nv [remap evil-paste-before] #'hydra-paste/evil-paste-before)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clojure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package! anakondo
  :hook ((clojure-mode . anakondo-minor-mode)))

(comment
  (use-package! inf-clojure
    :hook ((clojure-mode . inf-clojure-minor-mode))))

(map!
  :after lispy
  :map lispy-mode-map-lispy
  "[" #'lispy-brackets
  "]" #'lispy-right-nostring)

(map!
  :after lispy
  :mode lispy-mode
  :n "[" #'lispy-backward
  :n "]" #'lispy-forward)


(after! clojure
  (setq! clojure-toplevel-inside-comment-form t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Maximize window size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; add to ~/.doom.d/config.el
(when-let (dims (doom-store-get 'last-frame-size))
  (when (eq (length dims) 4)
    (cl-destructuring-bind ((left . top) width height fullscreen) dims
      (setq initial-frame-alist
        (append initial-frame-alist
          `((left . ,left)
             (top . ,top)
             (width . ,width)
             (height . ,height)
             (fullscreen . ,fullscreen)))))))

(defun save-frame-dimensions ()
  (doom-store-put 'last-frame-size
                  (list (frame-position)
                        (frame-width)
                        (frame-height)
                        (frame-parameter nil 'fullscreen))))

(add-hook 'kill-emacs-hook #'save-frame-dimensions)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JavaScript
;; - Fix indent on multi-line exprs
;; - General JS configuration
;; - Relies on editorconfig for most changes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defadvice! j/fix-js-multi-line-indent ()
  "Indent expression declarations by 2 just like the rest of the code"
  :after-while #'js--multi-line-declaration-indentation
  (let ((beg (match-beginning 0)))
    (when beg
      (goto-char beg)
      (+ js-indent-level (current-column)))))

(use-package! js2-mode
  :config
  (setq
    js-expr-indent-offset -2
    js-chain-indent nil))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Current File Operations
;; - Copies Spacemacs' delete-current-buffer-file to delete the file and buff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun delete-current-buffer-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
         (buffer (current-buffer)))
    (if (not (and filename (file-exists-p filename)))
      (ido-kill-buffer)
      (when (yes-or-no-p "Are you sure you want to delete this file? ")
        (delete-file filename t)
        (kill-buffer buffer)
        (when (and (configuration-layer/package-usedp 'projectile)
                (projectile-project-p))
          (call-interactively #'projectile-invalidate-cache))
        (message "File '%s' successfully removed" filename)))))

;; from magnars
(defun rename-current-buffer-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let* ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let* ((dir (file-name-directory filename))
             (new-name (read-file-name "New name: " dir nil nil filename)))
        (cond ((get-buffer new-name)
               (error "A buffer named '%s' already exists!" new-name))
              (t
               (let ((dir (file-name-directory new-name)))
                 (when (and (not (file-exists-p dir)) (yes-or-no-p (format "Create directory '%s'?" dir)))
                   (make-directory dir t)))
               (rename-file filename new-name 1)
               (rename-buffer new-name)
               (set-visited-file-name new-name)
               (set-buffer-modified-p nil)
               (when (fboundp 'recentf-add-file)
                   (recentf-add-file new-name)
                   (recentf-remove-if-non-kept filename))
               (when (and (configuration-layer/package-usedp 'projectile)
                          (projectile-project-p))
                 (call-interactively #'projectile-invalidate-cache))
               (message "File '%s' successfully renamed to '%s'" name (file-name-nondirectory new-name))))))))

(defun copy-project-path ()
  "Copies the current buffer path from the project root to copy a relative path"
  (interactive)
  (let* ((file-path (buffer-file-name))
         (project-path (or (doom-project-root) ""))
         (rel-path (replace-regexp-in-string (regexp-quote project-path) "" file-path nil 'literal)))
    (kill-new rel-path)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Zoom
;; - Use the hydra module's zoom example
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(map!
  :leader
  :desc "Font zoom" "z" #'+hydra/text-zoom/body)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flycheck Popup Tip Formatting
;; - Flycheck popup is a bit difficult to read\distinguish from surrounding code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-faces!
  '(popup-tip-face
     :background "#FD6D6E" :foreground "black"
     :weight normal :slant oblique
     :height 120)
  '(flycheck-posframe-face
     :weight normal :slant oblique)
  '(flycheck-posframe-warning-face
     :background "#ECBE7B" :foreground "black")
  '(flycheck-posframe-info-face
     :background "#7EAF54" :foreground "black")
  '(flycheck-posframe-error-face
     :background "#FD6D6E" :foreground "black"))

(defun j/format-flycheck-messages (msg)
  (concat
    " "
    flycheck-popup-tip-error-prefix
    (flycheck-error-format-message-and-id msg)
    " "))

(defun j/sort (pred errors)
  (sort errors pred))

(defun j/flycheck-errors->string (errors)
  "Formats ERRORS messages for display. Pads left and right of message with a space"
  (let ((messages (->> errors
                    (delete-dups)
                    (mapcar #'j/format-flycheck-message)
                    (j/sort))))
    (mapconcat 'identity messages "\n")))

(defadvice! j/format-flycheck-popup (errors)
  "Add padding to errors"
  :override #'flycheck-popup-tip-format-errors
  (-> errors
    (j/flycheck-errors->string)
    (propertize 'face 'popup-tip-face)))

(defadvice! j/flycheck-posframe-format-error (err)
  "Pads error message"
  :override #'flycheck-posframe-format-error
  (propertize (concat
                " "
                (flycheck-posframe-get-prefix-for-error err)
                (flycheck-error-format-message-and-id err)
                " ")
    'face
    `(:inherit ,(flycheck-posframe-get-face-for-error err))) )



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Evil Insert Newline and continue comments
;; - When pressing o on a repeating comment divider like the line below:
;;   create a new line tht is not in a comment
;; - Consider switching to substring the starter to ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defadvice! j/comment-indent (&optional continue)
  "Indent this line's comment to `comment-column', or insert an empty comment.
If CONTINUE is non-nil, use the `comment-continue' markers if any."
  :override #'comment-indent
  (interactive "*")
  (comment-normalize-vars)
  (let* ((empty (save-excursion (beginning-of-line)
                  (looking-at "[ \t]*$")))
          (starter (or (and continue comment-continue)
                     (and empty block-comment-start) comment-start))
          (ender (or (and continue comment-continue "")
                   (and empty block-comment-end) comment-end)))
    (unless starter (error "No comment syntax defined"))
    (beginning-of-line)
    (let* ((eolpos (line-end-position))
            (begpos (comment-search-forward eolpos t))
            (first-three (substring starter 0 3))
            (fst (substring starter 0 1))
            (test-str (concat fst fst fst))
            cpos indent)
      (if (and comment-insert-comment-function (not begpos))
        ;; If no comment and c-i-c-f is set, let it do everything.
        (funcall comment-insert-comment-function)
        ;; An existing comment?
        (if begpos
          (progn
            (if (and (not (looking-at "[\t\n ]"))
                  (looking-at comment-end-skip))
              ;; The comment is empty and we have skipped all its space
              ;; and landed right before the comment-ender:
              ;; Go back to the middle of the space.
              (forward-char (/ (skip-chars-backward " \t") -2)))
            (setq cpos (point-marker)))
          ;; If none, insert one.
          (save-excursion
              ;; Some `comment-indent-function's insist on not moving
              ;; comments that are in column 0, so we first go to the
              ;; likely target column.
              (indent-to comment-column)
              ;; Ensure there's a space before the comment for things
              ;; like sh where it matters (as well as being neater).
              (unless (memq (char-before) '(nil ?\n ?\t ?\s))
                (insert ?\s))
              (setq begpos (point))
            (unless (equal first-three test-str)
                (insert starter))
            (setq cpos (point-marker))
            (unless (equal first-three test-str)
              (insert ender))))
        (goto-char begpos)
        ;; Compute desired indent.
        (setq indent (save-excursion (funcall comment-indent-function)))
        ;; If `indent' is nil and there's code before the comment, we can't
        ;; use `indent-according-to-mode', so we default to comment-column.
        (unless (or indent (save-excursion (skip-chars-backward " \t") (bolp)))
          (setq indent comment-column))
        ;; (if (not indent)
        ;;   ;; comment-indent-function refuses: delegate to line-indent.
        ;;   (indent-according-to-mode)
        ;;   ;; If the comment is at the right of code, adjust the indentation.
        ;;   (unless (save-excursion (skip-chars-backward " \t") (bolp))
        ;;     (setq indent (comment-choose-indent indent)))
	      ;;   ;; If that's different from comment's current position, change it.
	      ;;   (unless (= (current-column) indent)
	      ;;     (delete-region (point) (progn (skip-chars-backward " \t") (point)))
	      ;;     (indent-to indent)))
	      (goto-char cpos)
	      (set-marker cpos nil)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Evil Lisp State
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun unwrap-comment ()
  "Unwrap sexp (comment ...)"
  (interactive)
  (save-excursion
    (forward-char)
    (beginning-of-sexp)
    (let ((line (string-trim (thing-at-point 'line))))
      (if (equal line "(comment")
        (cl-destructuring-bind (beg . end) (bounds-of-thing-at-point 'line)
          (lispyville-join beg end)
          (sp-backward-sexp)
          (sp-backward-sexp)))
      (sp-unwrap-sexp)
      (sp-kill-sexp)
      (indent-sexp))))

(defun wrap-comment ()
  "Wrap sexp in (comment ...) and indent it"
  (interactive)
  (let ((sexp (save-excursion
                (sexp-at-point))))
    (if (or (eq sexp 'comment)
            (eq (car sexp) 'comment))
      (unwrap-comment)
      (sp-wrap-with-pair "(")
      (insert "comment\n")
      (indent-for-tab-command)
      (evil-first-non-blank))))

(use-package! evil-lisp-state
  :init
  (setq evil-lisp-state-global t)
  :config
  (map!
    :map evil-lisp-state-map
    ";" (evil-lisp-state-enter-command wrap-comment))
  (map! :leader :desc "Lisp" "k" evil-lisp-state-map))

(after! doom-modeline
  (custom-set-faces!
    '(doom-modeline-evil-operator-state :foreground "#FF9F9E")))

(defsubst j/doom-modeline--evil ()
  "The current evil state. Requires `evil-mode' to be enabled."
  (when (bound-and-true-p evil-local-mode)
    (doom-modeline--modal-icon
     (let ((tag (evil-state-property evil-state :tag t)))
       (if (stringp tag) tag (funcall tag)))
     (cond
      ((evil-normal-state-p)   'doom-modeline-evil-normal-state)
      ((evil-emacs-state-p)    'doom-modeline-evil-emacs-state)
      ((evil-lisp-state-p)     'doom-modeline-evil-emacs-state)
      ((evil-insert-state-p)   'doom-modeline-evil-insert-state)
      ((evil-motion-state-p)   'doom-modeline-evil-motion-state)
      ((evil-visual-state-p)   'doom-modeline-evil-visual-state)
      ((evil-operator-state-p) 'doom-modeline-evil-operator-state)
      ((evil-vterm-state-p)    'error)
      ((evil-replace-state-p)  'doom-modeline-evil-replace-state)
      (t                       'doom-modeline-evil-normal-state))
     (evil-state-property evil-state :name t))))

(after! (evil-lisp-state doom-modeline)
  (doom-modeline-def-segment modals
    "Displays modal editing states, including `evil', `overwrite', ... etc."
    (let* ((evil (j/doom-modeline--evil))
           (ow (doom-modeline--overwrite))
           (vsep (doom-modeline-vspc))
           (sep (and (or evil ow) (doom-modeline-spc))))
      (concat sep
              (and evil (concat evil (and ow vsep)))
              (and ow (concat ow))
              sep))))

(defun j/evil-state-fg (state)
  (let ((sym (intern (concat "doom-modeline-evil-" state "-state"))))
    (face-foreground sym nil t)))

(add-hook! 'doom-load-theme-hook
    (defun j/theme-evil-cursors ()
      (setq
       evil-insert-state-cursor   (list 'bar (j/evil-state-fg "insert"))
       evil-normal-state-cursor   (list 'box (j/evil-state-fg "normal"))
       evil-visual-state-cursor   (list 'box (j/evil-state-fg "visual"))
       evil-operator-state-cursor (list 'box (j/evil-state-fg "operator"))
       evil-lisp-state-cursor     (list 'box (j/evil-state-fg "emacs"))
       evil-vterm-state-cursor    (list 'box (face-foreground 'error nil t)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rename Prefixes
;; - The which-key menu can sometimes display too long of names which causes
;;   them to be truncated.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! which-key
  (add-to-list
    'which-key-replacement-alist
    '((nil . "evil-lisp-state-") . (nil . "")))
  (add-to-list
    'which-key-replacement-alist
    '((nil . "evil-mc-") . (nil . "")))
  (add-to-list
    'which-key-replacement-alist
    '((nil . "+multiple-cursors/") . (nil . ""))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Prompt Workspace Rename
;; - After creating a workspace prompt to rename. Anon workspaces are not a
;;   fun surprise.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun j/workspace-new (&optional _ clone-p)
  "Prompt for a workspace name after creating the workspace"
  (interactive "iP")
  (+workspace/new nil clone-p)
  (when-let (newname (read-string
                      "Workspace name: "
                      (+workspace-current-name)))
    (+workspace/rename newname)))

(after! persp-mode
  (map! [remap +workspace/new] #'j/workspace-new)
  (map! :leader "TAB N" #'+workspace/new))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Make line numbers brighter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-faces!
  '(line-number
    :foreground "#888")
  '(line-number-current-line
    :foreground "#ebbd80"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Indent guides
;; - Show only the active guide
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun j/active-guide (level responsive display)
  (when (eq responsive 'top)
    (highlight-indent-guides--highlighter-default
      level responsive display)))

(after! highlight-indent-guides
  (setq
    highlight-indent-guides-auto-enabled         nil
    highlight-indent-guides-responsive           'top
    highlight-indent-guides-delay                0
    highlight-indent-guides-highlighter-function 'j/active-guide)
  (custom-set-faces!
    '(highlight-indent-guides-top-character-face
       :foreground "#DE5356")))

;; Uncomment this if you don't like indent guides in lisp languages
(comment
  (add-hook! '(lisp-mode-hook emacs-lisp-mode-hook clojure-mode-hook)
    (defun +disable-indent-guides-in-lisp ()
      (message "Disable indent-guides")
      (highlight-indent-guides-mode -1))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tramp
;; - Set shell to bash for simplicity
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! tramp
  ;; (setenv "SHELL" "/usr/local/bin/fish")
  (setq tramp-default-method "sshx"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Send region to tmux
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun j/persp-name ()
  (or (safe-persp-name (get-current-persp))
      "main"))

(defun j/cmd (command &rest args)
  "Run a command and return output"
  (let* ((args (mapcar #'shell-quote-argument (delq nil args)))
         (cmdstr (if args (apply #'format command args) command))
         (output (get-buffer-create " *cmd stdout*"))
         (errors (get-buffer-create " *cmd stderr*"))
         code)
    (unwind-protect
        (if (= 0 (setq code (quiet! (shell-command cmdstr output errors))))
            (with-current-buffer output
              (buffer-string))
          (error "[%d] %s $ %s (%s)"
                 code
                 cmdstr
                 (with-current-buffer errors
                   (buffer-string))
                 cmdstr))
      (and (kill-buffer output)
           (kill-buffer errors)))))

(defun j/tmux-sessions ()
  "Returns a lit of active tmux-sessions"
  (-> (j/cmd "tmux list-sessions %s %s" "-F" "#S")
      (split-string nil nil)))

(defun j/tmux-select-session ()
  "Select and update a tmux session associated with the persp"
  (interactive)
  (let* ((sessions (j/tmux-sessions))
         (persp-key (intern (j/persp-name))))
    (ivy-read "Select tmux session: " sessions
              :history j/tmux-history
              :initial-input (plist-get j/tmux-sessions persp-key)
              :action (lambda (session)
                        (setq j/tmux-sessions
                              (plist-put j/tmux-sessions persp-key session))))))

(defun j/tmux-select-get-session ()
  "Get the tmux session for the given persp or select a new one"
  (interactive)
  (let* ((persp-key (intern (j/persp-name)))
         (session   (plist-get j/tmux-sessions persp-key)))
    (if session
        session
        (j/tmux-select-session))))

(defun j/tmux-run (command &optional append-return)
  "Run COMMAND in tmux. If NORETURN is non-nil, send the commands as keypresses
but do not execute them."
  (interactive "P")
  (let* (;; (cmd (concat command (when append-return "\r\n")))
         (cmd command)
         (session (j/tmux-select-get-session))
         (tmp (make-temp-file "emacs-send-tmux" nil nil cmd)))
    ;; (message "tmux-run: text %s" cmd)
    (unwind-protect
        (progn
          (message "tmux-run")
          (message "%s" cmd)
          (message "---")
          (j/cmd "tmux load-buffer %s" tmp)
          (j/cmd "tmux paste-buffer -dpr -t %s;" session)
          (when append-return
            (j/cmd "tmux send-keys -t %s Enter;" session))
          )
      (delete-file tmp))))

(defun j/tmux-send-region (beg end &optional append-return)
  "Send region to tmux."
  (interactive "rP")
  (j/tmux-run (buffer-substring-no-properties beg end)
              append-return))

(defun j/tmux-send-paragraph ()
  "Send current paragraph to the selected tmux session"
  (interactive)
  (cl-destructuring-bind (beg . end)
      (bounds-of-thing-at-point 'paragraph)
    (j/tmux-send-region beg end t)))

(defun j/tmux-send-src-block ()
  "Send current src block to selected tmux session"
  (interactive)
  (org-babel-when-in-src-block
   (let* ((info (org-babel-get-src-block-info))
          (body (nth 1 info)))
     (j/tmux-run body t))))

(after! persp-mode
  (setq j/tmux-sessions '()
        j/tmux-history '())
  (map! :leader
        (:prefix ("e" . "tmux")
         :desc "select-session"      "s" #'j/tmux-select-session
         :desc "tmux-send-region"    "r" #'j/tmux-send-region
         :desc "tmux-send-paragraph" "p" #'j/tmux-send-paragraph
         :desc "tmux-send-src-block" "e" #'j/tmux-send-src-block)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  VTerm
;;  - Create evil vterm state
;;  - Map extra C-c * keys
;;  - Create evil-vterm-state to make sure I'm always in the right mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun vterm-send-esc ()
  (interactive)
  (vterm-send "ESC"))

(defun vterm-send-colon ()
  (interactive)
  (vterm-send ":"))

(defun vterm-exit ()
  (interactive)
  (evil-normal-state))

(defun vterm-enter (&rest _)
  (interactive)
  (evil-vterm-state))

(defun vterm-quit ()
  (interactive)
  (evil-window-mru)
  (vterm-exit))

(after! evil
  (map! "C-`" #'+vterm/toggle))

(after! vterm
  (map!
    :map vterm-mode-map
    "C-c <escape>" #'vterm-exit
    "C-c q"        #'vterm-quit
    "C-c x"        #'vterm-send-C-x
    "C-c C-d"      #'vterm-send-C-d
    "C-c :"        #'vterm-send-colon
    "C-h"          #'vterm-send-C-h
    "C-u"          #'vterm-send-C-u
    "C-]"          (cmd!! #'vterm-send-key "^]" t nil t)
    "C-^"          (cmd!! #'vterm-send-key "^" t nil t)))

(defun vterm-buffer-change ()
  (when (derived-mode-p 'vterm-mode)
    (vterm-enter)))

(defadvice! j/vterm-project-root (toggle-vterm arg)
  "Change vterm directory project root"
  :around #'+vterm/toggle
  (let* ((default-directory (or (doom-project-root)
                              default-directory)))
    (funcall toggle-vterm arg)))

(after! vterm
  (evil-define-state vterm
    "Evil vterm state.
    Used to signify when in vterm mode"
    :tag " <T> "
    :suppress-keymap t)
  (map-keymap
    (lambda (key cmd) (define-key evil-vterm-state-map (vector key) cmd))
    vterm-mode-map)
  (add-hook! 'buffer-list-update-hook #'vterm-buffer-change)
  (add-hook! 'evil-insert-state-entry-hook #'vterm-buffer-change)
  (evil-set-initial-state 'vterm-mode 'vterm))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SQL Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(comment
 (add-hook 'sql-mode-hook '(lambda () (sqlind-minor-mode 1))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org Mode, Agenda, and notes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! org
  (setq
   diary-file                            (concat org-directory "/diary")
   org-agenda-include-diary              nil
   org-agenda-file-regexp                "\\`[^.].*\\.org'\\|[0-9]+\\.org$"
   org-agenda-timegrid-use-ampm          t
   org-journal-dir                       (concat org-directory "/journal")
   org-journal-enable-agenda-integration nil
   org-journal-file-format               "%Y%m%d.org"
   org-journal-time-format               "%-l:%M%#p"
   org-journal-carryover-items           "TODO=\"TODO\"|TODO=\"STRT\"|TODO=\"HOLD\"")
  (setq! org-agenda-files (list org-journal-dir))

  (require 'ox-gfm nil t)

  (comment
   (advice-remove #'org-src--edit-element #'+org-inhibit-mode-hooks-a)))

(after! evil-org
  (remove-hook 'org-tab-first-hook #'+org-cycle-only-current-subtree-h))


(defadvice! j/log-dates (&rest _)
  "Log journal dates"
  :after #'org-journal-open-entry
  (let ((calendar-date (if (org-journal-daily-p)
                           (org-journal-file-name->calendar-date (file-truename (buffer-file-name)))
                         (while (org-up-heading-safe))
                         (org-journal-entry-date->calendar-date)))
         (dates (org-journal-list-dates)))
    (setq dates (cl-loop
                  for date in dates
                  while (calendar-date-compare (list date) (list calendar-date))
                  collect date into result and count t into cnt
                  finally return (if result
                                        ;; Front
                                        `(,@result ,calendar-date)
                                      ;; Somewhere enbetween or end of dates
                                      `(,calendar-date ,@result ,@(nthcdr cnt dates)))))
    (message "dates %s" dates)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org Roam
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package! org-roam
      :hook
      (after-init . org-roam-mode)
      :custom
      (org-roam-directory org-directory)
      (org-roam-tag-sources '(prop all-directories))
      (org-roam-capture-templates
       (list
        '("d" "default" plain (function org-roam--capture-get-point)
          "%?"
          :file-name "${dir}%<%Y%m%d%H%M%S>-${slug}"
          :head "#+title: ${title}\n"
          :unnarrowed t)))
      :bind (:map org-roam-mode-map
              (("C-c n l" . org-roam)
               ("C-c n f" . org-roam-find-file)
               ("C-c n g" . org-roam-graph))
              :map org-mode-map
              (("C-c n i" . org-roam-insert))
              (("C-c n I" . org-roam-insert-immediate))))

(defadvice! j/org-roam-capture (&optional goto keys)
  "Launches an `org-capture` process for a new existing note.
This uses the templates defined at `org-roam-capture-templates`.
Arguments GOTO and KEYS see `org-capture`."
  :override #'org-roam-capture
  (interactive "P")
  (unless org-roam-mode (org-roam-mode))
  (let* ((completions (org-roam--get-title-path-completions))
         (title-with-keys (org-roam-completion--completing-read "File: "
                                                                completions))
         (res (cdr (assoc title-with-keys completions)))
         (title (or (plist-get res :title) title-with-keys))
         (tags (split-string title "/"))
         (title (car (last tags)))
         (dir (string-join (butlast tags) "/"))
         (dir (if (string-blank-p dir) "" (concat dir "/")))
         (file-path (plist-get res :path)))
    (let ((org-roam-capture--info (list (cons 'title title)
                                        (cons 'slug (funcall org-roam-title-to-slug-function title))
                                        (cons 'file file-path)
                                        (cons 'dir dir)))
          (org-roam-capture--context 'capture))
      (condition-case err
          (org-roam-capture--capture goto keys)
        (error (user-error "%s.  Please adjust `org-roam-capture-templates'"
                           (error-message-string err)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org-Roam Server
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package org-roam-server
  :ensure t
  :config
  (setq org-roam-server-host "127.0.0.1"
        org-roam-server-port 8989
        org-roam-server-authenticate nil
        org-roam-server-export-inline-images t
        org-roam-server-serve-files nil
        org-roam-server-served-file-extensions '("pdf" "mp4" "ogv")
        org-roam-server-network-poll t
        org-roam-server-network-arrows nil
        org-roam-server-network-label-truncate t
        org-roam-server-network-label-truncate-length 60
        org-roam-server-network-label-wrap-length 20))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tmux Pane
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package! tmux-pane
  :config
  (tmux-pane-mode)
  (map! :leader
        (:prefix ("v" . "tmux pane")
          :desc "Open vpane" :nv "o" #'tmux-pane-open-vertical
          :desc "Open hpane" :nv "h" #'tmux-pane-open-horizontal
          :desc "Open hpane" :nv "s" #'tmux-pane-open-horizontal
          :desc "Open vpane" :nv "v" #'tmux-pane-open-vertical
          :desc "Close pane" :nv "c" #'tmux-pane-close
          :desc "Rerun last command" :nv "r" #'tmux-pane-rerun))
  (map! :leader
        (:prefix "t"
          :desc "vpane" :nv "v" #'tmux-pane-toggle-vertical
          :desc "hpane" :nv "h" #'tmux-pane-toggle-horizontal)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clipboard behavior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq save-interprogram-paste-before-kill t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Append to safe var list for dir-locals
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq! enable-local-variables :all)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load an optional local file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load! "local.el" nil t)
