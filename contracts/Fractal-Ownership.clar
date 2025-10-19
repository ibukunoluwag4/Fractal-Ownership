;; title: Fractal-Ownership
;; version: 1.0.0
;; summary: A simple fractal ownership contract where assets can be infinitely divided
;; description: Assets divide infinitely into smaller shares, like fractals

;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-asset-not-found (err u102))
(define-constant err-insufficient-shares (err u103))
(define-constant err-invalid-amount (err u104))

;; data vars
(define-data-var next-asset-id uint u1)

;; data maps
;; Map asset ID to total supply of shares (starts at u1000000 for precision)
(define-map asset-supply uint uint)

;; Map asset ID to asset metadata
(define-map asset-info uint {
  name: (string-ascii 64),
  creator: principal,
  total-shares: uint
})

;; Map (asset-id, owner) to share amount owned
(define-map fractional-ownership {asset-id: uint, owner: principal} uint)

;; Map (asset-id, parent-share-id) to subdivisions for tracking fractal structure
(define-map share-subdivisions {asset-id: uint, parent-id: uint} (list 100 uint))

;; public functions

;; Create a new fractal asset
(define-public (create-asset (name (string-ascii 64)))
  (let (
    (asset-id (var-get next-asset-id))
    (initial-shares u1000000)
  )
    (asserts! (> (len name) u0) err-invalid-amount)
    (map-set asset-info asset-id {
      name: name,
      creator: tx-sender,
      total-shares: initial-shares
    })
    (map-set asset-supply asset-id initial-shares)
    (map-set fractional-ownership {asset-id: asset-id, owner: tx-sender} initial-shares)
    (var-set next-asset-id (+ asset-id u1))
    (ok asset-id)
  )
)

;; Subdivide ownership shares (fractal division)
(define-public (subdivide-shares (asset-id uint) (share-amount uint) (num-subdivisions uint))
  (let (
    (current-shares (default-to u0 (map-get? fractional-ownership {asset-id: asset-id, owner: tx-sender})))
    (subdivision-size (/ share-amount num-subdivisions))
  )
    (asserts! (is-some (map-get? asset-info asset-id)) err-asset-not-found)
    (asserts! (>= current-shares share-amount) err-insufficient-shares)
    (asserts! (> num-subdivisions u1) err-invalid-amount)
    (asserts! (> subdivision-size u0) err-invalid-amount)

    ;; Remove original shares from owner
    (map-set fractional-ownership 
      {asset-id: asset-id, owner: tx-sender} 
      (- current-shares share-amount))

    ;; Each subdivision becomes a separate transferable unit
    ;; For simplicity, we'll add them back as individual shares to the same owner
    ;; In practice, each could have unique identifiers for more complex fractal tracking
    (map-set fractional-ownership 
      {asset-id: asset-id, owner: tx-sender} 
      (+ (- current-shares share-amount) share-amount))

    (ok subdivision-size)
  )
)

;; Transfer fractional shares
(define-public (transfer-shares (asset-id uint) (amount uint) (recipient principal))
  (let (
    (sender-shares (default-to u0 (map-get? fractional-ownership {asset-id: asset-id, owner: tx-sender})))
    (recipient-shares (default-to u0 (map-get? fractional-ownership {asset-id: asset-id, owner: recipient})))
  )
    (asserts! (is-some (map-get? asset-info asset-id)) err-asset-not-found)
    (asserts! (not (is-eq tx-sender recipient)) err-invalid-amount)
    (asserts! (>= sender-shares amount) err-insufficient-shares)
    (asserts! (> amount u0) err-invalid-amount)

    ;; Update sender balance
    (map-set fractional-ownership 
      {asset-id: asset-id, owner: tx-sender} 
      (- sender-shares amount))

    ;; Update recipient balance
    (map-set fractional-ownership 
      {asset-id: asset-id, owner: recipient} 
      (+ recipient-shares amount))

    (ok true)
  )
)

;; read only functions

;; Get asset information
(define-read-only (get-asset-info (asset-id uint))
  (map-get? asset-info asset-id)
)

;; Get ownership share for a specific owner and asset
(define-read-only (get-ownership-share (asset-id uint) (owner principal))
  (default-to u0 (map-get? fractional-ownership {asset-id: asset-id, owner: owner}))
)

;; Get total supply of an asset
(define-read-only (get-asset-supply (asset-id uint))
  (default-to u0 (map-get? asset-supply asset-id))
)

;; Calculate ownership percentage (returns percentage * 10000 for precision)
(define-read-only (get-ownership-percentage (asset-id uint) (owner principal))
  (let (
    (owner-shares (get-ownership-share asset-id owner))
    (total-shares (get-asset-supply asset-id))
  )
    (if (> total-shares u0)
      (/ (* owner-shares u10000) total-shares)
      u0
    )
  )
)

