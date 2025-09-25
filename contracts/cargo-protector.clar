;; Marine Cargo Insurance Smart Contract - Cargo Protector
;; Insure maritime cargo, track shipping conditions, and process weather-related claims automatically

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u1))
(define-constant ERR_SHIPMENT_NOT_FOUND (err u2))
(define-constant ERR_POLICY_NOT_FOUND (err u3))
(define-constant ERR_INVALID_WEATHER_DATA (err u4))
(define-constant ERR_CLAIM_ALREADY_EXISTS (err u5))
(define-constant ERR_INSUFFICIENT_BALANCE (err u6))
(define-constant ERR_POLICY_EXPIRED (err u7))
(define-constant ERR_INVALID_COORDINATES (err u8))
(define-constant ERR_CLAIM_NOT_FOUND (err u9))
(define-constant ERR_POLICY_ALREADY_EXISTS (err u10))

;; Data Variables
(define-data-var next-shipment-id uint u1)
(define-data-var next-policy-id uint u1)
(define-data-var next-claim-id uint u1)
(define-data-var insurance-pool uint u10000000) ;; Initial pool of 10M STX
(define-data-var weather-oracle principal tx-sender)

;; Data Maps
(define-map CargoShipments
  { shipment-id: uint }
  {
    shipper: principal,
    cargo-type: (string-ascii 64),
    origin-port: (string-ascii 32),
    destination-port: (string-ascii 32),
    cargo-value: uint,
    departure-date: uint,
    expected-arrival: uint,
    current-latitude: int,
    current-longitude: int,
    shipping-vessel: (string-ascii 64),
    container-ids: (list 10 (string-ascii 32)),
    status: (string-ascii 16),
    last-update: uint
  }
)

(define-map InsurancePolicies
  { policy-id: uint }
  {
    shipment-id: uint,
    policyholder: principal,
    coverage-amount: uint,
    premium-paid: uint,
    policy-start: uint,
    policy-end: uint,
    risk-factors: (list 5 (string-ascii 32)),
    deductible: uint,
    weather-coverage: bool,
    theft-coverage: bool,
    damage-coverage: bool,
    delay-coverage: bool,
    status: (string-ascii 16)
  }
)

(define-map WeatherData
  { shipment-id: uint, timestamp: uint }
  {
    latitude: int,
    longitude: int,
    wind-speed: uint,
    wave-height: uint,
    storm-category: uint,
    temperature: int,
    visibility: uint,
    weather-condition: (string-ascii 32),
    risk-level: uint
  }
)

(define-map InsuranceClaims
  { claim-id: uint }
  {
    policy-id: uint,
    shipment-id: uint,
    claimant: principal,
    claim-type: (string-ascii 32),
    claim-amount: uint,
    incident-date: uint,
    incident-location: { latitude: int, longitude: int },
    weather-conditions: (string-ascii 64),
    damage-description: (string-ascii 256),
    supporting-evidence: (list 5 (string-ascii 128)),
    auto-approved: bool,
    claim-status: (string-ascii 16),
    settlement-amount: uint,
    processed-date: uint
  }
)

(define-map TrackingHistory
  { shipment-id: uint, sequence: uint }
  {
    timestamp: uint,
    latitude: int,
    longitude: int,
    port-name: (string-ascii 32),
    event-type: (string-ascii 32),
    notes: (string-ascii 128)
  }
)

(define-map RiskAssessment
  { shipment-id: uint }
  {
    route-risk-score: uint,
    seasonal-risk: uint,
    cargo-risk: uint,
    vessel-risk: uint,
    overall-risk: uint,
    premium-multiplier: uint,
    recommended-coverage: uint,
    assessment-date: uint
  }
)

;; Private Functions
(define-private (is-authorized (caller principal))
  (or (is-eq caller CONTRACT_OWNER)
      (is-eq caller (var-get weather-oracle))
      (is-some (map-get? InsurancePolicies { policy-id: (default-to u0 (get-policy-by-holder caller)) }))
  )
)

