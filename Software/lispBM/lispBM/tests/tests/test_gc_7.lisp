
(define tree '(((1 . 2) . (3 . 4)) . ((5 . 6) . (7 . 8 ))))
(define tree2 (cons tree tree))
(define tree3 (cons tree2 tree2))

(gc)

(check (and
        (eq tree '(((1 . 2) . (3 . 4)) . ((5 . 6) . (7 . 8 ))))
        (eq (car tree2) '(((1 . 2) . (3 . 4)) . ((5 . 6) . (7 . 8 ))))
        (eq (cdr tree2) '(((1 . 2) . (3 . 4)) . ((5 . 6) . (7 . 8 ))))
        (eq (car (car tree3)) '(((1 . 2) . (3 . 4)) . ((5 . 6) . (7 . 8 ))))
        (eq (car (cdr tree3)) '(((1 . 2) . (3 . 4)) . ((5 . 6) . (7 . 8 ))))
        (eq (cdr (car tree3)) '(((1 . 2) . (3 . 4)) . ((5 . 6) . (7 . 8 ))))
        (eq (cdr (cdr tree3)) '(((1 . 2) . (3 . 4)) . ((5 . 6) . (7 . 8 ))))))
        

