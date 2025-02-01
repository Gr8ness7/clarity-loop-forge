;; IoT Data Registry Contract

;; Constants
(define-constant err-invalid-signature (err u200))

;; Data structures
(define-map data-records
  { device-id: (string-ascii 64), timestamp: uint }
  { data-hash: (buff 32), signature: (buff 65) }
)

;; Public functions
(define-public (store-data (device-id (string-ascii 64)) (data-hash (buff 32)) (signature (buff 65)))
  (let ((timestamp block-height))
    (asserts! (verify-signature device-id data-hash signature) err-invalid-signature)
    (map-set data-records
      {device-id: device-id, timestamp: timestamp}
      {data-hash: data-hash, signature: signature}
    )
    (ok timestamp)
  )
)

;; Read only functions
(define-read-only (get-data-record (device-id (string-ascii 64)) (timestamp uint))
  (ok (map-get? data-records {device-id: device-id, timestamp: timestamp}))
)
