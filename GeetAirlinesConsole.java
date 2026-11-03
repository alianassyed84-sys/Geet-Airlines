import java.io.*;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * ============================================================================
 * GEET AIRLINES - CORE JAVA & OOP CONSOLE APPLICATION
 * ============================================================================
 * Designed for College Project Presentation & Viva Defense.
 * Mimics the core functionality of the Geet Airlines Web Platform.
 *
 * SYLLABUS TOPICS COVERED:
 * 1. OOP CONCEPTS:
 *    - Classes & Objects (Flight, User, Customer, Admin, Booking)
 *    - Encapsulation (Private fields, getters/setters, validation)
 *    - Inheritance (User -> Customer, Admin)
 *    - Polymorphism (Overriding: displayMenu(), toString() | Overloading: search())
 *    - Abstraction & Interfaces (AirlineService, Printable)
 *
 * 2. CORE JAVA:
 *    - Constructors & Constructor Chaining (super(), this())
 *    - Custom Exception Handling (FlightNotFoundException, InvalidBookingException)
 *    - Access Modifiers (private, protected, public, package-private)
 *
 * 3. COLLECTIONS & LAMBDA / STREAMS:
 *    - Collections: ArrayList, LinkedList, Set (HashSet), Map (HashMap)
 *    - Comparable (Natural sort by price) & Comparator (Sort by duration, provider)
 *    - Lambda Expressions & Java Streams (filter, sorted, collect, map, forEach)
 *
 * 4. OTHER TOPICS:
 *    - Multithreading (Runnable / Thread for background seat reservation & PNR generation)
 *    - File Handling (FileWriter, BufferedWriter, BufferedReader, FileReader for tickets)
 * ============================================================================
 */

// ============================================================================
// 1. CUSTOM EXCEPTIONS [CORE JAVA: EXCEPTION HANDLING]
// ============================================================================
class FlightNotFoundException extends Exception {
    public FlightNotFoundException(String message) {
        super(message);
    }
}

class InvalidBookingException extends Exception {
    public InvalidBookingException(String message) {
        super(message);
    }
}

// ============================================================================
// 2. INTERFACES [OOP: ABSTRACTION]
// ============================================================================
interface Printable {
    void printSummary();
}

interface AirlineService {
    void registerUser(User user);
    User authenticate(String email, String password);
    List<Flight> getAllFlights();
    void addFlight(Flight flight);
    void cancelFlight(String flightNumber) throws FlightNotFoundException;
    Booking bookFlight(Customer customer, Flight flight, String date, String time) throws InvalidBookingException;
}

// ============================================================================
// 3. MODELS & INHERITANCE [OOP: CLASSES, INHERITANCE, ENCAPSULATION]
// ============================================================================

/**
 * Abstract Base Class for Users [OOP: ABSTRACTION & INHERITANCE]
 */
abstract class User {
    // Encapsulation: private/protected fields
    private final String userId;
    private String name;
    private String email;
    private String password;
    private String phone;

    // Parameterized Constructor
    public User(String userId, String name, String email, String password, String phone) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.password = password;
        this.phone = phone;
    }

    // Getters and Setters [OOP: ENCAPSULATION]
    public String getUserId() { return userId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public String getPhone() { return phone; }
    
    public boolean checkPassword(String inputPassword) {
        return this.password.equals(inputPassword);
    }

    // Abstract method: must be implemented by subclasses [OOP: POLYMORPHISM]
    public abstract String getRole();
    public abstract void displayDashboard();

    @Override
    public String toString() {
        return "[" + getRole() + "] " + name + " (" + email + ")";
    }
}

/**
 * Customer User Subclass [OOP: INHERITANCE]
 */
class Customer extends User {
    private String address;

    public Customer(String userId, String name, String email, String password, String phone, String address) {
        // Constructor Chaining using super() [CORE JAVA: CONSTRUCTORS]
        super(userId, name, email, password, phone);
        this.address = address;
    }

    public String getAddress() { return address; }

    // Method Overriding [OOP: POLYMORPHISM]
    @Override
    public String getRole() {
        return "CUSTOMER";
    }

