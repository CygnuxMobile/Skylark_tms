# Implementation Plan - Allow Special Characters in Invoice No and Consignee Name

The goal is to ensure that the Invoice Number and Consignee Name fields in the Booking screen explicitly allow special characters and provide the correct keyboard for the user.

## User Review Required

> [!NOTE]
> By default, `CustomTextField` allows all characters. I will explicitly set the keyboard type to `text` for these fields to ensure symbols are easily accessible, and confirm no restrictive formatters are present.

## Proposed Changes

### [skylark]

#### [MODIFY] [booking_screen.dart](file:///E:/Aayush/flutter/Skylark_tms-git/lib/app/modules/booking/booking_screen.dart)
- Update the `CustomTextField` for **Invoice Number** (`invNoController`) to explicitly set `keyboardType: TextInputType.text`.
- Update the `CustomTextField` for **Consignee Name (Walk-In)** (`walkInNameController`) to explicitly set `keyboardType: TextInputType.text`.

## Verification Plan

### Manual Verification
- Open the Booking Screen.
- Navigate to the "Walk-In" consignee section.
- Enter a name with special characters (e.g., `John & Sons Co.`) and verify it is accepted.
- Enter an Invoice Number with special characters (e.g., `INV/2024-25/001`) and verify it is accepted.
- Submit a booking and verify that the special characters are preserved in the data sent to the controller.
