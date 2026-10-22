# 🎯 Booking Implementation - Visual Overview

## System Architecture

```
VENDOR CARS DASHBOARD
        ↓
    [VendorCar]
   {pricing: {...}}
        ↓
   [Book Now Button]
        ↓
BOOKING SCREEN
        ↓
[BookingController]
        ↓
  Form Fields
  Dynamic Labels
  Real-time Calc
        ↓
PREVIEW SCREEN
  with charges
        ↓
PAYMENT SCREEN
```

## Form State Management

```
┌─────────────────────────────────────┐
│    BookingController State          │
├─────────────────────────────────────┤
│                                     │
│  Controllers:                       │
│  • emailController (auto-filled)    │
│  • mobileController (auto-filled)   │
│  • quantityController (user input)  │
│  • locationController (conditional) │
│  • noteController (optional)        │
│                                     │
│  Observables:                       │
│  • pricingType: "per_day|per_km"   │
│  • pricingUnit: "day|km"           │
│  • subtotal: 0.0                   │
│  • deliveryCharge: 0.0             │
│  • total: 0.0                      │
│  • isDeliver: false                │
│  • isFormValid: false              │
│                                     │
└─────────────────────────────────────┘
```

## Reactive Updates

```
┌──────────────────────────────────────────┐
│      User Action                         │
└─────────────────────┬────────────────────┘
                      ↓
┌──────────────────────────────────────────┐
│   quantityController.text changes        │
└─────────────────────┬────────────────────┘
                      ↓
┌──────────────────────────────────────────┐
│   Listener triggered                     │
│   • _updateFormValidity()                │
│   • _calculateCharges()                  │
└─────────────────────┬────────────────────┘
                      ↓
┌──────────────────────────────────────────┐
│   Observables updated:                   │
│   • subtotal = qty × price               │
│   • deliveryCharge = subtotal × 0.1      │
│   • total = subtotal + delivery          │
│   • isFormValid = all fields filled      │
└─────────────────────┬────────────────────┘
                      ↓
┌──────────────────────────────────────────┐
│   Obx() widgets rebuild                  │
│   • Price summary updates                │
│   • Form validation updates              │
│   • Button state updates                 │
└──────────────────────────────────────────┘
```

## Per Day vs Per KM Decision Tree

```
                    ┌─────────────────┐
                    │  Selected Car   │
                    └────────┬────────┘
                             ↓
                ┌────────────────────────────┐
                │ car.pricing.type == ?      │
                └────┬──────────────────┬────┘
                     ↓                  ↓
            "per_day"            "per_km"
                │                    │
         ┌──────┴──────┐      ┌──────┴──────┐
         ↓             ↓      ↓             ↓
      Label      Unit: day  Label      Unit: km
    عدد الأيام   price/day المسافة   price/km
         │             │      │             │
         └──────┬──────┘      └──────┬──────┘
                ↓                    ↓
            qty: days          qty: km
            calc: qty×price    calc: qty×price
                │                    │
                └──────────┬─────────┘
                           ↓
                    Both calculate
                  subtotal same way
                    subtotal = qty × price
```

## Form Validation States

```
INVALID STATE (Continue Button DISABLED)
├─ Email field empty (shouldn't happen - auto-filled)
├─ Phone field empty (shouldn't happen - auto-filled)
├─ Quantity field empty ← Most likely reason
│
└─ If Delivery checked:
   └─ Location field empty ← Required when delivery enabled

VALID STATE (Continue Button ENABLED)
├─ Email: filled ✓
├─ Phone: filled ✓
├─ Quantity: filled ✓
│
└─ If Delivery checked:
   └─ Location: filled ✓
```

## Delivery Charge Calculation

```
┌─────────────────────────────────┐
│   User checks delivery box      │
└────────────┬────────────────────┘
             ↓
┌─────────────────────────────────┐
│   Show location input field     │
│   Mark location as required     │
└────────────┬────────────────────┘
             ↓
┌─────────────────────────────────┐
│   When subtotal updates:        │
│                                 │
│   if (isDeliver.value) {        │
│     deliveryCharge =            │
│       subtotal × 0.1            │
│   } else {                      │
│     deliveryCharge = 0          │
│   }                             │
│   total = subtotal +            │
│            deliveryCharge       │
└─────────────────────────────────┘
```

## Data Transformation

