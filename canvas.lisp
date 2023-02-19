(in-package #:calm)

;; change this to suit yourself
(defparameter *board-items* '("A" "B" "C" "D" "E"))


(unless (str:starts-with? "dist" (uiop:getenv "CALM_CMD"))
  (swank:create-server))

(setf *calm-window-flags* '(:shown :allow-highdpi :always-on-top))
(setf *calm-window-height* 100)

(defun calculate-calm-width ()
  (setf *calm-window-width* (* *calm-window-height* (length *board-items*))))

(calculate-calm-width)


(defparameter *calm-window-title* "Score Board")

(defparameter *board-colors*
  (list
   (list (/ 41 255) (/ 52 255) (/ 98 255))
   (list (/ 214 255) (/ 28 255) (/ 78 255))
   (list (/ 63 255) (/ 167 255) (/ 150 255))
   (list (/ 88 255) (/ 0 255) (/ 255 255))
   (list (/ 245 255) (/ 55 255) (/ 236 255))
   (list 1 0 0)
   (list 1 1 0)
   (list 1 1 1)
   (list 0 0 0)))

(defparameter *board-scores*
  (list 0 0 0 0 0 0 0 0 0 0))

(defun incf-score (n &optional (delta 1))
  (incf (nth n *board-scores*) delta)
  (with-open-file (s (str:concat (uiop:getenv "APP_DIR") "score.log")
                     :direction :output
                     :if-exists :append
                     :if-does-not-exist :create)
    (format s "~A: ~A~%" (get-universal-time) *board-scores*)))

(defun draw-button (x y w h callback)
  (c:save)
  (c:rectangle x y w h)
  (when
      (and (c:in-fill *calm-state-mouse-x* *calm-state-mouse-y*) *calm-state-mouse-up* callback)
    (funcall callback))
  (c:fill-path)
  (c:restore))

(defun draw()
  (c:move-to 10 10)

  (loop for item in *board-items*
        for i from 0 to (length *board-items*)
        for x = (* i 100)
        do
           (apply #'c:set-source-rgb (nth i *board-colors*))
           (draw-button x 0 100 100
                        (lambda ()
                          (cond
                            ((= *calm-state-mouse-up* 1) (incf-score i))
                            ((= *calm-state-mouse-up* 3) (incf-score i -1)))))
           (c:set-source-rgb 1 1 1)
           (c:select-font-face "Courier New" :normal :normal)
           (c:set-font-size 30)
           (c:move-to (+ x 40) 28)
           (c:show-text item)
           (c:set-font-size 60)
           (c:move-to (+ x 12) 85)
           (c:show-text (format nil "~2,'0d" (nth i *board-scores*)))
        )

  (setf  *calm-state-mouse-up* nil
         *calm-state-mouse-down* nil))
