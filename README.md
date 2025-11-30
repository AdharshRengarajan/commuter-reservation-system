# Commuter Reservation System (CRS)

Oracle SQL and PL/SQL based mini reservation system for managing trains, passengers and ticket reservations with business and economy classes and waitlisting.

---

## Table of Contents

1. [Overview](#overview)  
2. [Key Features](#key-features)  
3. [Business Rules](#business-rules)  
4. [Tech Stack and Prerequisites](#tech-stack-and-prerequisites)  
---

## Overview

The Commuter Reservation System (CRS) is a simplified train reservation system built on Oracle SQL and PL/SQL.

The system manages:

- Train master data and schedules  
- Passenger profiles  
- Ticket reservations with confirmed and waitlisted seats  
- Business rules for capacity, waitlist, cancellations, and booking windows  

The focus is on database design, constraints, stored procedures, functions, and packages. No payment integration is implemented.

---

## Key Features

- Maintain master list of trains with seat capacities and fares per class  
- Maintain day-of-week schedules and train in-service flags  
- Maintain passenger profiles with unique email and phone  
- Book tickets for Business (FC) or Economy (ECON) class  
- Enforce capacity limits and waitlist limits per class  
- Automatic waitlisting when seats are exhausted  
- Automatic promotion of earliest waitlisted ticket upon cancellation  
- Validation of train, booking dates, and business rules  
- Two-schema setup with controlled privileges for application usage  

---

## Business Rules

1. **Passenger Uniqueness**
   - `email` is unique across all passengers  
   - `phone` is unique across all passengers  

2. **Booking Rules**
   - Passenger must provide:
     - Passenger info (or reference to an existing passenger)  
     - Train number  
     - Booking date and travel date  
   - Train number and travel date must be valid and in service.  
   - Seats must be available for the chosen class (FC or ECON).  
   - Only one week advance booking allowed (travel date within 7 days from booking date).  

3. **Capacity and Waitlist**
   - Two classes:  
     - Business / First Class: `FC`  
     - Economy Class: `ECON`  
   - Each class has:
     - Maximum 40 confirmed tickets per train per travel date  
     - Additional 5 waitlisted tickets per train per travel date  
   - After both confirmed and waitlist are full, no more bookings allowed.

4. **Ticket Status**
   - `seat_status` allowed values:
     - `CONFIRMED`  
     - `WAITLISTED`  
     - `CANCELLED`  

5. **Cancellation Rules**
   - Passenger can cancel any booked ticket by providing `booking_id`.  
   - Cancellation:
     - Changes `seat_status` to `CANCELLED`  
     - If a waitlist exists for the same train, travel date, and class, the earliest waitlisted ticket (lowest `waitlist_position`) is promoted to `CONFIRMED`.  

6. **Train Schedules**
   - System supports weekly schedules through a day-of-week table.  
   - Trains can be configured:
     - Weekdays only  
     - Weekends only  
     - All days  
   - `is_in_service` flag controls whether a train operates on a given day.

---

## Tech Stack and Prerequisites

- **Database**: Oracle Database
- **Language**: Oracle SQL and PL/SQL  
- **Tools**: SQL Developer  
 