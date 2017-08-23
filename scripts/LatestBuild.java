
import java.util.*;
import java.io.*;
import java.net.*;
import java.nio.file.*;

public class LatestBuild {

  private static final String USER_AGENT = "Mozilla/5.0";
  private static final String[] SERVICES = {"actionsvc","actionexportersvc","casesvc","collectionexercisesvc",
  "iacsvc","samplesvc","surveysvc","notifygatewaysvc","sdxgatewaysvc"};
  private static final String SURVEYSVC = "surveysvc";
  private static final String USAGE = "java LatestBuild [-n] [-g] <Host> <HomeDir> <Service> \n" +
                                      "-n   get name of latest version\n" +
                                      "-g   download latest version of service\n";

  public static void main(String[] args){
    try {
      String optn = args[0];
      String host = args[1];
      String home = args[2] + "/";
      String service = args[3];
      String ext;
      if (!(optn.equals("-g")) && !(optn.equals("-n"))){
        System.out.println(USAGE);
        System.exit(0);
      }
      if(!Arrays.asList(SERVICES).contains(service)) {
        System.out.println("Error! Service <" + service + "> does not exist!");
        System.exit(0);
      }
      if (service.equals(SURVEYSVC)) {
        ext = ".tar";
      }
      else ext = ".jar";
      String url = "" + host + "/artifactory/api/search/artifact?name=" + service + "*" + ext + "&repos=libs-snapshot-local";
      String snapshotList = getList(url,service,ext,home);
      String snapshotUrl = getSnapshotUrl(snapshotList,service);
      if(optn.equals("-g")){
        getSvc(snapshotUrl,service,ext,home);
      } else if(optn.equals("-n")) {
        getName(snapshotUrl,home,service);
      }
    } catch(Exception e){
      System.out.println(e);
    }
  }

  private static String getList(String uri,String svc, String ext,String home) throws IOException{
    URL url = new URL(uri);
    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
    connection.setRequestMethod("GET");
    connection.setRequestProperty("User-Agent", USER_AGENT);

    BufferedReader br = new BufferedReader(
      new InputStreamReader(connection.getInputStream()));

    StringBuffer response = new StringBuffer();
    String output;
    while ((output = br.readLine()) != null) {
      response.append(output);
    }
    br.close();
    return response.toString();
  }

  private static String getSnapshotUrl(String snapshotList, String service){
    snapshotList = snapshotList.replaceAll("[\"\\} \\n\\{\\[\\]]*","");
    snapshotList = snapshotList.replaceAll("results:uri:","");
    snapshotList = snapshotList.replaceAll("api/storage/","");

    List<String> snapshots = new ArrayList<String>(Arrays.asList(snapshotList.split("\\,uri\\:")));
    int urls = snapshots.size();
    String url = "";
    if(service.equals(SURVEYSVC)) {
      snapshotList = snapshotList.replaceAll("[a-zA-Z\\.\\/\\-\\:]*","");
      List<String> surveyVersions = new ArrayList<String>(Arrays.asList(snapshotList.split("\\,")));
      List<Integer> versionsNo = new ArrayList<Integer>();
      for(String s : surveyVersions){
        versionsNo.add(Integer.parseInt(s));
      }
      Collections.sort(versionsNo);
      int i = 0 ;
      for(Integer v : versionsNo) {
        surveyVersions.set(i, v.toString());
        i++;
      }
      i=0;
      for(String snapshot : snapshots) {
        if(snapshot.contains(surveyVersions.get(surveyVersions.size()-1))){
          url = snapshot;
        }
        i++;
      }
    }
    else url = snapshots.get(urls-1);
    return url;
  }

  private static void getName(String snapshotUrl, String home, String svc) throws FileNotFoundException{
    String[] fileName = snapshotUrl.split("/");
    String p = fileName[12].replaceAll(".jar","") + ".git.sha";
    Path path = Paths.get(p);
    try(  PrintWriter out = new PrintWriter(p)  ){
      out.println(fileName[12]);
    }
  }

  private static void getSvc(String uri,String svc, String ext,String home) throws IOException{
    URL obj = new URL(uri);
    HttpURLConnection connection = (HttpURLConnection) obj.openConnection();
    connection.setRequestMethod("GET");
    connection.setRequestProperty("User-Agent", USER_AGENT);

    int responseCode = connection.getResponseCode();

    BufferedReader br = new BufferedReader(
            new InputStreamReader(connection.getInputStream()));

    String p = home + svc + ext;
    Path path = Paths.get(p);
    Files.copy(connection.getInputStream(), path);
    br.close();
  }
}