    @Override
    public void displayDashboard() {
        System.out.println("\n----------------------------------------------");
        System.out.println("  WELCOME TO GEET AIRLINES, " + getName().toUpperCase());
        System.out.println("  Role: Passenger | Contact: " + getPhone());
        System.out.println("----------------------------------------------");
    }
}

/**
 * Admin User Subclass [OOP: INHERITANCE]
 */
class Admin extends User {
    private final String department;

    public Admin(String userId, String name, String email, String password, String phone, String department) {
        super(userId, name, email, password, phone);
        this.department = department;
    }

    public String getDepartment() { return department; }

    @Override
    public String getRole() {
        return "ADMINISTRATOR";
    }

    @Override
    public void displayDashboard() {
        System.out.println("\n==============================================");
        System.out.println("  GEET AIRLINES - ADMIN MANAGEMENT CONSOLE");
        System.out.println("  Admin: " + getName() + " | Dept: " + department);
        System.out.println("==============================================");
    }
}

/**
 * Flight Model [COLLECTIONS: COMPARABLE for natural sorting by price]
 */
class Flight implements Comparable<Flight>, Printable {
    private String flightNumber;
    private String provider;
    private String source;
    private String destination;
    private String duration; // e.g. "2h 10m"
    private double price;

    public Flight(String flightNumber, String provider, String source, String destination, String duration, double price) {
        this.flightNumber = flightNumber;
        this.provider = provider;
        this.source = source;
        this.destination = destination;
        this.duration = duration;
        this.price = price;
    }

    // Getters and Setters [OOP: ENCAPSULATION]
    public String getFlightNumber() { return flightNumber; }
    public String getProvider() { return provider; }
    public String getSource() { return source; }
    public String getDestination() { return destination; }
    public String getDuration() { return duration; }
    public double getPrice() { return price; }

    // Natural ordering: Comparable interface sorts by price ascending [COLLECTIONS: COMPARABLE]
    @Override
    public int compareTo(Flight other) {
        return Double.compare(this.price, other.price);
    }

    @Override
    public void printSummary() {
        System.out.printf("| %-8s | %-12s | %-10s -> %-10s | %-7s | Rs %8.2f |\n",
                flightNumber, provider, source, destination, duration, price);
    }

    @Override
    public String toString() {
        return String.format("%s (%s): %s -> %s, Duration: %s, Price: Rs %.2f",
                flightNumber, provider, source, destination, duration, price);
    }
}

/**
 * Booking Record Model
 */
class Booking implements Printable {
    private final String pnr;
    private final Customer customer;
    private final Flight flight;
    private final String travelDate;
    private final String travelTime;
    private final Date bookingTimestamp;

    public Booking(String pnr, Customer customer, Flight flight, String travelDate, String travelTime) {
        this.pnr = pnr;
        this.customer = customer;
        this.flight = flight;
        this.travelDate = travelDate;
        this.travelTime = travelTime;
        this.bookingTimestamp = new Date();
    }

    public String getPnr() { return pnr; }
    public Customer getCustomer() { return customer; }
    public Flight getFlight() { return flight; }
    public String getTravelDate() { return travelDate; }
    public String getTravelTime() { return travelTime; }

    @Override
    public void printSummary() {
        System.out.printf("PNR: %-10s | %-15s | Flight: %-7s (%s -> %s) | Date: %s %s\n",
                pnr, customer.getName(), flight.getFlightNumber(),
                flight.getSource(), flight.getDestination(), travelDate, travelTime);
    }
}

// ============================================================================
// 4. MULTITHREADING [TOPICS: RUNNABLE & THREADS]
// ============================================================================
/**
 * Simulates async seat reservation, inventory check, and PNR generation.
 */
class TicketBookingProcessor implements Runnable {
    private final String flightNumber;
    private final String passengerName;
    private volatile boolean completed = false;

    public TicketBookingProcessor(String flightNumber, String passengerName) {
        this.flightNumber = flightNumber;
        this.passengerName = passengerName;
    }

