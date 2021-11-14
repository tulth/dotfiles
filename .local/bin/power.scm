#!/usr/bin/guile \
-e main -s
!#
(use-modules (ice-9 format))
(use-modules (ice-9 textual-ports))

(define (rd-sys f)
  (string-trim-both
   (call-with-input-file f get-string-all)))

(define BAT1
  "/sys/class/power_supply/BAT1/")

(define ACAD
  "/sys/class/power_supply/ACAD/")

(define (current)
  (* 1e-6
     (string->number
      (rd-sys (string-append BAT1 "current_now")))))

(define (voltage)
  (* 1e-6
     (string->number
      (rd-sys (string-append BAT1 "voltage_now")))))

(define (power)
  (* (voltage) (current)))

(define (power-rounded-str)
  (format #f "~,1f" (power)))

(define (capacity)
  (rd-sys (string-append BAT1 "capacity")))

(define (on-ac)
  (string=? "1"
            (rd-sys (string-append ACAD "online"))))

(define (main args)
  (display (if (on-ac)
               "<fc=#FFEA33>⚡</fc>" "" ))
  (display (power-rounded-str))
  (display "W")
  (display " ")
  (display (capacity))
  (display "%")
  (newline))