(define-private (get-policy-by-holder (holder principal))
  (fold check-policy-holder (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) none)
)

(define-private (check-policy-holder (id uint) (current (optional uint)))
  (if (is-some current)
    current
    (match (map-get? InsurancePolicies { policy-id: id })
      policy-data (if (is-eq (get policyholder policy-data) tx-sender)
                     (some id)
                     none)
      none
    )
  )
)

(define-private (calculate-premium (cargo-value uint) (risk-score uint))
  (let (
    (base-premium (/ (* cargo-value u3) u100)) ;; 3% base premium
    (risk-adjustment (/ (* base-premium risk-score) u100))
  )
    (+ base-premium risk-adjustment)
  )
)

(define-private (assess-weather-risk (wind-speed uint) (wave-height uint) (storm-category uint))
  (let (
    (wind-risk (if (>= wind-speed u40) u30 (if (>= wind-speed u25) u20 u10)))
    (wave-risk (if (>= wave-height u8) u25 (if (>= wave-height u4) u15 u5)))
    (storm-risk (* storm-category u20))
  )
    (+ wind-risk (+ wave-risk storm-risk))
  )
)

(define-private (is-weather-claim-valid (claim-type (string-ascii 32)) (wind-speed uint) (storm-category uint))
  (and 
    (is-eq claim-type "weather-damage")
    (or (>= wind-speed u35) (>= storm-category u3))
  )
)

(define-private (calculate-settlement (claim-amount uint) (deductible uint) (coverage-amount uint))
  (let (
    (adjusted-claim (if (>= claim-amount deductible) (- claim-amount deductible) u0))
    (settlement (if (<= adjusted-claim coverage-amount) adjusted-claim coverage-amount))
  )
    settlement
  )
)

;; Public Functions

;; Register Cargo Shipment
(define-public (register-shipment
  (cargo-type (string-ascii 64))
  (origin-port (string-ascii 32))
  (destination-port (string-ascii 32))
  (cargo-value uint)
  (departure-date uint)
  (expected-arrival uint)
  (shipping-vessel (string-ascii 64))
  (container-ids (list 10 (string-ascii 32)))
)
  (let (
    (shipment-id (var-get next-shipment-id))
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
  )
    (map-set CargoShipments
      { shipment-id: shipment-id }
      {
        shipper: tx-sender,
        cargo-type: cargo-type,
        origin-port: origin-port,
        destination-port: destination-port,
        cargo-value: cargo-value,
        departure-date: departure-date,
        expected-arrival: expected-arrival,
        current-latitude: 0,
        current-longitude: 0,
        shipping-vessel: shipping-vessel,
        container-ids: container-ids,
        status: "registered",
        last-update: current-time
      }
    )
    (var-set next-shipment-id (+ shipment-id u1))
    (ok shipment-id)
  )
)

;; Create Insurance Policy
(define-public (create-policy
  (shipment-id uint)
  (coverage-amount uint)
  (policy-duration uint)
  (risk-factors (list 5 (string-ascii 32)))
  (weather-coverage bool)
  (theft-coverage bool)
  (damage-coverage bool)
  (delay-coverage bool)
)
  (let (
    (policy-id (var-get next-policy-id))
    (shipment-data (unwrap! (map-get? CargoShipments { shipment-id: shipment-id }) ERR_SHIPMENT_NOT_FOUND))
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    (risk-score (calculate-risk-score risk-factors))
    (premium (calculate-premium coverage-amount risk-score))
    (deductible (/ coverage-amount u20)) ;; 5% deductible
  )
    (asserts! (is-eq tx-sender (get shipper shipment-data)) ERR_UNAUTHORIZED)
    (try! (stx-transfer? premium tx-sender (as-contract tx-sender)))
    (map-set InsurancePolicies
      { policy-id: policy-id }
      {
        shipment-id: shipment-id,
        policyholder: tx-sender,
        coverage-amount: coverage-amount,
        premium-paid: premium,
        policy-start: current-time,
        policy-end: (+ current-time (* policy-duration u86400)), ;; days to seconds
        risk-factors: risk-factors,
        deductible: deductible,
        weather-coverage: weather-coverage,
        theft-coverage: theft-coverage,
        damage-coverage: damage-coverage,
        delay-coverage: delay-coverage,
        status: "active"
      }
    )
    (var-set next-policy-id (+ policy-id u1))
    (var-set insurance-pool (+ (var-get insurance-pool) premium))
    (ok policy-id)
  )
)