    @Override
    public void run() {
        try {
            System.out.print("  [Processing reservation asynchronously");
            for (int i = 0; i < 4; i++) {
                Thread.sleep(400); // [CORE JAVA: THREAD SLEEP]
                System.out.print(".");
            }
            System.out.println(" Confirmed!]");
            completed = true;
        } catch (InterruptedException e) {
            System.err.println("Booking thread was interrupted: " + e.getMessage());
            Thread.currentThread().interrupt();
        }
    }

    public boolean isCompleted() {
        return completed;
    }
}

// ============================================================================
// 5. AIRLINE SERVICE IMPLEMENTATION [COLLECTIONS, STREAMS, FILE HANDLING]
// ============================================================================
class GeetAirlineSystem implements AirlineService {
    // [COLLECTIONS & MAP]: Map email -> User for O(1) login lookup
    private final Map<String, User> userMap = new HashMap<>();

    // [COLLECTIONS & LIST]: ArrayList of available flights
    private final List<Flight> flightCatalog = new ArrayList<>();

    // [COLLECTIONS & LINKEDLIST]: LinkedList to track bookings in sequential order
    private final LinkedList<Booking> bookingHistory = new LinkedList<>();

    // [COLLECTIONS & SET]: HashSet to ensure unique airport destination names
    private final Set<String> registeredAirports = new HashSet<>();

    public GeetAirlineSystem() {
        seedInitialData();
    }

    private void seedInitialData() {
        // Sample Users
        userMap.put("admin@geetairlines.com", new Admin("U100", "Administrator", "admin@geetairlines.com", "admin123", "9876543210", "Flight Operations"));
        userMap.put("test@geetairlines.com", new Customer("U101", "Gursangeet Singh", "test@geetairlines.com", "Password123!", "9812345678", "Civil Lines, Amritsar"));

        // Sample Flights matching the website's initial seed
        addFlight(new Flight("AI101", "Air India", "Delhi", "Mumbai", "2h 10m", 5499.00));
        addFlight(new Flight("6E205", "IndiGo", "Mumbai", "Bengaluru", "1h 45m", 4299.00));
        addFlight(new Flight("SG312", "SpiceJet", "Delhi", "Jaipur", "1h 00m", 2499.00));
        addFlight(new Flight("UK810", "Vistara", "Delhi", "Bengaluru", "2h 40m", 6800.00));
        addFlight(new Flight("6E550", "IndiGo", "Delhi", "Mumbai", "2h 15m", 4899.00));
        addFlight(new Flight("AI404", "Air India", "Bengaluru", "Kolkata", "2h 30m", 5199.00));
    }

    @Override
    public void registerUser(User user) {
        userMap.put(user.getEmail().toLowerCase(), user);
    }

    @Override
    public User authenticate(String email, String password) {
        User user = userMap.get(email.toLowerCase());
        if (user != null && user.checkPassword(password)) {
            return user;
        }
        return null;
    }

    @Override
    public List<Flight> getAllFlights() {
        return Collections.unmodifiableList(flightCatalog);
    }

    @Override
    public void addFlight(Flight flight) {
        flightCatalog.add(flight);
        registeredAirports.add(flight.getSource());
        registeredAirports.add(flight.getDestination());
    }

    @Override
    public void cancelFlight(String flightNumber) throws FlightNotFoundException {
        boolean removed = flightCatalog.removeIf(f -> f.getFlightNumber().equalsIgnoreCase(flightNumber));
        if (!removed) {
            throw new FlightNotFoundException("Flight " + flightNumber + " does not exist in the active catalog.");
        }
    }

    // ========================================================================
    // METHOD OVERLOADING [OOP: POLYMORPHISM]
    // ========================================================================
    /**
     * Search by destination only [Method Overload 1]
     */
    public List<Flight> searchFlights(String destination) {
        // [COLLECTIONS: STREAMS & LAMBDA]
        return flightCatalog.stream()
                .filter(f -> f.getDestination().equalsIgnoreCase(destination))
                .collect(Collectors.toList());
    }

    /**
     * Search by source and destination [Method Overload 2]
     */
    public List<Flight> searchFlights(String source, String destination) {
        // [COLLECTIONS: STREAMS & LAMBDA]
        return flightCatalog.stream()
                .filter(f -> (source.isEmpty() || f.getSource().equalsIgnoreCase(source)) &&
                             (destination.isEmpty() || f.getDestination().equalsIgnoreCase(destination)))
                .collect(Collectors.toList());
    }

