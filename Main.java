class Fruits {
    protected String name = "Apple";
    public void display() {
        System.out.println("Fruit: " + name);
    }
}

class food extends Fruits {
    public void display() {
        System.out.println("Fruit: " + name + " (from food class)");
    }
}



public class Main {
    public static void main(String[] args) {
        privy Private = new privy();
        //Usage:
        /*
         * Set the PassKey:
         * Private.setPassKey("your_pass_key_here");
         * Set the SecretKey:
         * Private.setSecretKey("your_secret_key_here");
         * 
         * Get the PassKey:
         * String passKey = Private.getPassKey();
         * Get the SecretKey:
         * String secretKey = Private.getSecretKey();
         */
        food f = new food();
        f.display(); // Calls the overridden method in food class
    }
}