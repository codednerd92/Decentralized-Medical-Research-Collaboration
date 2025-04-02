;; Contribution Tracking Contract
;; Records inputs from various researchers

(define-data-var admin principal tx-sender)

;; Structure for research contributions
(define-map contributions uint
  {
    project-id: uint,
    contributor: principal,
    contribution-type: (string-ascii 50),
    description: (string-ascii 500),
    timestamp: uint,
    verified: bool
  }
)

;; Map of projects
(define-map projects uint
  {
    name: (string-ascii 100),
    lead-institution: principal,
    created-at: uint,
    status: (string-ascii 20)
  }
)

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

;; Counters
(define-data-var contribution-id-counter uint u0)
(define-data-var project-id-counter uint u0)

;; Public function to create a new project
(define-public (create-project (name (string-ascii 100)))
  (let
    (
      (caller tx-sender)
      (current-id (var-get project-id-counter))
    )
    ;; Check if caller is a verified institution
    (asserts! (default-to false (map-get? verified-institutions caller)) (err u401))

    ;; Create the project
    (map-set projects current-id
      {
        name: name,
        lead-institution: caller,
        created-at: block-height,
        status: "active"
      }
    )

    ;; Increment the counter
    (var-set project-id-counter (+ current-id u1))

    (ok current-id)
  )
)

;; Public function to record a contribution
(define-public (record-contribution
  (project-id uint)
  (contribution-type (string-ascii 50))
  (description (string-ascii 500)))
  (let
    (
      (caller tx-sender)
      (current-id (var-get contribution-id-counter))
      (project (unwrap! (map-get? projects project-id) (err u404)))
    )
    ;; Check if caller is a verified institution
    (asserts! (default-to false (map-get? verified-institutions caller)) (err u401))

    ;; Record the contribution
    (map-set contributions current-id
      {
        project-id: project-id,
        contributor: caller,
        contribution-type: contribution-type,
        description: description,
        timestamp: block-height,
        verified: false
      }
    )

    ;; Increment the counter
    (var-set contribution-id-counter (+ current-id u1))

    (ok current-id)
  )
)

;; Public function to verify a contribution (only project lead can do this)
(define-public (verify-contribution (contribution-id uint))
  (let
    (
      (caller tx-sender)
      (contribution (unwrap! (map-get? contributions contribution-id) (err u404)))
      (project (unwrap! (map-get? projects (get project-id contribution)) (err u404)))
    )
    ;; Check if caller is the project lead
    (asserts! (is-eq caller (get lead-institution project)) (err u403))

    ;; Update the contribution
    (map-set contributions contribution-id
      (merge contribution { verified: true })
    )

    (ok true)
  )
)

;; Read-only function to get project details
(define-read-only (get-project-details (project-id uint))
  (map-get? projects project-id)
)

;; Read-only function to get contribution details
(define-read-only (get-contribution-details (contribution-id uint))
  (map-get? contributions contribution-id)
)

