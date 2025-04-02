;; Institution Verification Contract
;; This contract validates legitimate research entities

(define-data-var admin principal tx-sender)

;; Map to store verified institutions
(define-map verified-institutions principal
  {
    name: (string-ascii 100),
    verification-date: uint,
    status: (string-ascii 20)
  }
)

;; Public function to verify an institution
(define-public (verify-institution (institution principal) (name (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-set verified-institutions institution
      {
        name: name,
        verification-date: block-height,
        status: "verified"
      }
    )
    (ok true)
  )
)

;; Public function to revoke verification
(define-public (revoke-verification (institution principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-delete verified-institutions institution)
    (ok true)
  )
)

;; Read-only function to check if an institution is verified
(define-read-only (is-verified (institution principal))
  (is-some (map-get? verified-institutions institution))
)

;; Read-only function to get institution details
(define-read-only (get-institution-details (institution principal))
  (map-get? verified-institutions institution)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)