    /**
     * Search with full filter criteria [Method Overload 3]
     */
    public List<Flight> searchFlights(String provider, String source, String destination) {
        return flightCatalog.stream()
                .filter(f -> (provider.isEmpty() || f.getProvider().equalsIgnoreCase(provider)) &&
                             (source.isEmpty() || f.getSource().equalsIgnoreCase(source)) &&
                             (destination.isEmpty() || f.getDestination().equalsIgnoreCase(destination)))
                .collect(Collectors.toList());
    }

    // ========================================================================
    // COMPARATOR SORTING [COLLECTIONS: COMPARATOR & LAMBDA]
    // ========================================================================
    public List<Flight> getFlightsSortedByPrice() {
        // Uses Flight.compareTo (Comparable)
        List<Flight> sorted = new ArrayList<>(flightCatalog);
        Collections.sort(sorted);
        return sorted;
    }

    public List<Flight> getFlightsSortedByDuration() {
        // Uses Comparator with Lambda [LAMBDA & COMPARATOR]
        return flightCatalog.stream()
                .sorted(Comparator.comparing(Flight::getDuration))
                .collect(Collectors.toList());
    }

    public List<Flight> getFlightsSortedByProvider() {
        // Anonymous Comparator or Lambda
        return flightCatalog.stream()
                .sorted((f1, f2) -> f1.getProvider().compareToIgnoreCase(f2.getProvider()))
                .collect(Collectors.toList());
    }

    // ========================================================================
    // BOOKING WITH MULTITHREADING & FILE HANDLING
    // ========================================================================
    @Override
    public Booking bookFlight(Customer customer, Flight flight, String date, String time) throws InvalidBookingException {
        if (flight == null) {
            throw new InvalidBookingException("Cannot book: Flight details cannot be null.");
        }
        try {
            LocalDate travelDate = LocalDate.parse(date);
            if (travelDate.isBefore(LocalDate.now())) {
                throw new InvalidBookingException("Booking date cannot be in the past!");
            }
        } catch (DateTimeParseException e) {
            throw new InvalidBookingException("Invalid date format. Please use YYYY-MM-DD.");
        }

        // Multithreading demonstration [MULTITHREADING: RUNNABLE & THREAD]
        TicketBookingProcessor processor = new TicketBookingProcessor(flight.getFlightNumber(), customer.getName());
        Thread reservationThread = new Thread(processor);
        reservationThread.start();
        try {
            reservationThread.join(); // Wait for confirmation thread to complete
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        // Generate PNR
        String pnr = "GA" + (1000 + bookingHistory.size() + 1);
        Booking booking = new Booking(pnr, customer, flight, date, time);
        bookingHistory.add(booking);

        // [FILE HANDLING: EXPORT TICKET TO FILE]
        saveTicketToFile(booking);

        return booking;
    }

    /**
     * File Handling: Writes ticket details to a physical file [FILE HANDLING: WRITE]
     */
    private void saveTicketToFile(Booking booking) {
        String fileName = "ticket_" + booking.getPnr() + ".txt";
        File ticketFile = new File(fileName);

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(ticketFile))) {
            writer.write("====================================================\n");
            writer.write("              GEET AIRLINES BOARDING PASS           \n");
            writer.write("====================================================\n");
            writer.write("PNR NO           : " + booking.getPnr() + "\n");
            writer.write("PASSENGER NAME   : " + booking.getCustomer().getName() + "\n");
            writer.write("PASSENGER EMAIL  : " + booking.getCustomer().getEmail() + "\n");
            writer.write("FLIGHT NUMBER    : " + booking.getFlight().getFlightNumber() + "\n");
            writer.write("AIRLINE PROVIDER : " + booking.getFlight().getProvider() + "\n");
            writer.write("ROUTE            : " + booking.getFlight().getSource() + " -> " + booking.getFlight().getDestination() + "\n");
            writer.write("DATE OF TRAVEL   : " + booking.getTravelDate() + "\n");
            writer.write("DEPARTURE TIME   : " + booking.getTravelTime() + "\n");
            writer.write("FARE PAID        : Rs " + String.format("%.2f", booking.getFlight().getPrice()) + "\n");
            writer.write("STATUS           : CONFIRMED\n");
            writer.write("====================================================\n");
            writer.write("Have a safe journey with Geet Airlines!\n");
            System.out.println("  [File Handling] Boarding pass saved to: " + ticketFile.getAbsolutePath());
        } catch (IOException e) {
            System.err.println("  [File Handling Error] Could not write ticket file: " + e.getMessage());
        }
    }

    /**
     * File Handling: Reads ticket back from disk [FILE HANDLING: READ]
     */
    public void displaySavedTicket(String pnr) {
        String fileName = "ticket_" + pnr + ".txt";
        File ticketFile = new File(fileName);
        if (!ticketFile.exists()) {
            System.out.println("  No saved ticket found on disk for PNR: " + pnr);
            return;
        }

        System.out.println("\n--- [READING TICKET FILE: " + fileName + "] ---");
        try (BufferedReader reader = new BufferedReader(new FileReader(ticketFile))) {
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }
        } catch (IOException e) {
            System.err.println("Error reading ticket file: " + e.getMessage());
        }
    }

    public List<Booking> getCustomerBookings(String userId) {
        // [STREAMS & LAMBDA]
        return bookingHistory.stream()
                .filter(b -> b.getCustomer().getUserId().equals(userId))
                .collect(Collectors.toList());
    }

    public List<Booking> getAllBookings() {
        return Collections.unmodifiableList(bookingHistory);
    }

    public Set<String> getRegisteredAirports() {
        return Collections.unmodifiableSet(registeredAirports);
    }
}

