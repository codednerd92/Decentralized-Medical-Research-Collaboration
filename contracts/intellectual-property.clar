;; Intellectual Property Contract
;; Manages rights to discoveries and innovations

(define-data-var admin principal tx-sender)

;; Structure for intellectual property records
(define-map ip-records uint
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    ip-type: (string-ascii 50),
    creation-date: uint,
    project-id: uint,
    status: (string-ascii 20)
  }
)

;; Structure for IP ownership
(define-map ip-ownership (tuple (ip-id uint) (institution principal))
  {
    share: uint
  }
)

;; Map to track verified institutions (simplified approach)
(define-map verified-institutions principal bool)

;; Map to track projects (simplified approach)
(define-map projects uint
  {
    lead-institution: principal
  }
)

;; Public function to verify an institution (admin only)
(define-public (verify-institution (institution principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-set verified-institutions institution true)
    (ok true)
  )
)

;; Public function to register a project (simplified)
(define-public (register-project (project-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-set projects project-id { lead-institution: tx-sender })
    (ok true)
  )
)

;; Counter for IP IDs
(define-data-var ip-id-counter uint u0)

;; Public function to register new intellectual property
(define-public (register-ip
  (title (string-ascii 100))
  (description (string-ascii 500))
  (ip-type (string-ascii 50))
  (project-id uint))
  (let
    (
      (caller tx-sender)
      (current-id (var-get ip-id-counter))
      (project (unwrap! (map-get? projects project-id) (err u404)))
    )
    ;; Check if caller is a verified institution and the project lead
    (asserts! (default-to false (map-get? verified-institutions caller)) (err u401))
    (asserts! (is-eq caller (get lead-institution project)) (err u403))

    ;; Register the IP
    (map-set ip-records current-id
      {
        title: title,
        description: description,
        ip-type: ip-type,
        creation-date: block-height,
        project-id: project-id,
        status: "active"
      }
    )

    ;; Set initial ownership (100% to the registering institution)
    (map-set ip-ownership {ip-id: current-id, institution: caller}
      {
        share: u100
      }
    )

    ;; Increment the counter
    (var-set ip-id-counter (+ current-id u1))

    (ok current-id)
  )
)

;; Public function to transfer IP ownership shares
(define-public (transfer-ip-share
  (ip-id uint)
  (to-institution principal)
  (share-amount uint))
  (let
    (
      (caller tx-sender)
      (from-share (default-to u0 (get share (map-get? ip-ownership {ip-id: ip-id, institution: caller}))))
      (to-share (default-to u0 (get share (map-get? ip-ownership {ip-id: ip-id, institution: to-institution}))))
    )
    ;; Check if caller has enough share
    (asserts! (>= from-share share-amount) (err u400))

    ;; Update the shares
    (map-set ip-ownership {ip-id: ip-id, institution: caller}
      {
        share: (- from-share share-amount)
      }
    )

    (map-set ip-ownership {ip-id: ip-id, institution: to-institution}
      {
        share: (+ to-share share-amount)
      }
    )

    (ok true)
  )
)

;; Read-only function to get IP record details
(define-read-only (get-ip-details (ip-id uint))
  (map-get? ip-records ip-id)
)

;; Read-only function to get an institution's share of an IP
(define-read-only (get-ip-share (ip-id uint) (institution principal))
  (default-to u0 (get share (map-get? ip-ownership {ip-id: ip-id, institution: institution})))
)

