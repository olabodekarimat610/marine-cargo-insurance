# Maritime Cargo Insurance Platform

## Overview

This PR introduces a comprehensive maritime cargo insurance system that revolutionizes how cargo is protected during global shipping operations. The smart contract enables automated insurance policies, real-time GPS tracking, weather-based claim processing, and transparent settlement mechanisms.

## Features Implemented

### Core Insurance Functions

- **Cargo Shipment Registration**: Complete shipment tracking with origin, destination, and cargo details
- **Dynamic Insurance Policies**: Flexible policy creation with customizable coverage options
- **Automated Weather Claims**: Real-time weather monitoring with automatic claim triggering
- **GPS Location Tracking**: Continuous cargo location updates and geofencing capabilities
- **Multi-Coverage Options**: Weather, theft, damage, and delay protection in single policies

### Smart Contract Architecture

- **Cargo Shipments Map**: Comprehensive shipment data with real-time location tracking
- **Insurance Policies Map**: Policy management with coverage terms and premium calculations
- **Weather Data Map**: Real-time meteorological data integration for claim validation
- **Claims Processing Map**: Automated and manual claim processing with settlement tracking
- **Risk Assessment Map**: Dynamic risk scoring based on route, cargo type, and conditions

### Advanced Capabilities

- **Weather Oracle Integration**: Real-time weather data for automated decision making
- **Dynamic Premium Calculation**: Risk-based pricing using multiple factors
- **Automated Settlement Processing**: Instant payouts for qualified claims
- **Multi-Factor Risk Assessment**: Comprehensive risk evaluation system
- **Insurance Pool Management**: Automated pool balance and liquidity management

## Technical Implementation

### Data Structures

The contract implements six comprehensive data maps:

1. **CargoShipments**: Core shipment information with GPS coordinates
2. **InsurancePolicies**: Policy terms, coverage, and premium details
3. **WeatherData**: Real-time weather conditions and risk assessments
4. **InsuranceClaims**: Claim processing and settlement tracking
5. **TrackingHistory**: Complete shipment journey documentation
6. **RiskAssessment**: Multi-factor risk scoring and premium calculations

### Key Smart Contract Functions

- `register-shipment`: Register new cargo shipments with complete details
- `create-policy`: Create comprehensive insurance policies with custom coverage
- `update-location`: Real-time GPS and weather data updates
- `file-claim`: Manual claim filing with supporting documentation
- `process-claim`: Automated claim processing and settlement
- `auto-weather-claim`: Automatic weather-triggered claim generation

### Risk Management System

- **Multi-Factor Risk Scoring**: Cargo type, route, weather, and vessel risk assessment
- **Dynamic Premium Adjustments**: Real-time premium calculations based on risk factors
- **Weather Risk Assessment**: Advanced weather pattern analysis for claim validation
- **Settlement Calculations**: Automated deductible and coverage limit calculations

## Insurance Coverage Types

### Weather Coverage
- Storm and hurricane damage protection
- High wind and wave damage claims
- Severe weather delay compensation
- Automatic triggering based on weather thresholds

### Comprehensive Protection
- Theft and piracy coverage
- Physical damage protection
- Delivery delay compensation
- Container and cargo loss protection

### Specialized Features
- High-value cargo protection
- Fragile goods handling coverage
- Hazardous materials special terms
- Multi-modal transport protection

## Automated Claims Processing

### Weather-Based Automation
- Real-time weather monitoring integration
- Automatic claim generation for severe conditions
- Risk threshold-based claim triggering
- Instant settlement for qualified auto-claims

### Manual Claims Processing
- Comprehensive claim documentation system
- Multi-evidence support for claim validation
- Flexible settlement calculations
- Transparent processing status tracking

## Financial Management

### Insurance Pool Operations
- Automated premium collection and pool management
- Real-time liquidity monitoring and risk assessment
- Settlement processing with pool balance validation
- Premium calculation based on dynamic risk factors

### Settlement Processing
- Automated deductible calculations
- Coverage limit enforcement
- Instant settlement transfers to claimants
- Complete audit trail for all transactions

## Usage Examples

### Register Shipment
```clarity
(contract-call? .cargo-protector register-shipment 
  "Electronics" 
  "Shanghai" 
  "Los-Angeles" 
  u1000000 
  u1672531200 
  u1672617600 
  "MSC-Oscar" 
  (list "CONT001" "CONT002"))
```

### Create Insurance Policy
```clarity
(contract-call? .cargo-protector create-policy 
  u1 
  u800000 
  u30 
  (list "high-value" "fragile" "weather-sensitive") 
  true 
  true 
  true 
  false)
```

### Update Location with Weather Data
```clarity
(contract-call? .cargo-protector update-location 
  u1 
  340000000 
  -1180000000 
  u45 
  u6 
  u2 
  "stormy")
```

### File Insurance Claim
```clarity
(contract-call? .cargo-protector file-claim 
  u1 
  "weather-damage" 
  u50000 
  u1672531200 
  340000000 
  -1180000000 
  "Container damaged due to storm conditions" 
  (list "photos" "weather-report" "survey-report"))
```

## Security and Authorization

### Access Control
- Contract owner administrative privileges
- Weather oracle authorized data updates
- Shipment owner location update permissions
- Policyholder claim filing and processing rights

### Data Integrity
- Immutable transaction records on blockchain
- Cryptographic verification of all operations
- Multi-signature requirements for high-value claims
- Audit trails for regulatory compliance

## Risk Assessment Algorithm

### Multi-Factor Analysis
- Cargo type risk scoring (high-value: 20, fragile: 15, hazardous: 25)
- Weather sensitivity factors (weather-sensitive: 10 points)
- Theft risk assessments (theft-risk: 15 points)
- Route-specific risk calculations

### Weather Risk Evaluation
- Wind speed thresholds (40+ mph: high risk)
- Wave height assessments (8+ feet: severe risk)
- Storm category multipliers (category × 20 points)
- Automated claim triggering at 70+ risk level

## Testing and Validation

### Contract Verification
- All functions tested for proper authorization
- Data integrity validation across operations
- Error handling for edge cases and invalid inputs
- Settlement calculation accuracy verification

### Integration Testing
- Weather data integration validation
- GPS tracking system compatibility
- Multi-currency settlement processing
- Insurance pool balance management

## Future Enhancements

### Advanced Features
- Machine learning for predictive risk analytics
- Satellite imagery integration for damage assessment
- IoT sensor integration for real-time cargo monitoring
- Blockchain interoperability for global coverage

### Platform Expansion
- Mobile applications for field inspections
- API integrations with shipping management systems
- Multi-language support for global operations
- Advanced reporting and analytics dashboards

## Contract Specifications

- **Language**: Clarity Smart Contract Language
- **Platform**: Stacks Blockchain
- **Total Lines**: 493 lines of code
- **Public Functions**: 6 core functions
- **Read-Only Functions**: 8 query functions
- **Private Functions**: 8 helper functions
- **Data Maps**: 6 comprehensive data structures
- **Error Codes**: 10 specific error conditions

This implementation provides a robust foundation for maritime cargo insurance with comprehensive automation, real-time monitoring, and transparent claim processing capabilities.
