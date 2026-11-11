<p align="right"><b>English</b> · <a href="product.ru.md">Русский</a></p>

# Wayback

> Save a place. Find your way back.

Wayback is a mobile app for saving the current location and returning to it later with GPS and a compass.

Instead of building a route, the app shows the user **the direction to the saved point and the distance to it**.

The core idea is a tool as simple and reliable as possible, one that keeps working where regular navigation is awkward or there is no internet.

---

## Problem

In many situations the user does not need a full route along roads or trails. They only need to know:

- where the saved place is;
- which way it is;
- how far it is.

For example, someone leaves their car by the woods, saves its location and goes for a walk.

Later they do not need to know the route back. It is enough to open the app and see:

**← 640 m to the car**

The arrow keeps pointing at the saved point, wherever the user is moving.

---

## Main Scenario

The main user scenario:

1. The user is next to the car.
2. Opens Wayback.
3. Taps **Save current location**.
4. The app gets the current GPS coordinates.
5. The user can name the point, for example **Car**.
6. The user walks away from the car.
7. When it is time to go back, they open the saved point.
8. The app shows:
   - the direction to the point;
   - the distance to it;
   - the current GPS accuracy.
9. Direction and distance update as the user moves.
10. When the user gets close, the app says they are near the target.

---

## Use Cases

The app is not limited to finding a car.

You can save:

- 🚗 a car;
- ⛺ a tent or a camp;
- 🎣 a fishing spot;
- 🎒 things left behind;
- 🏠 a cabin or a holiday base;
- 📍 a meeting place;
- 🌲 an interesting place in the woods;
- 🅿️ a parking spot;
- any point at all.

The main principle:

**Save → Walk away → Navigate back**

---

## Core Experience

The main navigation screen has to be as simple as possible.

The user has to see right away:

### Direction

A large arrow or compass keeps pointing towards the chosen point.

The direction is calculated from:

- the current GPS position;
- the coordinates of the saved point;
- the heading of the device.

### Distance

The remaining distance is shown under the arrow:

**1.4 km**

or

**320 m**

The value updates as the user moves.

### GPS Accuracy

The user has to understand the approximate position error:

**GPS accuracy ±8 m**

This matters most when looking for small objects and when using the app in the woods.

---

## MVP

The first version of Wayback has to stay small.

### Location

- getting the current GPS position;
- showing the GPS accuracy;
- tracking changes in the user's position.

### Saved Points

- saving the current position;
- a point name;
- a simple type/icon;
- viewing saved points;
- deleting a point;
- choosing the active point.

### Navigation

- direction to the active point;
- distance to it;
- a compass;
- smooth changes of the arrow direction;
- distance updates while moving.

### Offline

The core functionality has to work **without an internet connection**.

GPS, the device sensors and locally saved coordinates are enough to find the direction to a saved point.

### Arrival

When the user gets close to the saved point, the app can let them know with:

- a visual state;
- vibration;
- a sound.

For example:

**You are near your destination — 18 m**

---

## Non-Goals for MVP

The first version must not turn into a full navigator.

Not needed at the start:

- sign-up;
- accounts;
- social features;
- sync between devices;
- car routes;
- routing along roads;
- routing along trails;
- a server side;
- a required internet connection.

The core value of the MVP:

> The user saves a point and can always find the direction and distance to it.

---

## Technical Concept

For each saved point it is enough to store the coordinates:

```text
latitude
longitude
```

It can also store:

```text
id
name
type
latitude
longitude
createdAt
altitude
```

During navigation the app gets:

```text
Current location:
latitude
longitude

Target:
latitude
longitude

Device:
heading
```

From this data it calculates:

```text
distance(currentLocation, targetLocation)

bearing(currentLocation, targetLocation)

arrowRotation = bearing - deviceHeading
```

So the core navigation needs neither the internet nor an external routing API.

---

## UX Principles

### Immediate

The user should be able to save their position in practically one action.

### Simple

On the way back, the main information is:

**direction + distance**

Everything else is secondary.

### Offline First

The main scenario has to work without a mobile network.

### Outdoor Friendly

The interface has to be comfortable outdoors:

- large elements;
- high readability;
- a minimum of small text;
- a minimum of actions;
- a clear GPS state;
- good behaviour in bright light.

### Honest About Accuracy

GPS and the magnetic compass have errors.

The app must not create a false sense of absolute precision, and it has to tell the user about a weak GPS signal or unreliable compass data.

---

## Future Ideas

After the MVP the project can grow.

Possible features:

- a map with the user and the saved point;
- several active points;
- a history of visited places;
- showing the path walked;
- a breadcrumb trail;
- altitude above sea level;
- walk statistics;
- import and export of coordinates;
- passing a point to another person;
- Apple Watch / Wear OS;
- widgets;
- Live Activities;
- automatic saving of the parking spot;
- a photo of the saved place;
- a note on the point;
- offline maps.

---

## Product Vision

Wayback should not compete with full mapping services.

Its job is much simpler:

> **Help a person get back to a known point as quickly and simply as possible.**

The user does not need to look for a place on a map, download regional maps or build a route.

They save their position, walk away and at any moment get a simple answer to two questions:

**Where to go?**

**How far is it?**