;; Update Location and Weather Data
(define-public (update-location
  (shipment-id uint)
  (latitude int)
  (longitude int)
  (wind-speed uint)
  (wave-height uint)
  (storm-category uint)
  (weather-condition (string-ascii 32))
)
  (let (
    (shipment-data (unwrap! (map-get? CargoShipments { shipment-id: shipment-id }) ERR_SHIPMENT_NOT_FOUND))
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    (risk-level (assess-weather-risk wind-speed wave-height storm-category))
  )
    (asserts! (or (is-eq tx-sender (get shipper shipment-data)) (is-eq tx-sender (var-get weather-oracle))) ERR_UNAUTHORIZED)
    ;; Update shipment location
    (map-set CargoShipments
      { shipment-id: shipment-id }
      (merge shipment-data {
        current-latitude: latitude,
        current-longitude: longitude,
        last-update: current-time
      })
    )
    ;; Record weather data
    (map-set WeatherData
      { shipment-id: shipment-id, timestamp: current-time }
      {
        latitude: latitude,
        longitude: longitude,
        wind-speed: wind-speed,
        wave-height: wave-height,
        storm-category: storm-category,
        temperature: 20, ;; Default temperature
        visibility: u10,
        weather-condition: weather-condition,
        risk-level: risk-level
      }
    )
    ;; Auto-trigger claim if severe weather detected
    (if (>= risk-level u70)
      (auto-weather-claim shipment-id risk-level)
      (ok true)
    )
  )
)

;; File Insurance Claim
(define-public (file-claim
  (policy-id uint)
  (claim-type (string-ascii 32))
  (claim-amount uint)
  (incident-date uint)
  (incident-latitude int)
  (incident-longitude int)
  (damage-description (string-ascii 256))
  (supporting-evidence (list 5 (string-ascii 128)))
)
  (let (
    (claim-id (var-get next-claim-id))
    (policy-data (unwrap! (map-get? InsurancePolicies { policy-id: policy-id }) ERR_POLICY_NOT_FOUND))
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
  )
    (asserts! (is-eq tx-sender (get policyholder policy-data)) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status policy-data) "active") ERR_POLICY_EXPIRED)
    (map-set InsuranceClaims
      { claim-id: claim-id }
      {
        policy-id: policy-id,
        shipment-id: (get shipment-id policy-data),
        claimant: tx-sender,
        claim-type: claim-type,
        claim-amount: claim-amount,
        incident-date: incident-date,
        incident-location: { latitude: incident-latitude, longitude: incident-longitude },
        weather-conditions: "pending-verification",
        damage-description: damage-description,
        supporting-evidence: supporting-evidence,
        auto-approved: false,
        claim-status: "pending",
        settlement-amount: u0,
        processed-date: u0
      }
    )
    (var-set next-claim-id (+ claim-id u1))
    (ok claim-id)
  )
)

;; Process Claim (Automated or Manual)
(define-public (process-claim (claim-id uint))
  (let (
    (claim-data (unwrap! (map-get? InsuranceClaims { claim-id: claim-id }) ERR_CLAIM_NOT_FOUND))
    (policy-data (unwrap! (map-get? InsurancePolicies { policy-id: (get policy-id claim-data) }) ERR_POLICY_NOT_FOUND))
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    (settlement (calculate-settlement (get claim-amount claim-data) (get deductible policy-data) (get coverage-amount policy-data)))
  )
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) (is-eq tx-sender (get claimant claim-data))) ERR_UNAUTHORIZED)
    (asserts! (>= (var-get insurance-pool) settlement) ERR_INSUFFICIENT_BALANCE)
    ;; Transfer settlement to claimant
    (try! (as-contract (stx-transfer? settlement tx-sender (get claimant claim-data))))
    ;; Update claim record
    (map-set InsuranceClaims
      { claim-id: claim-id }
      (merge claim-data {
        claim-status: "settled",
        settlement-amount: settlement,
        processed-date: current-time
      })
    )
    (var-set insurance-pool (- (var-get insurance-pool) settlement))
    (ok settlement)
  )
)

