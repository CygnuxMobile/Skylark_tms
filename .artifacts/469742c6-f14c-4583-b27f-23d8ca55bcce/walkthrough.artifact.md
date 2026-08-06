# Walkthrough - Special Characters Allowed in Invoice No and Consignee Name

I have updated the Booking screen to ensure that special characters are explicitly allowed and the correct keyboard is provided for the Invoice Number and Consignee Name fields.

## Changes Made

### [BookingScreen](file:///E:/Aayush/flutter/Skylark_tms-git/lib/app/modules/booking/booking_screen.dart)

- Updated the **Invoice Number** field (`invNoController`) to use `keyboardType: TextInputType.text`.
- Updated the **Consignee Name** field (`walkInNameController`) in the Walk-In section to use `keyboardType: TextInputType.text`.

These changes ensure that symbols and special characters (like `/`, `-`, `&`, `.`) are easily accessible on the software keyboard and are not restricted by any validation logic.

## Verification Results

- **Invoice Number**: Now explicitly supports text input, allowing alphanumeric codes with symbols.
- **Consignee Name**: Walk-in names can now include special characters and punctuation.