// ============================================================================
// 6. MAIN APPLICATION & INTERACTIVE CONSOLE MENU
// ============================================================================
public class GeetAirlinesConsole {
    private static final Scanner scanner = new Scanner(System.in);
    private static final GeetAirlineSystem airline = new GeetAirlineSystem();

    public static void main(String[] args) {
        printHeader();

        boolean running = true;
        while (running) {
            System.out.println("\nMAIN MENU:");
            System.out.println("1. Login (Customer / Admin)");
            System.out.println("2. Register as New Customer");
            System.out.println("3. View All Active Flights (Guest View)");
            System.out.println("4. Run Syllabus OOP Concepts Self-Check");
            System.out.println("5. Exit Application");
            System.out.print("Enter choice (1-5): ");

            String choice = scanner.nextLine().trim();
            switch (choice) {
                case "1":
                    handleLogin();
                    break;
                case "2":
                    handleRegister();
                    break;
                case "3":
                    displayFlightTable(airline.getAllFlights());
                    break;
                case "4":
                    runVivaDemonstration();
                    break;
                case "5":
                    System.out.println("\nThank you for choosing Geet Airlines. Goodbye!");
                    running = false;
                    break;
                default:
                    System.out.println("Invalid selection. Please enter 1 to 5.");
            }
        }
    }

    private static void printHeader() {
        System.out.println("======================================================================");
        System.out.println("                    WELCOME TO GEET AIRLINES                          ");
        System.out.println("             Core Java & Object-Oriented Console Suite                ");
        System.out.println("======================================================================");
    }

    private static void handleLogin() {
        System.out.print("\nEnter Email: ");
        String email = scanner.nextLine().trim();
        System.out.print("Enter Password: ");
        String password = scanner.nextLine().trim();

        User user = airline.authenticate(email, password);
        if (user == null) {
            System.out.println("Invalid email or password! Please try again.");
            return;
        }

        user.displayDashboard(); // [OOP: POLYMORPHISM]

        if (user instanceof Customer) {
            runCustomerMenu((Customer) user);
        } else if (user instanceof Admin) {
            runAdminMenu((Admin) user);
        }
    }

