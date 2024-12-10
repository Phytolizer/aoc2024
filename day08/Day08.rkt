#lang racket
(require racket/generator)

(define (node-dist a b)
  (vector-map - b a))

(define (node-add a b)
  (vector-map + a b))

(define (bounded? x a b)
  (and (>= x a)
       (< x b)))

(define (antenna? b)
  (let* ([bs (make-bytes 1 b)]
         [s (bytes->string/latin-1 bs (integer->char #xFFFD))]
         [ch (string-ref s 0)])
    (or (char-alphabetic? ch) (char-numeric? ch))))

(define (node-bounded? n data)
  (and
   (bounded? (vector-ref n 0) 0 (vector-length data))
   (bounded? (vector-ref n 1) 0 (bytes-length (vector-ref data 0)))))

(define (antinodes1 src dst data)
  ;; Follow `dir` exactly once.
  (let* ([dir (node-dist src dst)]
         [antinode (node-add dst dir)])
    (in-generator
     (when (node-bounded? antinode data)
       (yield antinode)))))

(define (antinodes2 src dst data)
  ;; Follow `dir` infinitely.
  (let ([dir (node-dist src dst)])
    (in-generator
     (let loop ([antinode dst])
       (when (node-bounded? antinode data)
         (yield antinode)
         (loop (node-add antinode dir)))))))

(define (node-ref data n)
  (bytes-ref
   (vector-ref data (vector-ref n 0))
   (vector-ref n 1)))

(define (map-indices data)
  (for*/list ([y (in-range (vector-length data))]
              [x (in-range (bytes-length (vector-ref data 0)))])
    (vector y x)))

(define (unique-antinodes data antinodes)
  (let* ([antennae
          (filter
           (lambda (coord) (antenna? (node-ref data coord)))
           (map-indices data))]
         [antinodes
          (for*/set
              ([src-antenna antennae]
               [dst-antenna antennae]
               [antinode
                (if (and
                     (not (equal? src-antenna dst-antenna))
                     (equal?
                      (node-ref data src-antenna)
                      (node-ref data dst-antenna)))
                    (antinodes src-antenna dst-antenna data)
                    empty-sequence)])
            antinode)])
    (set-count antinodes)))

(let* ([data (list->vector (port->bytes-lines (current-input-port)))]
       [part1 (unique-antinodes data antinodes1)]
       [part2 (unique-antinodes data antinodes2)])
  (printf "Part 1: ~a~n" part1)
  (printf "Part 2: ~a~n" part2))