```
INPUT: VendorCar
{
  id: 13,
  vendorName: "تلجاني",
  make: "تويوتا",
  model: "كامري",
  pricing: {
    type: "per_day",
    currency: "SAR",
    price: 100,
    unit: "day",
    displayName: "Price per day"
  }
}
        ↓
        ↓ initializeWithCar(car)
        ↓
CONTROLLER STATE
{
  selectedPricing: pricing object
  pricingType: "per_day"
  pricingUnit: "day"
}
        ↓
        ↓ User enters: 5 days
        ↓
CALCULATIONS
{
  subtotal: 500        // 5 × 100
  deliveryCharge: 50   // 500 × 0.1
  total: 550
}
        ↓
        ↓ User clicks Continue
        ↓
OUTPUT: getBookingData()
{
  email: "user@example.com",
  phone: "+966501234567",
  quantity: "5",
  pricing_type: "per_day",
  pricing_unit: "day",
  delivery_required: true,
  delivery_location: "Riyadh",
  notes: "...",
  subtotal: 500.0,
  delivery_charge: 50.0,
  total: 550.0
}
```

## Component Interaction Map

```
┌─────────────────────────────────────┐
│  All Vendors Dashboard Controller   │
│  • vendor cars list                 │
│  • pass selected car on tap         │
└────────────────┬────────────────────┘
                 │ Get.toNamed(
                 │   Routes.bookingScreen,
                 │   arguments: {'car': car}
                 │ )
                 ↓
┌─────────────────────────────────────┐
│  Booking Screen                     │
│  • shows booking form               │
└────────────────┬────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────┐
│  BookingController                  │
│  • receives car from arguments      │
│  • initializes with car data        │
│  • manages form state               │
│  • calculates prices                │
│  • prepares booking data            │
└────────────────┬────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────┐
│  BookingAllFields Widget            │
│  • displays form fields             │
│  • binds to controller              │
│  • reactive price updates           │
│  • form validation visual           │
└────────────────┬────────────────────┘
                 │ User submits
                 │ getBookingData()
                 ↓
┌─────────────────────────────────────┐
│  Preview Controller                 │
│  • receives booking data            │
│  • displays summary                 │
│  • handles payment                  │
└─────────────────────────────────────┘
```

## Key Controller Methods Call Order

```
1. INITIALIZATION
   onInit()
   ├─ _initializeUserData()
   │  ├─ emailController.text = LocalStorage.email
   │  └─ mobileController.text = LocalStorage.number
   │
   └─ _setupListeners()
      ├─ emailController.addListener()
      ├─ quantityController.addListener()
      └─ ever(isDeliver, ...)
           
2. ARGUMENT HANDLING
   onInit() - Check if car passed as argument
   └─ initializeWithCar(car)
      ├─ selectedPricing.value = car.pricing
      ├─ pricingType.value = car.pricing.type
      ├─ pricingUnit.value = car.pricing.unit
      └─ _updateFormValidity()

3. USER INPUT
   quantityController.text changes
   ├─ _updateFormValidity()
   │  └─ isFormValid.value = true/false
   │
   └─ _calculateCharges()
      ├─ subtotal.value = qty × price
      ├─ deliveryCharge.value = ...
      └─ total.value = subtotal + delivery

4. SUBMISSION
   User clicks Continue
   └─ calculateAllCharges() (legacy)
      └─ Get.toNamed(Routes.previewScreen)
         
   OR

   getBookingData()
   └─ return booking map with all fields
```

## Debug Points

```
┌─────────────────────────────────────┐
│  To verify setup is correct:        │
├─────────────────────────────────────┤
│                                     │
│  1. Log in onInit:                  │
│     log.i('pricingType: $pricingType')
│     log.i('pricingUnit: $pricingUnit')
│                                     │
│  2. Log in _calculateCharges:       │
│     log.i('qty: $quantity')         │
│     log.i('price: $price')          │
│     log.i('subtotal: $subtotal')    │
│     log.i('delivery: $delivery')    │
│     log.i('total: $total')          │
│                                     │
│  3. Log in _updateFormValidity:     │
│     log.i('formValid: $isFormValid')
│                                     │
│  4. Log on submit:                  │
│     print(getBookingData())         │
│                                     │
└─────────────────────────────────────┘
```

---

**Status**: ✅ COMPLETE & READY FOR TESTING