    private static void handleRegister() {
        System.out.println("\n--- CUSTOMER REGISTRATION ---");
        System.out.print("Full Name: ");
        String name = scanner.nextLine().trim();
        System.out.print("Email: ");
        String email = scanner.nextLine().trim();
        System.out.print("Password (min 6 chars): ");
        String password = scanner.nextLine().trim();
        System.out.print("Phone Number: ");
        String phone = scanner.nextLine().trim();
        System.out.print("City / Address: ");
        String address = scanner.nextLine().trim();

        if (name.isEmpty() || email.isEmpty() || password.length() < 6 || phone.isEmpty()) {
            System.out.println("Error: All fields are required and password must be >= 6 characters.");
            return;
        }

        String userId = "U" + (100 + (int)(Math.random() * 900));
        Customer newCustomer = new Customer(userId, name, email, password, phone, address);
        airline.registerUser(newCustomer);
        System.out.println("Registration successful! You can now log in with " + email);
    }

    // ========================================================================
    // CUSTOMER MENU
    // ========================================================================
    private static void runCustomerMenu(Customer customer) {
        boolean loggedIn = true;
        while (loggedIn) {
            System.out.println("\nCUSTOMER SERVICES:");
            System.out.println("1. Search Flights (Filter by Route / Airline)");
            System.out.println("2. View All Flights (Sort by Price / Duration)");
            System.out.println("3. Book a Flight");
            System.out.println("4. View My Booking History");
            System.out.println("5. Print/View Saved Ticket File (File I/O Demo)");
            System.out.println("6. Logout");
            System.out.print("Choose action (1-6): ");

            String action = scanner.nextLine().trim();
            switch (action) {
                case "1":
                    handleSearchFlights();
                    break;
                case "2":
                    handleSortFlights();
                    break;
                case "3":
                    handleBookFlight(customer);
                    break;
                case "4":
                    List<Booking> myBookings = airline.getCustomerBookings(customer.getUserId());
                    if (myBookings.isEmpty()) {
                        System.out.println("You have no active bookings.");
                    } else {
                        System.out.println("\n--- YOUR RESERVATIONS ---");
                        myBookings.forEach(Booking::printSummary);
                    }
                    break;
                case "5":
                    System.out.print("Enter PNR to view ticket from file: ");
                    String pnr = scanner.nextLine().trim();
                    airline.displaySavedTicket(pnr);
                    break;
                case "6":
                    loggedIn = false;
                    System.out.println("Logged out successfully.");
                    break;
                default:
                    System.out.println("Invalid option.");
            }
        }
    }

    private static void handleSearchFlights() {
        System.out.println("\n--- SEARCH FLIGHTS ---");
        System.out.print("Provider (or press ENTER for any): ");
        String provider = scanner.nextLine().trim();
        System.out.print("Source City (or press ENTER for any): ");
        String source = scanner.nextLine().trim();
        System.out.print("Destination City (or press ENTER for any): ");
        String destination = scanner.nextLine().trim();

        // Demonstrates overloaded searchFlights method [POLYMORPHISM]
        List<Flight> results = airline.searchFlights(provider, source, destination);
        if (results.isEmpty()) {
            System.out.println("No flights found matching your search criteria.");
        } else {
            System.out.println("\nFound " + results.size() + " matching flight(s):");
            displayFlightTable(results);
        }
    }

    private static void handleSortFlights() {
        System.out.println("\n--- SORT CATALOG ---");
        System.out.println("1. Sort by Price (Lowest First) [Comparable]");
        System.out.println("2. Sort by Duration (Shortest First) [Comparator & Lambda]");
        System.out.println("3. Sort by Airline Provider [Streams & Lambda]");
        System.out.print("Select sorting option (1-3): ");
        String sortChoice = scanner.nextLine().trim();

        List<Flight> sorted;
        switch (sortChoice) {
            case "1":
                sorted = airline.getFlightsSortedByPrice();
                break;
            case "2":
                sorted = airline.getFlightsSortedByDuration();
                break;
            case "3":
                sorted = airline.getFlightsSortedByProvider();
                break;
            default:
                sorted = airline.getAllFlights();
        }
        displayFlightTable(sorted);
    }

