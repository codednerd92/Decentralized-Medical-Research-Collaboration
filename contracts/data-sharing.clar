;; Data Sharing Contract
;; Manages secure exchange of research information

(define-data-var admin principal tx-sender)

;; Structure for research data
(define-map research-data uint
  {
    owner: principal,
    title: (string-ascii 100),
    data-hash: (buff 32),
    timestamp: uint,
    access-control: (list 10 principal)
  }
)

;; Counter for data IDs
(define-data-var data-id-counter uint u0)

;; Map to track verified institutions (simplified approach)
(define-map verified-institutions principal bool)

;; Public function to verify an institution (admin only)
;; In a real system, this would reference the institution-verification contract
(define-public (verify-institution (institution principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-set verified-institutions institution true)
    (ok true)
  )
)

;; Public function to share research data
(define-public (share-data (title (string-ascii 100)) (data-hash (buff 32)) (access-list (list 10 principal)))
  (let
    (
      (caller tx-sender)
      (current-id (var-get data-id-counter))
    )
    ;; Check if caller is a verified institution
    (asserts! (default-to false (map-get? verified-institutions caller)) (err u401))

    ;; Store the data
    (map-set research-data current-id
      {
        owner: caller,
        title: title,
        data-hash: data-hash,
        timestamp: block-height,
        access-control: access-list
      }
    )

    ;; Increment the counter
    (var-set data-id-counter (+ current-id u1))

    (ok current-id)
  )
)

;; Public function to update access control
(define-public (update-access (data-id uint) (new-access-list (list 10 principal)))
  (let
    (
      (data (unwrap! (map-get? research-data data-id) (err u404)))
    )
    ;; Check if caller is the owner
    (asserts! (is-eq tx-sender (get owner data)) (err u403))

    ;; Update access control
    (map-set research-data data-id
      (merge data { access-control: new-access-list })
    )

    (ok true)
  )
)

;; Read-only function to check if a principal has access to data
(define-read-only (has-access (data-id uint) (user principal))
  (let
    (
      (data (unwrap! (map-get? research-data data-id) false))
    )
    (or
      (is-eq user (get owner data))
      (is-some (index-of (get access-control data) user))
    )
  )
)

;; Read-only function to get data details (if user has access)
(define-read-only (get-data-details (data-id uint))
  (let
    (
      (data (unwrap! (map-get? research-data data-id) none))
    )
    (if (has-access data-id tx-sender)
      (some data)
      none
    )
  )
)

