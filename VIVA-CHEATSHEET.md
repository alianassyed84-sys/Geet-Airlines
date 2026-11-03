# Geet Airlines - Java Viva & Class Presentation Cheat Sheet

Yeh cheat sheet aapke class presentation aur professor ke viva questions ke liye design ki gayi hai. Isme aapke syllabus ke saare topics [GeetAirlinesConsole.java](file:///c:/Users/admin/Desktop/Geet-Airlines/GeetAirlinesConsole.java) ke line numbers aur concepts ke saath mapped hain.

---

## How to Run in Class

```bash
# 1. Compile
javac GeetAirlinesConsole.java

# 2. Run
java GeetAirlinesConsole
```

> **Viva Tip:** Menu option `4` dabate hi ek second me saare syllabus topics live output me screen par print ho jaate hain!

---

## 1. OOP CONCEPTS

### A. Classes & Objects
- **Kahan use hua:** `Flight`, `User`, `Customer`, `Admin`, `Booking` classes banayi gayi hain.
- **Example:** `new Customer(...)`, `new Flight("AI101", ...)` objects create karte hain.
- **Viva Answer:** *"Sir, humne real-world entities jaise Flight, Customer, Admin aur Booking ko Java classes aur objects me model kiya hai."*

### B. Encapsulation
- **Kahan use hua:** Classes ke saare data fields `private` hain (e.g., `private double price;`, `private String password;`).
- **Access:** Unhe access karne ke liye public getters (`getPrice()`, `getFlightNumber()`) aur setters use kiye hain with validation logic.
- **Viva Answer:** *"Data hiding aur integrity ensure karne ke liye fields private hain aur unhe public getters/setters ke through expose kiya hai."*

### C. Inheritance
- **Kahan use hua:** 
  - Base class: `abstract class User`
  - Derived classes: `class Customer extends User` aur `class Admin extends User`
- **Viva Answer:** *"Common user properties (userId, name, email, phone) base class `User` me hain, aur specific roles (Customer address, Admin department) subclass me inherit hoti hain."*

### D. Polymorphism
1. **Method Overriding (Runtime Polymorphism):**
   - `User.displayDashboard()` aur `User.getRole()` ko `Customer` aur `Admin` dono ne override kiya hai.
   - `user.displayDashboard()` call karne par dynamic method dispatch se runtime par role-based screen khulti hai.
2. **Method Overloading (Compile-time Polymorphism):**
   - `searchFlights(destination)`
   - `searchFlights(source, destination)`
   - `searchFlights(provider, source, destination)`

### E. Abstraction & Interfaces
- **Interfaces:** `interface AirlineService` aur `interface Printable`
- **Abstract Class:** `abstract class User` (jisme `abstract void displayDashboard()` hai)
- **Viva Answer:** *"Contract design ke liye `AirlineService` interface banaya hai jisko `GeetAirlineSystem` implement karta hai. Implementation details user se hidden rehti hain."*

---

## 2. CORE JAVA CONCEPTS

### A. Constructors & Methods
- **Constructor Chaining:**
  - `Customer` ke constructor me `super(userId, name, email, password, phone);` use karke parent class constructor ko call kiya hai.
- **Instance Methods:** Business logic methods jaise `authenticate()`, `bookFlight()`, `cancelFlight()`.

### B. Exception Handling
- **Custom Checked Exceptions:**
  - `class FlightNotFoundException extends Exception`
  - `class InvalidBookingException extends Exception`
- **Try-Catch-Finally:**
  - Invalid date format (`DateTimeParseException`), past date booking, ya missing flight handle karne ke liye try-catch blocks lagaye gaye hain.

### C. Access Modifiers
- `private`: Encapsulated fields jo sirf usi class ke andar accessible hain.
- `protected` / package-private: Subclasses aur internal operations ke liye.
- `public`: Service methods aur console interfaces ke liye.
- `final`: Immutable constants jaise `userId`, `pnr`.

---

## 3. COLLECTIONS & LAMBDA / STREAMS

### A. Collections Framework
1. **`ArrayList<Flight>` (`flightCatalog`):** O(1) index access ke liye flights list store karta hai.
2. **`LinkedList<Booking>` (`bookingHistory`):** Sequential order me reservations maintain karne ke liye.
3. **`HashSet<String>` (`registeredAirports`):** Unique airport/cities store karne ke liye (duplicates automatically ignore ho jaate hain).
4. **`HashMap<String, User>` (`userMap`):** Email id ko key banakar O(1) time me user login/lookup perform karta hai.

### B. Comparable vs Comparator
- **`Comparable<Flight>`:** `Flight` class `Comparable<Flight>` implement karti hai aur `compareTo()` method price ascending order me natural sorting deta hai.
- **`Comparator`:** Custom sorting ke liye:
  - `Comparator.comparing(Flight::getDuration)` se duration ke hisab se sort hota hai.
  - `(f1, f2) -> f1.getProvider().compareToIgnoreCase(...)` se airline provider ke hisab se sort hota hai.

### C. Lambda Expressions & Streams API (Java 8+)
- **Filtering:**
  ```java
  flightCatalog.stream()
      .filter(f -> f.getSource().equalsIgnoreCase(source))
      .collect(Collectors.toList());
  ```
- **Method Reference & forEach:**
  ```java
  myBookings.forEach(Booking::printSummary);
  ```

---

## 4. OTHER TOPICS

### A. Multithreading
- **Kahan use hua:** `TicketBookingProcessor implements Runnable`
- **Implementation:**
  ```java
  Thread reservationThread = new Thread(processor);
  reservationThread.start();
  reservationThread.join();
  ```
- **Real-world use:** Flight booking ke time par background thread inventory lock aur PNR generation simulate karta hai (`Thread.sleep(400)`), bina main thread ko block kiye.

### B. File Handling (I/O)
- **Writing to File:** `FileWriter` aur `BufferedWriter` use karke confirmed booking ka boarding pass `ticket_<pnr>.txt` file me generate hota hai.
- **Reading from File:** `FileReader` aur `BufferedReader` use karke saved ticket file ko console par live display kiya jaata hai.

---

## Quick Viva Q&A Ready Reference

| Question | Short Viva Answer |
|---|---|
| **Q: Project me encapsulation kahan hai?** | "Classes ke fields private hain aur unko validation ke saath getters aur setters ke zariye access kiya gaya hai." |
| **Q: Run-time polymorphism kaise dikhaya?** | "`User` abstract class ka reference use karke `displayDashboard()` call karte hain, jo runtime par Customer ya Admin ka respective dashboard render karta hai." |
| **Q: Comparable aur Comparator dono kyu lagaye?** | "Default/natural sorting (by price) ke liye `Comparable` lagaya, aur dynamic sorting (duration, provider) ke liye `Comparator` aur Lambdas use kiye." |
| **Q: Multithreading ka role kya hai?** | "Flight ticket confirmation aur PNR generation async background thread me process hoti hai via `Runnable` interface." |
| **Q: Data file me kaise persist ho raha hai?** | "`BufferedWriter` aur `BufferedReader` use karke physical boarding pass file (`ticket_GA1001.txt`) disk par write aur read hoti hai." |
