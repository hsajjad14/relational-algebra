// A simple JDBC example.

// Remember that you need to put the jdbc postgresql driver in your class path
// when you run this code.
// See /local/packages/jdbc-postgresql on cdf for the driver, another example
// program, and a how-to file.

// To compile and run this program on cdf:
// (1) Compile the code in Example.java.
//     javac Example
// This creates the file Example.class.
// (2) Run the code in Example.class.
// Normally, you would run a Java program whose main method is in a class
// called Example as follows:
//     java Example
// But we need to also give the class path to where JDBC is, so we type:
//     java -cp /local/packages/jdbc-postgresql/postgresql-9.4.1212.jar: Example
// Alternatively, we can set our CLASSPATH variable in linux.  (See
// /local/packages/jdbc-postgresql/HelloPostgresql.txt on cdf for how.)

import java.sql.*;
import java.io.*;

class JDBC {

    public static void main(String args[]) throws IOException
        {
            String url;
            Connection conn;
            PreparedStatement pStatement;
            ResultSet rs;
            String queryString;

            try {
                Class.forName("org.postgresql.Driver");
            }
            catch (ClassNotFoundException e) {
                System.out.println("Failed to find the JDBC driver");
            }
            try
            {
                // This program connects to my database csc343h-dianeh,
                // where I have loaded a table called Guess, with this schema:
                //     Guesses(_number_, name, guess, age)
                // and put some data into it.

                // Establish our own connection to the database.
                // This is the right url, username and password for jdbc
                // with postgres on cdf -- but you would replace "dianeh"
                // with your cdf account name.X^Vp::
                // Password really does need to be the emtpy string.
                url = "jdbc:postgresql://localhost:5432/csc343h-sajjadh2";
                conn = DriverManager.getConnection(url, "sajjadh2", "Uchiha@575318");

                // Executing this query without having first prepared it
                // would be safe because the entire query is hard-coded.
                // No one can inject any SQL code into our query.
                // But let's get in the habit of using a prepared statement.


                BufferedReader br = new BufferedReader(new
                      InputStreamReader(System.in));


                System.out.println("enter age of every get the average of everyone who is that age");

                queryString = "select avg(guess) from guesses where age >= ?";
                String age = br.readLine();

                PreparedStatement newps = conn.prepareStatement(queryString);
                newps.setInt(1, Integer.parseInt(age)); //turn age to integer and change setstring
                rs = newps.executeQuery();

                while (rs.next()) {
                    //String nam = rs.getString("name");
                    int avg = rs.getInt("avg");
                    System.out.println("The average guess for everyone older than "+age+" is: "+Integer.toString(avg));
                }



            }
            catch (SQLException se)
            {
                System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
            }

        }

}
