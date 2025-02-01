;; LoopForge Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-owner (err u102))
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

;; Public functions
(define-public (register-device (device-id (string-ascii 64)) (name (string-ascii 64)) (description (string-utf8 256)))
  (let ((caller tx-sender))
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
    (map-set devices
      {device-id: device-id}
      (merge device {owner: new-owner})
    )
    (ok true)
  )
)

;; Read only functions
(define-read-only (get-device-info (device-id (string-ascii 64)))
  (ok (map-get? devices {device-id: device-id}))
)

(define-read-only (get-device-metadata (device-id (string-ascii 64)))
  (ok (map-get? device-metadata {device-id: device-id}))
)
