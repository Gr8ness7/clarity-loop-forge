;; LoopForge Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-owner (err u102))
(define-constant err-invalid-input (err u103))
(define-constant err-device-inactive (err u104))
(define-constant registration-fee u1000)

;; Data structures
(define-map devices 
  { device-id: (string-ascii 64) }
  { owner: principal, active: bool, registration-time: uint }
)

(define-map device-metadata
  { device-id: (string-ascii 64) }
  { name: (string-ascii 64), description: (string-utf8 256) }
)

;; Private functions
(define-private (validate-input (device-id (string-ascii 64)) (name (string-ascii 64)))
  (and (> (len device-id) u0) (> (len name) u0))
)

;; Public functions
(define-public (register-device (device-id (string-ascii 64)) (name (string-ascii 64)) (description (string-utf8 256)))
  (let ((caller tx-sender))
    (asserts! (validate-input device-id name) err-invalid-input)
    (asserts! (not (default-to false (get active (map-get? devices {device-id: device-id})))) err-already-registered)
    (try! (stx-transfer? registration-fee caller (as-contract tx-sender)))
    (map-set devices
      {device-id: device-id}
      {owner: caller, active: true, registration-time: block-height}
    )
    (map-set device-metadata
      {device-id: device-id}
      {name: name, description: description}
    )
    (ok true)
  )
)

(define-public (transfer-device (device-id (string-ascii 64)) (new-owner principal))
  (let ((device (unwrap! (map-get? devices {device-id: device-id}) err-not-owner)))
    (asserts! (is-eq (get owner device) tx-sender) err-not-owner)
    (asserts! (get active device) err-device-inactive)
    (map-set devices
      {device-id: device-id}
      (merge device {owner: new-owner})
    )
    (ok true)
  )
)

(define-public (deactivate-device (device-id (string-ascii 64)))
  (let ((device (unwrap! (map-get? devices {device-id: device-id}) err-not-owner)))
    (asserts! (is-eq (get owner device) tx-sender) err-not-owner)
    (map-set devices
      {device-id: device-id}
      (merge device {active: false})
    )
    (ok true)
  )
)

(define-public (withdraw-fees)
  (let ((balance (stx-get-balance (as-contract tx-sender))))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (as-contract (stx-transfer? balance tx-sender contract-owner))
  )
)

;; Read only functions
(define-read-only (get-device-info (device-id (string-ascii 64)))
  (ok (map-get? devices {device-id: device-id}))
)

(define-read-only (get-device-metadata (device-id (string-ascii 64)))
  (ok (map-get? device-metadata {device-id: device-id}))
)
