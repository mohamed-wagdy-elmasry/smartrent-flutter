# PayTabs Configuration Guide

## How to Identify PayTabs Gateway in Your App

The system automatically detects PayTabs gateway when:

```dart
// Option 1: Gateway alias contains 'paytabs'
alias.value.contains('paytabs')

// Option 2: Payment type contains 'paytabs'
paymentTypes.value.contains('paytabs')
```

## Laravel Backend Configuration Checklist

### 1. Environment Variables (.env)
```env
PAYTABS_PROFILE_ID=your_profile_id
PAYTABS_SERVER_KEY=your_server_key
PAYTABS_CURRENCY=SAR
PAYTABS_REGION=SAU
PAYTABS_ENVIRONMENT=sandbox  # Change to 'production' for live
```

### 2. Required API Routes
Your Laravel backend must have these routes defined:

```php
Route::post('/api/paytabs/create-payment', 'PayTabsController@createPayment');
Route::post('/api/paytabs/verify-payment', 'PayTabsController@verifyPayment');
Route::post('/api/paytabs/refund-payment', 'PayTabsController@refundPayment');
Route::get('/api/paytabs/payment-methods', 'PayTabsController@getPaymentMethods');
Route::get('/api/paytabs/currencies', 'PayTabsController@getCurrencies');
```

### 3. Payment Gateway Setup in Database
Make sure your payment gateway has PayTabs configured with:
- **Type**: `paytabs` or similar identifier
- **Alias**: Must contain `paytabs`
- **Status**: Active/Enabled
- **Currencies**: Configured with proper rates

## Testing

### Sandbox Test Cards
**Successful Payment:**
- Card: `4111 1111 1111 1111`
- Expiry: Any future date
- CVV: `123`

**Declined Payment:**
- Card: `4000 0000 0000 0002`
- Expiry: Any future date
- CVV: `123`

### Testing Checklist
- [ ] PayTabs credentials configured in Laravel
- [ ] API routes accessible from mobile app
- [ ] Payment gateway enabled in database
- [ ] Test card processes successfully
- [ ] Payment verification works
- [ ] Booking confirmation appears after payment
- [ ] Callback URL is publicly accessible

## Common Issues

### Issue: "Payment gateway not found"
**Solution:** Ensure gateway alias contains 'paytabs' in database

### Issue: "Failed to create payment"
**Solution:** 
- Check Laravel logs
- Verify PayTabs credentials
- Ensure API endpoint is accessible

### Issue: "Payment verification failed"
**Solution:**
- Check Laravel callback URL is publicly accessible
- Verify transaction reference is correct
- Wait a few seconds and retry

### Issue: WebView shows blank page
**Solution:**
- Check payment URL is valid
- Ensure JavaScript is enabled (already done in code)
- Verify CORS settings in Laravel

## API Response Format

### Create Payment Success
```json
{
  "success": true,
  "message": "Payment page created successfully",
  "data": {
    "payment_url": "https://secure.paytabs.sa/payment/page/...",
    "transaction_ref": "TST2213800357411"
  }
}
```

### Verify Payment Success
```json
{
  "success": true,
  "message": "Payment successful",
  "data": {
    "transaction_ref": "TST2213800357411",
    "cart_id": "BOOKING_123456789",
    "amount": 100.50,
    "currency": "SAR",
    "status": "A",
    "code": "100"
  }
}
```

## Payment Status Codes
- **A** - Approved (Payment successful)
- **H** - Hold (Requires action)
- **P** - Pending
- **V** - Voided
- **E** - Error
- **D** - Declined

## Integration Points

### When Payment is Triggered
```dart
// In PaymentSelectionWidget
GestureDetector(
  onTap: () {
    controller.changePaymentMethod(1); // Online payment
    // Select PayTabs gateway from dropdown
  },
)
```

### Payment Flow Trigger
```dart
// In PreviewController
void handlePaymentProcess() {
  if (alias.value.contains('paytabs')) {
    processPayTabsPayment(); // ← PayTabs flow starts here
  }
}
```

### Success Handler
```dart
// Called from PayTabsPaymentScreen after verification
previewController.handlePaymentSuccess(transactionRef);
```

## Security Best Practices

✅ **DO:**
- Use HTTPS only for API calls
- Verify payment on server-side
- Store auth tokens securely
- Validate callback signatures in Laravel
- Use bearer token authentication

❌ **DON'T:**
- Expose PayTabs server key in Flutter
- Skip payment verification
- Trust client-side payment status
- Use HTTP for payment endpoints
- Store sensitive data in app

## Production Deployment

Before going live:
1. Change `PAYTABS_ENVIRONMENT` to `production`
2. Update PayTabs credentials to production keys
3. Test with real cards in small amounts
4. Verify callback URL is accessible
5. Enable error logging
6. Set up monitoring for failed payments

## Support Resources

- **PayTabs Docs:** https://docs.paytabs.com/
- **PayTabs Support:** customercare@paytabs.com
- **Support Portal:** https://support.paytabs.com/
