import java.sql.*;
//import java.util.List;
import java.util.*;
import java.io.*;
// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
//import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {
  // java.sql.Connection  conn;
  PreparedStatement ps;
  ResultSet rs;
    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try{
          this.connection = DriverManager.getConnection(url, username, password);
          //return true;
        }catch(SQLException se){
          return false;
        }

        return true;


    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        if (this.rs != null){
          try{
            this.rs.close();
          }catch (SQLException e) {
            return false;
          }
        }
        if (this.ps != null){
          try{
            this.ps.close();
          }catch (SQLException e) {
            return false;
          }
        }
        if (this.connection != null){
          try{
            this.connection.close();
            return true;
          }catch (SQLException e) {
            return false;
          }
        }

        return false;

    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        ElectionCabinetResult result = null;
        try{
        // Implement this method!
          String testinggg = "SET search_path TO parlgov";
          String nextEPelectionview = "create view nextEPelection as "+
            " select e1.id, e2.e_date as enddate "+
            " from parlgov.election e1, parlgov.election e2 "+
            " where e2.previous_ep_election_id = e1.id";

          String nextparlelectionview = "create view nextparlelection as "+
          "select e1.id, e2.e_date as enddate "+
          "from parlgov.election e1, parlgov.election e2 "+
          "where e2.previous_parliament_election_id = e1.id";

          String almostEPelview = "create view almostEPel as "+
          "select c.name, cab.id as cabid, cab.start_date as cabstartdate, "+
          "e.e_date as elecdate, e.id as elecid, "+
          "npe.enddate as nextelectiondate "+
          "from parlgov.country c join parlgov.election e on e.country_id = c.id "+
          "join parlgov.cabinet cab on cab.country_id = c.id and cab.start_date >= e.e_date "+
          "join nextEPelection npe on e.id = npe.id and cab.start_date <= npe.enddate ";

          String almostparlelview = "create view almostparlel as "+
          "select c.name, cab.id as cabid, cab.start_date as cabstartdate, "+
          "e.e_date as elecdate, e.id as elecid, "+
          "npe.enddate as nextelectiondate "+
          "from parlgov.country c join parlgov.election e on e.country_id = c.id "+
          "join parlgov.cabinet cab on cab.country_id = c.id and cab.start_date >= e.e_date "+
          "join nextparlelection npe on e.id = npe.id and cab.start_date <= npe.enddate ";

          String temp = "create view temp as "+
          " (select elecid, cabid, name, elecdate "+
          " from almostparlel) "+
          " Union "+
          " (select elecid, cabid, name, elecdate "+
          " from almostEPel)";

          String queryString = "select elecid, cabid, elecdate from temp "+
           "where name = ? "+
           "order by elecdate desc";



          // String testddl = "select id, name from parlgov.cabinet";
          // PreparedStatement nps = conn.prepareStatement(testddl);
          // System.out.println("ll");
          // rs = nps.executeQuery();
          // System.out.println("aa");
          //
          // while (rs.next()){
          //     String name = rs.getString("name");
          //     Integer id = rs.getInt("id");
          //     System.out.print(name);
          //     System.out.print(" ");
          //     System.out.println(id);
          // }
          PreparedStatement ps1 = connection.prepareStatement(nextEPelectionview);
          ps1.executeUpdate();
          //while (rs.next()){}

          PreparedStatement ps2 = connection.prepareStatement(nextparlelectionview);
          ps2.executeUpdate();

          PreparedStatement ps3 = connection.prepareStatement(almostEPelview);
          ps3.executeUpdate();

          PreparedStatement ps4 = connection.prepareStatement(almostparlelview);
          ps4.executeUpdate();

          PreparedStatement ps5 = connection.prepareStatement(temp);
          ps5.executeUpdate();

          PreparedStatement ps6 = connection.prepareStatement(queryString);
          ps6.setString(1,countryName);
          this.rs = ps6.executeQuery();



          List<Integer> electionids = new ArrayList<Integer>();
          List<Integer> cabinetsids = new ArrayList<Integer>();

          while(this.rs.next()){
            electionids.add(this.rs.getInt("elecid"));
            cabinetsids.add(this.rs.getInt("cabid"));
            System.out.print("elecid: " + Integer.toString((this.rs.getInt("elecid"))));
            System.out.println(" cabid: " + Integer.toString((this.rs.getInt("cabid"))));
            java.sql.Date date = rs.getDate("elecdate");
            System.out.println(date);
          }

          String drop1 = "drop view nextparlelection cascade";
          String drop2 = "drop view nextepelection cascade";
          PreparedStatement ps7 = connection.prepareStatement(drop1);
          ps7.executeUpdate();
          PreparedStatement ps8 = connection.prepareStatement(drop2);
          ps8.executeUpdate();

          result = new ElectionCabinetResult(electionids, cabinetsids);
        }catch(SQLException e){

          System.out.println("SQLException: "+e.getMessage());
          e.printStackTrace();
        }
        return result;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        List<Integer> ret = new ArrayList<Integer>();
        String querry = "select p.description as desc1, p2.id as id2, "+
        "p2.description as desc1 from politician_president p, politician_president p2 "+
        "where p.id < p2.id and p.id = ?";
        double similar = 0;

        try{
          PreparedStatement prepst = this.connection.prepareStatement(querry);
          this.rs = prepst.executeQuery();
          boolean pass = false;
          while (rs.next()){
            pass = false;
            Integer id2 = rs.getInt("id2");
            String desc1 = rs.getString("desc1");
            if (rs.wasNull() || desc1 == null){
              pass = true;
            }
            String desc2 = rs.getString("desc2");
            if (rs.wasNull() || desc2 == null){
              pass = true;
            }
            if (pass == true){
              similar = similarity(desc1, desc2);
              if ((float)similar >= threshold){
                ret.add(id2);
              }
            }
          }
        }catch(SQLException e){

        }



        return ret;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
        try {
          Assignment2 test = new Assignment2();
          boolean ret = test.connectDB("jdbc:postgresql://localhost:5432/csc343h-sajjadh2", "sajjadh2", "Uchiha@575318" );
          System.out.println(ret);

          ElectionCabinetResult temp = test.electionSequence("United Kingdom");
          //float f = 0.35;
          List<Integer> t2 = test.findSimilarPoliticians(9,(float)0.25);
          for(Integer i: t2){
            System.out.println(i);
          }
        }catch(ClassNotFoundException e){
          System.out.println("Assignment2 class not found");
        }

    }


}
