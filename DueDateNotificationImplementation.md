# Due Date Notification System Implementation

## Overview

I've implemented a comprehensive local notification system for SoftDreams that reminds users to update their pregnancy profiles near the due date. The system automatically schedules notifications and handles profile updates gracefully.

## Key Features

### 1. Notification Schedule

- **3 days before due date**: First reminder to update profile if due date changed
- **On due date**: Reminder if baby has arrived to update profile
- **2 days after due date**: Final reminder if profile still hasn't been updated

### 2. Smart Notification Management

- Prevents duplicate notifications using history tracking
- Automatically cancels notifications when baby is born
- Reschedules notifications when due date is updated
- Handles app launch notification setup

### 3. User-Friendly Features

- Interactive notification actions (Update Profile, Remind Later)
- Child-friendly notification messages
- Proper permission handling
- Background notification support

## Implementation Details

### Files Created/Modified

#### New Files

1. **`DueDateNotificationService.swift`**
   - Core notification scheduling logic
   - History tracking to prevent duplicates
   - Permission management
   - Notification content customization

#### Modified Files

1. **`AutoProfileUpdateService.swift`**
   - Integrated with notification service
   - Handles notification cancellation when baby is born
   - Sets up notifications for pregnancy profiles

2. **`SoftDreamsApp.swift`**
   - Added notification delegate
   - Set up notification categories with actions
   - Automatic notification setup on app launch

3. **`ServiceFactory.swift`**
   - Added factory methods for notification service
   - Centralized service creation

4. **`OnboardingViewModel.swift`**
   - Sets up notifications when pregnancy profile is created

5. **`EditProfileViewModel.swift`**
   - Handles notification updates when profile is edited
   - Reschedules notifications when due date changes

6. **`HomeViewModel.swift`**
   - Ensures notifications are set up during auto-updates
   - Validates notification setup on app launch

7. **`project.pbxproj`**
   - Added notification usage description for App Store compliance

### Core Classes

#### `DueDateNotificationService`

- **Purpose**: Manages all due date notification functionality
- **Key Methods**:
  - `setupDueDateNotifications()`: Request permission and schedule notifications
  - `scheduleNotificationsForCurrentProfile()`: Schedule for current pregnancy profile
  - `cancelAllDueDateNotifications()`: Cancel all due date notifications
  - `handleProfileUpdate()`: Handle profile changes

#### `NotificationDelegate`

- **Purpose**: Handles notification responses and presentation
- **Features**:
  - Processes user actions (Update Profile, Remind Later)
  - Shows notifications even when app is in foreground
  - Schedules follow-up reminders

## Usage Flow

### 1. Onboarding with Pregnancy Profile

```bash
User completes onboarding with pregnancy → 
Notifications automatically scheduled →
3 notifications queued (3 days before, on due date, 2 days after)
```

### 2. Profile Updates

```bash
User updates due date →
Old notifications cancelled →
New notifications scheduled with updated dates
```

### 3. Baby Born

```bash
User updates from pregnancy to newborn →
All due date notifications cancelled →
Profile automatically updated
```

### 4. Auto-Updates

```bash
App launches →
Auto-update checks for stage progression →
If baby should be born based on due date →
Automatic transition to newborn + notification cleanup
```

## Testing Guide

### 1. Testing Notification Permission

```swift
// In simulator or device, go to Settings > Notifications > SoftDreams
// Verify permission request appears when creating pregnancy profile
```

### 2. Testing Notification Scheduling

```swift
// Create pregnancy profile with due date in near future
// Check notification center for scheduled notifications
// Verify correct timing (3 days before, on date, 2 days after)
```

### 3. Testing Profile Updates

```swift
// Update due date in existing pregnancy profile
// Verify old notifications are cancelled
// Verify new notifications are scheduled
```

### 4. Testing Baby Born Transition

```swift
// Update profile from pregnancy to newborn
// Verify all due date notifications are cancelled
// Verify no new notifications are scheduled
```

### 5. Testing Notification Actions

```swift
// Receive notification
// Test "Update Profile" action (should open app)
// Test "Remind Later" action (should schedule 24h reminder)
```

## Configuration

### Notification Permission

The app requests notification permission with the usage description:
> "SoftDreams sends helpful reminders to update your baby's profile for personalized stories."

### Notification Categories

- **Category ID**: `DUE_DATE_REMINDER`
- **Actions**:
  - Update Profile (opens app)
  - Remind Later (schedules 24h reminder)

### Notification Identifiers

- `due_date_3_days_before`
- `due_date_on_date`
- `due_date_2_days_after`

## Edge Cases Handled

1. **Permission Denied**: Gracefully handles when user denies notification permission
2. **Multiple Profiles**: Tracks notifications per profile to avoid conflicts
3. **Date Changes**: Properly reschedules when due date is updated
4. **App Lifecycle**: Sets up notifications on app launch if needed
5. **Background Processing**: Notifications work even when app is closed
6. **Duplicate Prevention**: History tracking prevents duplicate notifications

## Future Enhancements

1. **Customizable Timing**: Allow users to configure notification timing
2. **Rich Notifications**: Add images or more interactive content
3. **Multiple Reminders**: Support for additional reminder types
4. **Localization**: Support for multiple languages
5. **Sound Customization**: Custom notification sounds for baby app

## Troubleshooting

### Common Issues

1. **Notifications not appearing**: Check device notification settings
2. **Permission issues**: Verify `NSUserNotificationsUsageDescription` in project
3. **Duplicate notifications**: Check notification history implementation
4. **Timing issues**: Verify date calculations and time zone handling

### Debug Logging

The system includes comprehensive logging with category `.notification` for debugging notification-related issues.

## Conclusion

The due date notification system provides a seamless way to keep pregnancy profiles up-to-date while respecting user preferences and providing value through timely reminders. The implementation is robust, handles edge cases well, and integrates smoothly with the existing SoftDreams architecture.