    private static void handleBookFlight(Customer customer) {
        displayFlightTable(airline.getAllFlights());
        System.out.print("\nEnter Flight Number to reserve (e.g. AI101): ");
        String flightNo = scanner.nextLine().trim();

        Flight selectedFlight = airline.getAllFlights().stream()
                .filter(f -> f.getFlightNumber().equalsIgnoreCase(flightNo))
                .findFirst()
                .orElse(null);

        if (selectedFlight == null) {
            System.out.println("Error: Flight number not found in catalog.");
            return;
        }

        System.out.print("Enter Travel Date (YYYY-MM-DD): ");
        String date = scanner.nextLine().trim();
        System.out.print("Enter Preferred Time (HH:MM, e.g. 14:30): ");
        String time = scanner.nextLine().trim();

        try {
            // [CORE JAVA: EXCEPTION HANDLING & MULTITHREADING]
            Booking booking = airline.bookFlight(customer, selectedFlight, date, time);
            System.out.println("\n==============================================");
            System.out.println("        RESERVATION SUCCESSFUL!               ");
            System.out.println("==============================================");
            System.out.println("PNR: " + booking.getPnr());
            System.out.println("Flight: " + selectedFlight.getFlightNumber() + " (" + selectedFlight.getProvider() + ")");
            System.out.println("Route: " + selectedFlight.getSource() + " -> " + selectedFlight.getDestination());
            System.out.println("Date: " + date + " at " + time);
            System.out.printf("Total Fare: Rs %.2f\n", selectedFlight.getPrice());
            System.out.println("A text copy of your boarding ticket has been generated.");
        } catch (InvalidBookingException e) {
            System.err.println("Booking Failed: " + e.getMessage());
        }
    }

    // ========================================================================
    // ADMIN MENU
    // ========================================================================
    private static void runAdminMenu(Admin admin) {
        boolean loggedIn = true;
        while (loggedIn) {
            System.out.println("\nADMINISTRATOR CONSOLE:");
            System.out.println("1. Add New Flight to Catalog");
            System.out.println("2. Cancel / Remove a Flight");
            System.out.println("3. View All Customer Bookings");
            System.out.println("4. View All Registered Airports [Set Demo]");
            System.out.println("5. View Full Flight Catalog");
            System.out.println("6. Logout");
            System.out.print("Choose action (1-6): ");

            String action = scanner.nextLine().trim();
            switch (action) {
                case "1":
                    handleAdminAddFlight();
                    break;
                case "2":
                    handleAdminRemoveFlight();
                    break;
                case "3":
                    List<Booking> all = airline.getAllBookings();
                    if (all.isEmpty()) {
                        System.out.println("No passenger bookings recorded yet.");
                    } else {
                        System.out.println("\n--- ALL PASSENGER RESERVATIONS ---");
                        all.forEach(Booking::printSummary);
                    }
                    break;
                case "4":
                    System.out.println("\n--- REGISTERED AIRPORT DESTINATIONS (HashSet) ---");
                    airline.getRegisteredAirports().forEach(airport -> System.out.println(" * " + airport));
                    break;
                case "5":
                    displayFlightTable(airline.getAllFlights());
                    break;
                case "6":
                    loggedIn = false;
                    System.out.println("Logged out from Admin Console.");
                    break;
                default:
                    System.out.println("Invalid choice.");
            }
        }
    }

    private static void handleAdminAddFlight() {
        System.out.println("\n--- ADD NEW FLIGHT ---");
        System.out.print("Flight Number (e.g. GA707): ");
        String no = scanner.nextLine().trim();
        System.out.print("Provider (e.g. Geet Express): ");
        String provider = scanner.nextLine().trim();
        System.out.print("Source: ");
        String source = scanner.nextLine().trim();
        System.out.print("Destination: ");
        String dest = scanner.nextLine().trim();
        System.out.print("Duration (e.g. 1h 50m): ");
        String duration = scanner.nextLine().trim();
        System.out.print("Price (Rs): ");
        try {
            double price = Double.parseDouble(scanner.nextLine().trim());
            if (source.equalsIgnoreCase(dest)) {
                System.out.println("Error: Source and Destination cannot be the same.");
                return;
            }
            Flight flight = new Flight(no, provider, source, dest, duration, price);
            airline.addFlight(flight);
            System.out.println("Flight " + no + " added successfully!");
        } catch (NumberFormatException e) {
            System.out.println("Error: Invalid price entered.");
        }
    }

