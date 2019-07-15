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

          String querry = "select e1.id, e1.e_type, c1.name, cb.id as cabid , cb.start_date ,e1.e_date as eldate "+
          " from parlgov.election e1 join parlgov.country c1 on e1.country_id = c1.id "+
          " full join parlgov.election e2 on e2.e_type = e1.e_type "+
          " and e2.previous_parliament_election_id = e1.id "+
          " full join parlgov.cabinet cb on cb.country_id = c1.id and date_part('year',cb.start_date) >= date_part('year',e1.e_date) "+
          " and cb.election_id = e1.id  "+
          " where c1.name = ?  "+
          " order by e1.e_date desc";


          PreparedStatement ps3 = connection.prepareStatement(querry);
          ps3.setString(1, countryName);


          this.rs = ps3.executeQuery();



          List<Integer> electionids = new ArrayList<Integer>();
          List<Integer> cabinetsids = new ArrayList<Integer>();

          while(this.rs.next()){
            electionids.add(this.rs.getInt("id"));
            int cabid = this.rs.getInt("cabid");
            if (!this.rs.wasNull()){
              cabinetsids.add(cabid);
            }

          }



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
        String querry ="select p.id as id1, p2.id as id2, "+
         "p.description as desc1, p2.description as desc2, "+
         "p.comment as comm1,  p2.comment as comm2 "+
        "from parlgov.politician_president p, parlgov.politician_president p2 " +
        "where p.id <> p2.id and p.id = ? ";


        double similar = 0;
        double similar2 = 0;

        try{

          PreparedStatement prepst = this.connection.prepareStatement(querry);
          prepst.setInt(1,politicianName);
          this.rs = prepst.executeQuery();


          while (rs.next()){
            Integer id2 = rs.getInt("id2");
            String desc1 = rs.getString("desc1");
            String desc2 = rs.getString("desc2");
            String comm1 = rs.getString("comm1");
            String comm2 = rs.getString("comm2");

            String p1 = desc1 + " " + comm1;
            String p2 = desc2 + " " + comm2;
            similar = similarity(p1, p2);
            if ((float)similar >= threshold){
              ret.add(id2);
            }


          }
        }catch(SQLException e){
          System.out.println("SQLException: "+e.getMessage());
          e.printStackTrace();
        }



        return ret;
    }

    public static void main(String[] args) {
        //You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
        try {
          Assignment2 test = new Assignment2();
          boolean ret = test.connectDB("jdbc:postgresql://localhost:5432/csc343h-sajjadh2", "sajjadh2", "Uchiha@575318" );
          System.out.println(ret);

          ElectionCabinetResult temp = test.electionSequence("Germany");
          //float f = 0.35;
          System.out.println();
          System.out.println(temp.toString());
          List<Integer> t2 = test.findSimilarPoliticians(9,(float)0.25);
          for(Integer i: t2){
            System.out.println(i);
          }
        }catch(ClassNotFoundException e){
          System.out.println("Assignment2 class not found");
        }

    }


}
