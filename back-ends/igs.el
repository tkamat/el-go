;;; igs.el --- IGS GO back-end

;; Copyright (C) 2012 Eric Schulte <eric.schulte@gmx.com>

;; Author: Eric Schulte <eric.schulte@gmx.com>
;; Created: 2012-05-15
;; Version: 0.1
;; Keywords: game go sgf

;; This file is not (yet) part of GNU Emacs.
;; However, it is distributed under the same license.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;; Commentary:

;; http://www.pandanet.co.jp/English/commands/term/Summary.html

;; Code:
(require 'go)

(defvar igs-telnet-command "telnet"
  "Telnet command used by igs.")

(defvar igs-server "igs.joyjoy.net"
  "Address of the IGS server.")

(defvar igs-port 6969
  "Port to use when connecting to an IGS server.")

(defvar igs-message-types
  '((:unknown   . 0)
    (:AUTOMAT   . 35)   ;; Automatch announcement
    (:AUTOASK   . 36)   ;; Automatch accept
    (:CHOICES   . 38)   ;; game choices
    (:CLIVRFY   . 41)   ;; Client verify message
    (:BEEP      . 2)    ;; \7 telnet
    (:BOARD     . 3)    ;; Board being drawn
    (:DOWN      . 4)    ;; The server is going down
    (:ERROR     . 5)    ;; An error reported
    (:FIL       . 6)    ;; File being sent
    (:GAMES     . 7)    ;; Games listing
    (:HELP      . 8)    ;; Help file
    (:INFO      . 9)    ;; Generic info
    (:LAST      . 10)   ;; Last command
    (:KIBITZ    . 11)   ;; Kibitz strings
    (:LOAD      . 12)   ;; Loading a game
    (:LOOK_M    . 13)   ;; Look
    (:MESSAGE   . 14)   ;; Message listing
    (:MOVE      . 15)   ;; Move #:(B) A1
    (:OBSERVE   . 16)   ;; Observe report
    (:PROMPT    . 1)    ;; A Prompt (never)
    (:REFRESH   . 17)   ;; Refresh of a board
    (:SAVED     . 18)   ;; Stored command
    (:SAY       . 19)   ;; Say string
    (:SCORE_M   . 20)   ;; Score report
    (:SGF_M     . 34)   ;; SGF variation
    (:SHOUT     . 21)   ;; Shout string
    (:SHOW      . 29)   ;; Shout string
    (:STATUS    . 22)   ;; Current Game status
    (:STORED    . 23)   ;; Stored games
    (:TEACH     . 33)   ;; teaching game
    (:TELL      . 24)   ;; Tell string
    (:DOT       . 40)   ;; your . string
    (:THIST     . 25)   ;; Thist report
    (:TIM       . 26)   ;; times command
    (:TRANS     . 30)   ;; Translation info
    (:TTT_BOARD . 37)   ;; tic tac toe
    (:WHO       . 27)   ;; who command
    (:UNDO      . 28)   ;; Undo report
    (:USER      . 42)   ;; Long user report
    (:VERSION   . 39)   ;; IGS Version
    (:YELL      . 32))) ;; Channel yelling


(defvar igs-process-name "igs"
  "Name for the igs process.")

(defun igs-connect ()
  "Open a connection to `igs-server'."
  (interactive)
  (let ((buffer (apply 'make-comint
                       igs-process-name
                       igs-telnet-command nil
                       (list igs-server (number-to-string igs-port)))))
    (with-current-buffer buffer (comint-mode))
    buffer))

(defun igs-wait-for-output (igs)
  (with-current-buffer (buffer igs)
    (while  (progn
	     (goto-char comint-last-input-end)
	     (not (re-search-forward "^\#> " nil t)))
      (accept-process-output (get-buffer-process (current-buffer))))))

(defun igs-last-output (igs)
  (with-current-buffer (buffer igs)
    (comint-show-output)
    (org-babel-clean-text-properties
     (buffer-substring (+ 2 (point)) (- (point-max) 2)))))

(defun igs-command-to-string (igs command)
  "Send command to an igs connection and return the results as a string"
  (interactive "sigs command: ")
  (with-current-buffer (buffer igs)
    (goto-char (process-mark (get-buffer-process (current-buffer))))
    (insert command)
    (comint-send-input))
  (igs-wait-for-output igs)
  (igs-last-output igs))

(defvar igs-player-re
  "\\([[:alpha:][:digit:]]+\\) +\\[ *\\([[:digit:]]+[kd]\\*\\)\\]"
  "Regular expression used to parse igs player name and rating.")

(defvar igs-game-re
  (format "\\[\\([[:digit:]]+\\)\\] +%s +vs. +%s +\\((.+)\\) \\((.+)\\)$"
          igs-player-re igs-player-re)
  "Regular expression used to parse igs game listings.")

(defun igs-parse-game-string (game-string)
  ;; [##] white name [ rk ] black name [ rk ] (Move size H Komi BY FR) (###)
  (when (string-match igs-game-re game-string)
    (let* ((num        (match-string 1 game-string))
           (white-name (match-string 2 game-string))
           (white-rank (match-string 3 game-string))
           (black-name (match-string 4 game-string))
           (black-rank (match-string 5 game-string))
           (other1     (read (match-string 6 game-string)))
           (other2     (read (match-string 7 game-string))))
      `((:number     . ,(read num))
        (:white-name . ,white-name)
        (:white-rank . ,white-rank)
        (:black-name . ,black-name)
        (:black-rank . ,black-rank)
        (:move       . ,(nth 0 other1))
        (:size       . ,(nth 1 other1))
        (:h          . ,(nth 2 other1))
        (:komi       . ,(nth 3 other1))
        (:by         . ,(nth 4 other1))
        (:fr         . ,(nth 5 other1))
        (:other      . ,(car other2))))))

(defun igs-games (igs)
  (let ((games-str (igs-command-to-string igs "games")))
    (delete nil
            (mapcar #'igs-parse-game-string
                    (cdr (split-string games-str "[\n\r]"))))))


;;; Class and interface
(defclass igs ()
  ((buffer :initarg :buffer :accessor buffer :initform nil)))

(provide 'igs)