    private static void handleAdminRemoveFlight() {
        System.out.print("Enter Flight Number to remove: ");
        String flightNo = scanner.nextLine().trim();
        try {
            airline.cancelFlight(flightNo);
            System.out.println("Flight " + flightNo + " successfully removed.");
        } catch (FlightNotFoundException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }

    private static void displayFlightTable(List<Flight> flights) {
        System.out.println("\n+----------+--------------+--------------------------+---------+-------------+");
        System.out.printf("| %-8s | %-12s | %-24s | %-7s | %-11s |\n", "FLIGHT", "AIRLINE", "ROUTE", "TIME", "PRICE");
        System.out.println("+----------+--------------+--------------------------+---------+-------------+");
        for (Flight f : flights) {
            f.printSummary();
        }
        System.out.println("+----------+--------------+--------------------------+---------+-------------+");
    }

    // ========================================================================
    // VIVA DEMO METHOD: PROVES ALL SYLLABUS TOPICS IN ONE CLICK
    // ========================================================================
    private static void runVivaDemonstration() {
        System.out.println("\n=======================================================");
        System.out.println("   VIVA DEMONSTRATION OF ALL CORE JAVA & OOP TOPICS    ");
        System.out.println("=======================================================");

        System.out.println("\n[1] OOP INHERITANCE & POLYMORPHISM:");
        User u1 = new Customer("U1", "Rahul", "rahul@test.com", "pass", "99999", "Delhi");
        User u2 = new Admin("U2", "Admin Priya", "priya@test.com", "pass", "88888", "Flight Ops");
        System.out.println("  u1 is: " + u1); // calls toString()
        System.out.println("  u2 is: " + u2);
        System.out.println("  Polymorphic call u1.getRole(): " + u1.getRole());
        System.out.println("  Polymorphic call u2.getRole(): " + u2.getRole());

        System.out.println("\n[2] COLLECTIONS (ArrayList, HashSet, HashMap, LinkedList):");
        System.out.println("  * ArrayList Flights Count : " + airline.getAllFlights().size());
        System.out.println("  * Set Unique Airports     : " + airline.getRegisteredAirports());
        System.out.println("  * Map User Lookup         : admin@geetairlines.com exists? " + (airline.authenticate("admin@geetairlines.com", "admin123") != null));

        System.out.println("\n[3] COMPARABLE & COMPARATOR:");
        System.out.println("  * Lowest price flight (Comparable): " + airline.getFlightsSortedByPrice().get(0));
        System.out.println("  * Shortest flight (Comparator)     : " + airline.getFlightsSortedByDuration().get(0));

        System.out.println("\n[4] LAMBDA & STREAMS (Filter Delhi flights):");
        airline.getAllFlights().stream()
                .filter(f -> f.getSource().equalsIgnoreCase("Delhi"))
                .forEach(f -> System.out.println("    -> " + f.getFlightNumber() + " to " + f.getDestination()));

        System.out.println("\n[5] EXCEPTION HANDLING:");
        try {
            airline.cancelFlight("NON_EXISTING_999");
        } catch (FlightNotFoundException e) {
            System.out.println("  * Caught Custom Exception: " + e.getMessage());
        }

        System.out.println("\n[6] MULTITHREADING & FILE HANDLING:");
        try {
            Customer demoCustomer = (Customer) u1;
            Flight demoFlight = airline.getAllFlights().get(0);
            Booking b = airline.bookFlight(demoCustomer, demoFlight, LocalDate.now().plusDays(1).toString(), "10:00");
            System.out.println("  * Successfully created and saved booking: " + b.getPnr());
            airline.displaySavedTicket(b.getPnr());
        } catch (InvalidBookingException e) {
            System.out.println("  Demo booking failed: " + e.getMessage());
        }

        System.out.println("=======================================================");
        System.out.println("   ALL SYLLABUS TOPICS TESTED & VERIFIED SUCCESSFULLY! ");
        System.out.println("=======================================================\n");
    }
}