;; Auto Weather Claim (Internal)
(define-private (auto-weather-claim (shipment-id uint) (risk-level uint))
  (match (get-active-policy shipment-id)
    policy-id
    (let (
      (claim-id (var-get next-claim-id))
      (policy-data (unwrap-panic (map-get? InsurancePolicies { policy-id: policy-id })))
      (estimated-damage (/ (* (get coverage-amount policy-data) risk-level) u100))
    )
      (map-set InsuranceClaims
        { claim-id: claim-id }
        {
          policy-id: policy-id,
          shipment-id: shipment-id,
          claimant: (get policyholder policy-data),
          claim-type: "auto-weather",
          claim-amount: estimated-damage,
          incident-date: (unwrap-panic (get-block-info? time (- block-height u1))),
          incident-location: { latitude: 0, longitude: 0 },
          weather-conditions: "severe-weather-detected",
          damage-description: "Automatic claim triggered by severe weather conditions",
          supporting-evidence: (list "weather-data" "gps-tracking" "sensor-data"),
          auto-approved: true,
          claim-status: "auto-approved",
          settlement-amount: u0,
          processed-date: u0
        }
      )
      (var-set next-claim-id (+ claim-id u1))
      (ok true)
    )
    (ok false)
  )
)

;; Helper Functions
(define-private (get-active-policy (shipment-id uint))
  (fold check-active-policy (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) none)
)

(define-private (check-active-policy (id uint) (current (optional uint)))
  (if (is-some current)
    current
    (match (map-get? InsurancePolicies { policy-id: id })
      policy-data (if (and (is-eq (get shipment-id policy-data) id) (is-eq (get status policy-data) "active"))
                     (some id)
                     none)
      none
    )
  )
)

(define-private (calculate-risk-score (risk-factors (list 5 (string-ascii 32))))
  (fold add-risk-factor risk-factors u0)
)

(define-private (add-risk-factor (factor (string-ascii 32)) (current uint))
  (+ current
    (if (is-eq factor "high-value") u20
    (if (is-eq factor "fragile") u15
    (if (is-eq factor "hazardous") u25
    (if (is-eq factor "weather-sensitive") u10
    (if (is-eq factor "theft-risk") u15
      u5
    )))))
  )
)

;; Read-only Functions

;; Get Shipment Information
(define-read-only (get-shipment (shipment-id uint))
  (map-get? CargoShipments { shipment-id: shipment-id })
)

;; Get Policy Information
(define-read-only (get-policy (policy-id uint))
  (map-get? InsurancePolicies { policy-id: policy-id })
)

;; Get Claim Information
(define-read-only (get-claim (claim-id uint))
  (map-get? InsuranceClaims { claim-id: claim-id })
)

;; Get Weather Data
(define-read-only (get-weather-data (shipment-id uint) (timestamp uint))
  (map-get? WeatherData { shipment-id: shipment-id, timestamp: timestamp })
)

;; Get Insurance Pool Balance
(define-read-only (get-insurance-pool)
  (var-get insurance-pool)
)

;; Get Shipment Count
(define-read-only (get-shipment-count)
  (- (var-get next-shipment-id) u1)
)

;; Get Policy Count  
(define-read-only (get-policy-count)
  (- (var-get next-policy-id) u1)
)

;; Get Claim Count
(define-read-only (get-claim-count)
  (- (var-get next-claim-id) u1)
)


;; title: cargo-protector
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps
;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

